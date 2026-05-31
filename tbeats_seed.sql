-- ==============================================================================
-- TBEATS - SEED DATABASE REALISTIK
-- ==============================================================================
-- CARA PAKAI:
--   1. Jalankan update_supabase.sql lebih dulu (buat tabel, RLS, trigger)
--   2. Jalankan file ini di Supabase SQL Editor
--
-- AKUN LOGIN (SEMUA PASSWORD: TBeats2026!)
-- ┌─────────────────────────────────┬──────────────────────────┬─────────────────┐
-- │ Nama                            │ Email                    │ Role & Perawat  │
-- ├─────────────────────────────────┼──────────────────────────┼─────────────────┤
-- │ Ns. Dewi Lestari                │ ns.dewi@tbeats.app       │ Perawat         │
-- │ Ns. Budi Hartono                │ ns.budi@tbeats.app       │ Perawat         │
-- │ Budi Santoso  (90% kepatuhan)   │ budi.s@tbeats.app        │ Pasien / Dewi   │
-- │ Ani Rahayu    (55% KRITIS)      │ ani.r@tbeats.app         │ Pasien / Dewi   │
-- │ Rudi Hermanto (75% Lanjutan)    │ rudi.h@tbeats.app        │ Pasien / Dewi   │
-- │ Siti Nurhaliza (85% baru)       │ siti.n@tbeats.app        │ Pasien / Dewi   │
-- │ Agus Setiawan (88%)             │ agus.s@tbeats.app        │ Pasien / Budi   │
-- │ Linda Kusuma  (92% Lanjutan)    │ linda.k@tbeats.app       │ Pasien / Budi   │
-- │ Hendra Wijaya (60% KRITIS)      │ hendra.w@tbeats.app      │ Pasien / Budi   │
-- └─────────────────────────────────┴──────────────────────────┴─────────────────┘
-- ==============================================================================

DO $$
DECLARE
  -- ─── UUID Perawat ────────────────────────────────────────────────────────────
  dewi_id  UUID := 'aa000001-aa00-4000-8000-000000000000';
  budiN_id UUID := 'aa000002-aa00-4000-8000-000000000000';

  -- ─── UUID Pasien ─────────────────────────────────────────────────────────────
  p1 UUID := 'bb000001-bb00-4000-8000-000000000000'; -- Budi Santoso   (Dewi, 90%)
  p2 UUID := 'bb000002-bb00-4000-8000-000000000000'; -- Ani Rahayu     (Dewi, 55% KRITIS)
  p3 UUID := 'bb000003-bb00-4000-8000-000000000000'; -- Rudi Hermanto  (Dewi, 75% Lanjutan)
  p4 UUID := 'bb000004-bb00-4000-8000-000000000000'; -- Siti Nurhaliza (Dewi, 85% baru)
  p5 UUID := 'bb000005-bb00-4000-8000-000000000000'; -- Agus Setiawan  (Budi, 88%)
  p6 UUID := 'bb000006-bb00-4000-8000-000000000000'; -- Linda Kusuma   (Budi, 92% Lanjutan)
  p7 UUID := 'bb000007-bb00-4000-8000-000000000000'; -- Hendra Wijaya  (Budi, 60% KRITIS)

  enc_pw TEXT;
  d      INT;     -- hari mundur dari hari ini (0 = hari ini)
  m      INT;     -- indeks obat
  r      FLOAT;   -- random value untuk menentukan status
  sv     TEXT;    -- status value
  rt     TIMESTAMPTZ; -- reported_at

  -- ─── Data Obat Fase Intensif (4 obat) ────────────────────────────────────────
  nm TEXT[] := ARRAY['Isoniazid', 'Rifampisin', 'Pirazinamid', 'Etambutol'];
  ds TEXT[] := ARRAY['300mg',     '450mg',      '1500mg',      '750mg'];
  jm TEXT[] := ARRAY['07:00',     '07:30',      '08:00',       '20:00'];
  am TEXT[] := ARRAY['Sebelum makan', 'Sebelum makan', 'Sesudah makan', 'Sesudah makan'];

  -- ─── Data Obat Fase Lanjutan (2 obat) ────────────────────────────────────────
  lnm TEXT[] := ARRAY['Isoniazid', 'Rifampisin'];
  lds TEXT[] := ARRAY['300mg',     '450mg'];
  ljm TEXT[] := ARRAY['07:00',     '07:30'];
  lam TEXT[] := ARRAY['Sebelum makan', 'Sebelum makan'];

  total_meds INT;

BEGIN
  enc_pw := crypt('TBeats2026!', gen_salt('bf'));

  -- ============================================================================
  -- BERSIHKAN DATA LAMA
  -- ============================================================================
  DELETE FROM public.medications;
  DELETE FROM auth.identities
    WHERE user_id IN (SELECT id FROM auth.users WHERE email LIKE '%@tbeats.app');
  DELETE FROM auth.users WHERE email LIKE '%@tbeats.app';
  -- profiles akan terhapus otomatis via ON DELETE CASCADE dari auth.users

  -- ============================================================================
  -- AUTH USERS: PERAWAT
  -- ============================================================================
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES
    (
      '00000000-0000-0000-0000-000000000000', dewi_id,
      'authenticated', 'authenticated', 'ns.dewi@tbeats.app', enc_pw, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"name":"Ns. Dewi Lestari","role":"perawat","phone":"+62811001001"}'::jsonb,
      now(), now(), '', '', '', ''
    ),
    (
      '00000000-0000-0000-0000-000000000000', budiN_id,
      'authenticated', 'authenticated', 'ns.budi@tbeats.app', enc_pw, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"name":"Ns. Budi Hartono","role":"perawat","phone":"+62811001002"}'::jsonb,
      now(), now(), '', '', '', ''
    );

  -- Identities perawat (diperlukan agar bisa login)
  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), dewi_id,  dewi_id::TEXT,
     ('{"sub":"' || dewi_id  || '","email":"ns.dewi@tbeats.app"}')::jsonb, 'email', now(), now(), now()),
    (gen_random_uuid(), budiN_id, budiN_id::TEXT,
     ('{"sub":"' || budiN_id || '","email":"ns.budi@tbeats.app"}')::jsonb, 'email', now(), now(), now());

  -- Update profiles perawat (trigger sudah insert basic, tambahkan info klinik)
  UPDATE public.profiles SET
    phone          = '+62811001001',
    clinic_name    = 'Puskesmas Kecamatan Tebet',
    clinic_address = 'Jl. Dr. Saharjo No.87, Tebet, Jakarta Selatan',
    updated_at     = now()
  WHERE id = dewi_id;

  UPDATE public.profiles SET
    phone          = '+62811001002',
    clinic_name    = 'Puskesmas Kelurahan Menteng',
    clinic_address = 'Jl. Cik Ditiro No.12, Menteng, Jakarta Pusat',
    updated_at     = now()
  WHERE id = budiN_id;

  -- ============================================================================
  -- AUTH USERS: PASIEN
  -- ============================================================================
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES
    -- ── Pasien Ns. Dewi Lestari ───────────────────────────────────────────────
    ('00000000-0000-0000-0000-000000000000', p1, 'authenticated', 'authenticated',
     'budi.s@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Budi Santoso","role":"pasien","phone":"+62812100001","perawat_id":"' || dewi_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    ('00000000-0000-0000-0000-000000000000', p2, 'authenticated', 'authenticated',
     'ani.r@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Ani Rahayu","role":"pasien","phone":"+62813200002","perawat_id":"' || dewi_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    ('00000000-0000-0000-0000-000000000000', p3, 'authenticated', 'authenticated',
     'rudi.h@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Rudi Hermanto","role":"pasien","phone":"+62814300003","perawat_id":"' || dewi_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    ('00000000-0000-0000-0000-000000000000', p4, 'authenticated', 'authenticated',
     'siti.n@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Siti Nurhaliza","role":"pasien","phone":"+62815400004","perawat_id":"' || dewi_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    -- ── Pasien Ns. Budi Hartono ───────────────────────────────────────────────
    ('00000000-0000-0000-0000-000000000000', p5, 'authenticated', 'authenticated',
     'agus.s@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Agus Setiawan","role":"pasien","phone":"+62816500005","perawat_id":"' || budiN_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    ('00000000-0000-0000-0000-000000000000', p6, 'authenticated', 'authenticated',
     'linda.k@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Linda Kusuma","role":"pasien","phone":"+62817600006","perawat_id":"' || budiN_id || '"}')::jsonb,
     now(), now(), '', '', '', ''),

    ('00000000-0000-0000-0000-000000000000', p7, 'authenticated', 'authenticated',
     'hendra.w@tbeats.app', enc_pw, now(),
     '{"provider":"email","providers":["email"]}'::jsonb,
     ('{"name":"Hendra Wijaya","role":"pasien","phone":"+62818700007","perawat_id":"' || budiN_id || '"}')::jsonb,
     now(), now(), '', '', '', '');

  -- Identities pasien (satu query dengan SELECT)
  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  SELECT
    gen_random_uuid(),
    u.id,
    u.id::TEXT,
    ('{"sub":"' || u.id || '","email":"' || u.email || '"}')::jsonb,
    'email', now(), now(), now()
  FROM auth.users u
  WHERE u.email LIKE '%@tbeats.app'
    AND u.id NOT IN (SELECT user_id FROM auth.identities);

  -- ============================================================================
  -- UPDATE PROFILES PASIEN: Data Klinis Lengkap
  -- (trigger auto-insert data dasar, kita UPDATE kolom klinis)
  -- ============================================================================

  -- P1: Budi Santoso — Intensif, sudah 45 hari, kepatuhan BAIK
  UPDATE public.profiles SET
    registration_no = 'TBC-2026-038291',
    start_date      = now() - INTERVAL '45 days',
    duration_months = 6,
    phase           = 'Intensif',
    dokter_name     = 'Dr. Ahmad Fauzi, Sp.P',
    clinic_name     = 'Puskesmas Kecamatan Tebet',
    clinic_address  = 'Jl. Dr. Saharjo No.87, Tebet, Jakarta Selatan',
    updated_at      = now()
  WHERE id = p1;

  -- P2: Ani Rahayu — Intensif, 20 hari, kepatuhan KRITIS
  UPDATE public.profiles SET
    registration_no = 'TBC-2026-041852',
    start_date      = now() - INTERVAL '20 days',
    duration_months = 6,
    phase           = 'Intensif',
    dokter_name     = 'Dr. Ahmad Fauzi, Sp.P',
    clinic_name     = 'Puskesmas Kecamatan Tebet',
    clinic_address  = 'Jl. Dr. Saharjo No.87, Tebet, Jakarta Selatan',
    updated_at      = now()
  WHERE id = p2;

  -- P3: Rudi Hermanto — Lanjutan (120 hari), kepatuhan SEDANG
  UPDATE public.profiles SET
    registration_no = 'TBC-2025-097634',
    start_date      = now() - INTERVAL '120 days',
    duration_months = 6,
    phase           = 'Lanjutan',
    dokter_name     = 'Dr. Ahmad Fauzi, Sp.P',
    clinic_name     = 'Puskesmas Kecamatan Tebet',
    clinic_address  = 'Jl. Dr. Saharjo No.87, Tebet, Jakarta Selatan',
    updated_at      = now()
  WHERE id = p3;

  -- P4: Siti Nurhaliza — Intensif, baru mulai 7 hari
  UPDATE public.profiles SET
    registration_no = 'TBC-2026-052103',
    start_date      = now() - INTERVAL '7 days',
    duration_months = 6,
    phase           = 'Intensif',
    dokter_name     = 'Dr. Ahmad Fauzi, Sp.P',
    clinic_name     = 'Puskesmas Kecamatan Tebet',
    clinic_address  = 'Jl. Dr. Saharjo No.87, Tebet, Jakarta Selatan',
    updated_at      = now()
  WHERE id = p4;

  -- P5: Agus Setiawan — Intensif, 60 hari, kepatuhan BAGUS
  UPDATE public.profiles SET
    registration_no = 'TBC-2026-019847',
    start_date      = now() - INTERVAL '60 days',
    duration_months = 6,
    phase           = 'Intensif',
    dokter_name     = 'Dr. Citra Dewi, Sp.P',
    clinic_name     = 'Puskesmas Kelurahan Menteng',
    clinic_address  = 'Jl. Cik Ditiro No.12, Menteng, Jakarta Pusat',
    updated_at      = now()
  WHERE id = p5;

  -- P6: Linda Kusuma — Lanjutan (150 hari), kepatuhan TERBAIK
  UPDATE public.profiles SET
    registration_no = 'TBC-2025-088421',
    start_date      = now() - INTERVAL '150 days',
    duration_months = 6,
    phase           = 'Lanjutan',
    dokter_name     = 'Dr. Citra Dewi, Sp.P',
    clinic_name     = 'Puskesmas Kelurahan Menteng',
    clinic_address  = 'Jl. Cik Ditiro No.12, Menteng, Jakarta Pusat',
    updated_at      = now()
  WHERE id = p6;

  -- P7: Hendra Wijaya — Intensif, baru 10 hari, kepatuhan KRITIS
  UPDATE public.profiles SET
    registration_no = 'TBC-2026-027359',
    start_date      = now() - INTERVAL '10 days',
    duration_months = 6,
    phase           = 'Intensif',
    dokter_name     = 'Dr. Citra Dewi, Sp.P',
    clinic_name     = 'Puskesmas Kelurahan Menteng',
    clinic_address  = 'Jl. Cik Ditiro No.12, Menteng, Jakarta Pusat',
    updated_at      = now()
  WHERE id = p7;

  -- ============================================================================
  -- MEDICATIONS HISTORY
  -- Strategi distribusi status per pasien:
  --   d=0         = hari ini → belum lapor / sudah lapor pagi
  --   d=1..N      = hari lalu → status acak sesuai profil kepatuhan tiap pasien
  --
  -- Status: sudahDiminum | terlambat | terlewat | belumWaktunya | belumDilaporkan
  -- ============================================================================

  -- ── P1: BUDI SANTOSO — 45 hari × 4 obat Intensif — target ~90% ─────────────
  FOR d IN 0..44 LOOP
    FOR m IN 1..4 LOOP
      IF d = 0 THEN
        -- Pagi sudah lapor 2 obat pertama, 2 terakhir (malam) belum waktunya
        sv := CASE WHEN m <= 2 THEN 'belumDilaporkan' ELSE 'belumWaktunya' END;
        rt := NULL;
      ELSE
        r := random();
        IF r < 0.87 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 25)::INT);
        ELSIF r < 0.95 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 9 + m, mins => (random() * 45)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p1, nm[m], ds[m], jm[m], am[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P2: ANI RAHAYU — 20 hari × 4 obat Intensif — target ~55% KRITIS ────────
  FOR d IN 0..19 LOOP
    FOR m IN 1..4 LOOP
      IF d = 0 THEN
        sv := 'terlewat'; rt := NULL; -- Hari ini sudah terlewat → tampil sebagai KRITIS
      ELSE
        r := random();
        IF r < 0.50 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 20)::INT);
        ELSIF r < 0.62 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 11 + m, mins => (random() * 40)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p2, nm[m], ds[m], jm[m], am[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P3: RUDI HERMANTO — 30 hari × 2 obat Lanjutan — target ~75% ─────────────
  FOR d IN 0..29 LOOP
    FOR m IN 1..2 LOOP
      IF d = 0 THEN
        sv := 'belumDilaporkan'; rt := NULL;
      ELSE
        r := random();
        IF r < 0.73 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 20)::INT);
        ELSIF r < 0.84 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 9 + m, mins => (random() * 40)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p3, lnm[m], lds[m], ljm[m], lam[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P4: SITI NURHALIZA — 7 hari × 4 obat Intensif — target ~85% (baru) ──────
  FOR d IN 0..6 LOOP
    FOR m IN 1..4 LOOP
      IF d = 0 THEN
        sv := CASE WHEN m = 1 THEN 'belumDilaporkan' ELSE 'belumWaktunya' END;
        rt := NULL;
      ELSE
        r := random();
        IF r < 0.82 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 20)::INT);
        ELSIF r < 0.93 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 9 + m, mins => (random() * 30)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p4, nm[m], ds[m], jm[m], am[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P5: AGUS SETIAWAN — 30 hari × 4 obat Intensif — target ~88% ─────────────
  FOR d IN 0..29 LOOP
    FOR m IN 1..4 LOOP
      IF d = 0 THEN
        sv := CASE WHEN m <= 2 THEN 'belumDilaporkan' ELSE 'belumWaktunya' END;
        rt := NULL;
      ELSE
        r := random();
        IF r < 0.85 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 25)::INT);
        ELSIF r < 0.94 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 9 + m, mins => (random() * 30)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p5, nm[m], ds[m], jm[m], am[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P6: LINDA KUSUMA — 30 hari × 2 obat Lanjutan — target ~92% TERBAIK ──────
  FOR d IN 0..29 LOOP
    FOR m IN 1..2 LOOP
      IF d = 0 THEN
        -- Linda sudah lapor pagi ini, menunjukkan pasien paling patuh
        sv := 'sudahDiminum';
        rt := CURRENT_DATE::TIMESTAMPTZ + make_interval(hours => 7, mins => 5 + m);
      ELSE
        r := random();
        IF r < 0.91 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 15)::INT);
        ELSIF r < 0.97 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 9, mins => (random() * 30)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p6, lnm[m], lds[m], ljm[m], lam[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ── P7: HENDRA WIJAYA — 10 hari × 4 obat Intensif — target ~60% KRITIS ──────
  FOR d IN 0..9 LOOP
    FOR m IN 1..4 LOOP
      IF d = 0 OR d = 1 THEN
        -- 2 hari berturut-turut terlewat → pasti muncul sebagai KRITIS di dashboard
        sv := 'terlewat'; rt := NULL;
      ELSE
        r := random();
        IF r < 0.57 THEN
          sv := 'sudahDiminum';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 7 + m, mins => (random() * 20)::INT);
        ELSIF r < 0.68 THEN
          sv := 'terlambat';
          rt := (CURRENT_DATE - d)::TIMESTAMPTZ
                + make_interval(hours => 11 + m, mins => (random() * 40)::INT);
        ELSE
          sv := 'terlewat'; rt := NULL;
        END IF;
      END IF;

      INSERT INTO public.medications
        (user_id, nama_obat, takaran, jam_minum, aturan_makan, status, reported_at, created_at, updated_at)
      VALUES
        (p7, nm[m], ds[m], jm[m], am[m], sv, rt,
         (CURRENT_DATE - d)::TIMESTAMPTZ + make_interval(hours => 6), now());
    END LOOP;
  END LOOP;

  -- ============================================================================
  -- RINGKASAN
  -- ============================================================================
  SELECT COUNT(*) INTO total_meds FROM public.medications;

  RAISE NOTICE '';
  RAISE NOTICE '╔══════════════════════════════════════════════════════╗';
  RAISE NOTICE '║           TBEATS SEED BERHASIL DIJALANKAN           ║';
  RAISE NOTICE '╠══════════════════════════════════════════════════════╣';
  RAISE NOTICE '║ Perawat        : 2 akun                             ║';
  RAISE NOTICE '║ Pasien         : 7 akun                             ║';
  RAISE NOTICE '║ Total obat     : % entri                       ║', lpad(total_meds::TEXT, 4, ' ');
  RAISE NOTICE '║ Password semua : TBeats2026!                        ║';
  RAISE NOTICE '╠══════════════════════════════════════════════════════╣';
  RAISE NOTICE '║ Dashboard Dewi : 4 pasien (2 kritis, 2 aman)       ║';
  RAISE NOTICE '║ Dashboard Budi : 3 pasien (1 kritis, 2 aman)       ║';
  RAISE NOTICE '╚══════════════════════════════════════════════════════╝';

END $$;

-- ============================================================================
-- VERIFIKASI HASIL
-- ============================================================================
SELECT
  p.role,
  p.name,
  p.email,
  p.phase,
  p.registration_no,
  COUNT(m.id)                                                        AS total_obat,
  COUNT(m.id) FILTER (WHERE m.status = 'sudahDiminum')              AS diminum,
  COUNT(m.id) FILTER (WHERE m.status = 'terlambat')                 AS terlambat,
  COUNT(m.id) FILTER (WHERE m.status = 'terlewat')                  AS terlewat,
  ROUND(
    COUNT(m.id) FILTER (WHERE m.status = 'sudahDiminum')::NUMERIC /
    NULLIF(
      COUNT(m.id) FILTER (WHERE m.status IN ('sudahDiminum','terlewat')),
    0) * 100
  , 1) AS kepatuhan_pct
FROM public.profiles p
LEFT JOIN public.medications m ON m.user_id = p.id
GROUP BY p.role, p.name, p.email, p.phase, p.registration_no
ORDER BY p.role DESC, kepatuhan_pct ASC NULLS LAST;
