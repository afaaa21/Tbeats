-- ==============================================================================
-- TBEATS PATCH - Jalankan di Supabase SQL Editor
-- PENTING: Jalankan dalam 2 tahap terpisah (2x klik Run)
-- ==============================================================================

-- ╔══════════════════════════════════════════════════════╗
-- ║  TAHAP 1: Jalankan ini dulu, klik RUN               ║
-- ╚══════════════════════════════════════════════════════╝

ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'dokter';

-- ============================================================
-- Setelah TAHAP 1 berhasil, hapus baris di atas,
-- lalu paste dan jalankan TAHAP 2 di bawah ini:
-- ============================================================

-- ╔══════════════════════════════════════════════════════╗
-- ║  TAHAP 2: Jalankan ini setelah Tahap 1 berhasil     ║
-- ╚══════════════════════════════════════════════════════╝

-- Tambah kolom yang mungkin belum ada di profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS clinic_name TEXT DEFAULT 'Puskesmas Kecamatan';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS clinic_address TEXT DEFAULT 'Jl. Kesehatan No. 123';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS registration_no TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS start_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS duration_months INTEGER DEFAULT 6;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phase TEXT DEFAULT 'Intensif';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS dokter_name TEXT;

-- Hapus dan buat ulang trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE FUNCTION public.handle_new_user()
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
EXCEPTION WHEN others THEN
  RAISE LOG 'handle_new_user error: %', SQLERRM;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Index performa
CREATE INDEX IF NOT EXISTS idx_medications_user_created
  ON public.medications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_profiles_perawat_id
  ON public.profiles(perawat_id);

-- ╔══════════════════════════════════════════════════════╗
-- ║  TAHAP 3: Perbaiki profil yang hilang (WAJIB)       ║
-- ║  Jalankan ini setelah Tahap 2 berhasil              ║
-- ╚══════════════════════════════════════════════════════╝

-- Buat profil untuk semua user yang sudah ada di auth.users
-- tapi belum punya baris di profiles (trigger lama yang gagal)
INSERT INTO public.profiles (id, name, email, role, clinic_name, clinic_address)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'name', u.email),
  u.email,
  CAST(COALESCE(u.raw_user_meta_data->>'role', 'perawat') AS user_role),
  COALESCE(u.raw_user_meta_data->>'clinic_name', 'Puskesmas Kecamatan'),
  COALESCE(u.raw_user_meta_data->>'clinic_address', 'Jl. Kesehatan No. 123')
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- ╔══════════════════════════════════════════════════════╗
-- ║  TAHAP 4: Tambah RLS policy untuk perawat (WAJIB)   ║
-- ║  Jalankan ini setelah Tahap 3 berhasil              ║
-- ╚══════════════════════════════════════════════════════╝

-- RLS: profiles
-- Perawat bisa insert profil pasien baru (upsert dari kode)
DROP POLICY IF EXISTS "perawat_insert_patient_profile" ON public.profiles;
CREATE POLICY "perawat_insert_patient_profile"
ON public.profiles FOR INSERT
WITH CHECK (
  id = auth.uid()
  OR perawat_id = auth.uid()
);

-- Perawat bisa baca profil pasien mereka sendiri
DROP POLICY IF EXISTS "perawat_select_patient_profiles" ON public.profiles;
CREATE POLICY "perawat_select_patient_profiles"
ON public.profiles FOR SELECT
USING (
  id = auth.uid()
  OR perawat_id = auth.uid()
);

-- Perawat bisa update profil pasien mereka
DROP POLICY IF EXISTS "perawat_update_patient_profiles" ON public.profiles;
CREATE POLICY "perawat_update_patient_profiles"
ON public.profiles FOR UPDATE
USING (
  id = auth.uid()
  OR perawat_id = auth.uid()
)
WITH CHECK (
  id = auth.uid()
  OR perawat_id = auth.uid()
);

-- RLS: medications
-- Pasien bisa baca/tulis obat sendiri, perawat bisa baca/tulis obat pasien mereka
DROP POLICY IF EXISTS "user_or_perawat_select_medications" ON public.medications;
CREATE POLICY "user_or_perawat_select_medications"
ON public.medications FOR SELECT
USING (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = medications.user_id
      AND profiles.perawat_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "user_or_perawat_insert_medications" ON public.medications;
CREATE POLICY "user_or_perawat_insert_medications"
ON public.medications FOR INSERT
WITH CHECK (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = medications.user_id
      AND profiles.perawat_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "user_or_perawat_update_medications" ON public.medications;
CREATE POLICY "user_or_perawat_update_medications"
ON public.medications FOR UPDATE
USING (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = medications.user_id
      AND profiles.perawat_id = auth.uid()
  )
)
WITH CHECK (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = medications.user_id
      AND profiles.perawat_id = auth.uid()
  )
);
