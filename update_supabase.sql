-- ==============================================================================
-- TBEATS - SUPABASE RESET & CLEAN RECREATE MIGRATION SCRIPT
-- Jalankan seluruh script ini di SQL Editor pada Supabase Dashboard Anda
-- untuk mereset total database Anda ke kondisi bersih, fungsional, dan bebas error.
-- ==============================================================================

-- 1. Hapus seluruh trigger, fungsi, RLS policies, dan tabel lama agar database bersih total
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP TABLE IF EXISTS public.medications CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS aturan_makan_enum CASCADE;

-- 2. Buat ulang ENUM untuk Role
CREATE TYPE user_role AS ENUM ('perawat', 'pasien', 'dokter');

-- 3. Buat ulang tabel Profiles (Berdasarkan struktur supabase_schema.sql + kolom klinis lengkap secara bawaan)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role user_role NOT NULL DEFAULT 'pasien',
  phone TEXT, -- Menyimpan nomor telepon perawat/pasien
  perawat_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL, -- Relasi perawat pengawas (jika role='pasien')
  
  -- Kolom Medis Klinis (Wajib untuk fungsionalitas pasien TBeats)
  registration_no TEXT,
  start_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  duration_months INTEGER DEFAULT 6,
  phase TEXT DEFAULT 'Intensif', -- 'Intensif' atau 'Lanjutan'
  dokter_name TEXT,
  clinic_name TEXT DEFAULT 'Puskesmas Kecamatan',
  clinic_address TEXT DEFAULT 'Jl. Kesehatan No. 123',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Buat ulang tabel Medications (Berdasarkan struktur supabase_schema.sql + kolom pelaporan minum obat secara bawaan)
CREATE TABLE public.medications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL, -- Obat milik siapa
  nama_obat TEXT NOT NULL,
  takaran TEXT NOT NULL,
  jam_minum TEXT NOT NULL, -- Menggunakan TEXT agar fleksibel dibanding TIME
  aturan_makan TEXT NOT NULL, -- Menggunakan TEXT agar fleksibel dibanding ENUM kaku
  status TEXT NOT NULL DEFAULT 'belumWaktunya', -- 'belumWaktunya', 'belumDilaporkan', 'sudahDiminum', 'terlewat'
  photo_path TEXT, -- Menyimpan path foto bukti minum obat
  notes TEXT, -- Menyimpan catatan keluhan pasien
  reported_at TIMESTAMP WITH TIME ZONE, -- Waktu ketika pasien melapor minum obat
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Aktifkan RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;

-- 6. Buat ulang Fungsi handle_new_user yang menyalin kolom phone dari Auth Metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, role, phone, perawat_id, clinic_name, clinic_address)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'name', ''),
    new.email,
    CAST(COALESCE(new.raw_user_meta_data->>'role', 'pasien') AS user_role),
    new.raw_user_meta_data->>'phone',
    NULLIF(new.raw_user_meta_data->>'perawat_id', '')::uuid,
    COALESCE(new.raw_user_meta_data->>'clinic_name', 'Puskesmas Kecamatan'),
    COALESCE(new.raw_user_meta_data->>'clinic_address', 'Jl. Kesehatan No. 123')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- 7. KEBIJAKAN KEAMANAN RLS (Row Level Security) - BEBAS REKURSI MELINGKAR
-- ==============================================================================

-- A. Kebijakan untuk Profiles
-- 1. Semua user login bisa melihat profilnya sendiri ATAU perawat bisa melihat profil pasiennya
CREATE POLICY "Users can view own profile or perawat can view their pasiens" ON public.profiles
  FOR SELECT USING (
    auth.uid() = id OR 
    auth.uid() = perawat_id
  );

-- 2. Mengizinkan user baru menyisipkan profilnya sendiri saat register (untuk tempClient/RLS bypass)
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. Mengizinkan user mengupdate profilnya sendiri atau perawat pendamping mengupdate profil pasiennya
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (
    auth.uid() = id OR 
    auth.uid() = perawat_id
  );

-- B. Kebijakan untuk Medications
-- 1. Pasien bisa melihat obatnya sendiri. Perawat bisa melihat obat pasien pendampingnya.
CREATE POLICY "Users can view their own medications and perawat can view them" ON public.medications
  FOR SELECT USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = user_id AND perawat_id = auth.uid())
  );

-- 2. Pasien dan Perawat yang berwenang bisa menambahkan jadwal obat (untuk default meds RLS bypass)
CREATE POLICY "Users can insert medications" ON public.medications
  FOR INSERT WITH CHECK (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = user_id AND perawat_id = auth.uid())
  );

-- 3. Pasien dan Perawat yang berwenang bisa mengupdate status jadwal obat
CREATE POLICY "Users can update medications" ON public.medications
  FOR UPDATE USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = user_id AND perawat_id = auth.uid())
  );

-- 4. Pasien dan Perawat yang berwenang bisa menghapus jadwal obat
CREATE POLICY "Users can delete medications" ON public.medications
  FOR DELETE USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = user_id AND perawat_id = auth.uid())
  );

-- ==============================================================================
-- 8. INDEX PERFORMA
-- Dibutuhkan agar query checklist mingguan (filter created_at >= Senin) dan
-- query RLS EXISTS (perawat_id) tidak melakukan full-table scan.
-- ==============================================================================

-- Index komposit untuk getMedicationsThisWeek: user_id + created_at
CREATE INDEX IF NOT EXISTS idx_medications_user_created
  ON public.medications(user_id, created_at DESC);

-- Index untuk relasi perawat-pasien (dipakai di RLS EXISTS & getDaftarPasienKu)
CREATE INDEX IF NOT EXISTS idx_profiles_perawat_id
  ON public.profiles(perawat_id);

-- Dokter can view patients they are assigned to (same structure as perawat)
-- The existing RLS policies already cover dokter since they use the same perawat_id foreign key

-- ==============================================================================
-- 9. KEBIJAKAN DELETE PROFILES (Mengizinkan Perawat Menghapus Pasien)
-- ==============================================================================
CREATE POLICY "Perawat can delete their own pasiens" ON public.profiles
  FOR DELETE USING (
    auth.uid() = perawat_id
  );
