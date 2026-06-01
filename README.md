# 🩺 TBeats
> **"Pendamping Setia Perjalanan Pengobatan TBC demi Kesembuhan Paripurna"**

[![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Material 3](https://img.shields.io/badge/Material--3-Design-7D5260?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#)

---

## 🎯 Tentang TBeats

**TBC (Tuberkulosis)** adalah salah satu penyakit menular dengan masa pengobatan terlama — minimal 6 bulan tanpa putus. Kegagalan atau ketidakteraturan minum obat dapat memicu resistensi obat (*Multi-Drug Resistant TB* / MDR-TB) yang berakibat fatal.

**TBeats** hadir sebagai solusi digital berbasis mobile yang dirancang khusus untuk menjembatani kesenjangan komunikasi antara **Pasien TBC** dan **Tenaga Medis (Perawat)**. Melalui sistem pelaporan minum obat harian berbasis foto verifikasi, pemantauan tingkat kepatuhan secara *real-time*, dan pencatatan riwayat pengobatan yang dinamis, TBeats memastikan setiap dosis obat dikonsumsi tepat waktu.

---

## 🛠️ Tech Stack & Library

| Kategori | Library / Tool | Keterangan |
|---|---|---|
| **Core Framework** | [Flutter SDK](https://flutter.dev) `>=3.0.0 <4.0.0` | Mobile app framework utama |
| **Language** | Dart | Bahasa pemrograman utama |
| **Backend & Auth** | [Supabase Flutter](https://supabase.com) `^2.12.4` | Database, autentikasi, dan API |
| **Environment Config** | `flutter_dotenv` `^6.0.1` | Manajemen `.env` untuk Supabase credentials |
| **Design System** | Google Material 3 | UI guidelines & komponen visual |
| **Font** | `google_fonts` `^6.2.1` | Font `Plus Jakarta Sans` |
| **Visualisasi Progres** | `percent_indicator` `^4.2.3` | Grafik kepatuhan interaktif |
| **Kamera & Galeri** | `image_picker` `^1.0.4` | Foto bukti minum obat |
| **Penyimpanan Lokal** | `shared_preferences` `^2.2.2` | Persistensi data sesi lokal |
| **Lokalisasi Waktu** | `intl` `^0.18.1` | Format tanggal & kalender Indonesia |

---

## 📁 Struktur Proyek (Feature-First Architecture)

```text
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart         # Inisialisasi & konfigurasi Supabase client
│   └── theme/
│       └── app_theme.dart               # Design System: palet warna Material 3 & tipografi
├── data/
│   └── app_data.dart                    # Data dummy / seed lokal (fallback)
├── models/
│   └── models.dart                      # Model inti: Patient, Medication, MedicationHistory
├── service/
│   └── api_service.dart                 # Seluruh integrasi Supabase (auth, CRUD, query)
├── widgets/
│   └── medication_icon.dart             # Widget ikon obat yang dapat digunakan ulang
├── features/
│   ├── auth/
│   │   └── presentation/pages/
│   │       ├── login_page.dart          # Halaman login (perawat & pasien)
│   │       └── register_page.dart       # Halaman registrasi perawat
│   ├── onboarding/
│   │   └── presentation/pages/
│   │       └── onboarding_page.dart     # Halaman splash / onboarding awal
│   ├── patient/
│   │   └── presentation/pages/
│   │       ├── patient_main_wrapper.dart  # Bottom nav wrapper pasien (4 tab)
│   │       ├── beranda_page.dart          # Dashboard: jadwal hari ini & info perawat
│   │       ├── jadwal_page.dart           # Daftar jadwal obat aktif
│   │       ├── lapor_page.dart            # Laporan minum obat + foto verifikasi
│   │       ├── riwayat_page.dart          # Riwayat kepatuhan mingguan & bulanan
│   │       ├── profil_page.dart           # Profil pasien
│   │       └── tambah_obat_page.dart      # Form tambah jadwal obat
│   └── nurse/
│       ├── screens/
│       │   ├── nurse_dashboard_screen.dart   # Dashboard: daftar pasien
│       │   ├── nurse_profile_screen.dart     # Profil perawat
│       │   ├── add_patient_screen.dart       # Form pendaftaran pasien baru
│       │   ├── patient_detail_screen.dart    # Detail pasien & rekam medis
│       │   ├── report_screen.dart            # Daftar laporan pasien
│       │   └── report_detail_screen.dart     # Detail laporan harian
│       └── widgets/
│           ├── patient_card.dart             # Kartu ringkasan pasien
│           └── success_modal.dart            # Modal konfirmasi berhasil
└── main.dart                                 # Entry point aplikasi
```

---

## ✨ Fitur Utama

### 👩‍⚕️ Perawat
| Fitur | Deskripsi |
|---|---|
| **Register & Login** | Registrasi akun perawat dengan data klinik |
| **Manajemen Pasien** | Daftar, pantau, dan hapus pasien |
| **Detail Pasien** | Lihat rekam medis, jadwal obat, dan kepatuhan pasien |
| **Tambah Obat Pasien** | Tambahkan jadwal obat untuk pasien tertentu |
| **Laporan Harian** | Pantau laporan minum obat lengkap dengan foto bukti |

### 🧑‍🦽 Pasien
| Fitur | Deskripsi |
|---|---|
| **Login** | Masuk dengan akun yang didaftarkan perawat |
| **Dashboard Beranda** | Jadwal obat hari ini, jam real-time, dan info perawat |
| **Jadwal Obat** | Daftar seluruh jadwal obat aktif |
| **Lapor Minum Obat** | Kirim laporan kepatuhan dengan foto verifikasi & catatan |
| **Riwayat Pengobatan** | Kepatuhan mingguan (checklist) & bulanan (kalender) |
| **Pilih Tahun Fleksibel** | Pop-up pilih tahun: chip daftar cepat atau input manual bebas |
| **Profil Pasien** | Lihat dan perbarui data profil pribadi |
| **Tambah Obat** | Daftarkan obat baru ke dalam jadwal pengobatan |

---

## ⚙️ Setup & Konfigurasi

### Prasyarat
- Flutter SDK `>=3.0.0`
- Akun [Supabase](https://supabase.com)

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/afaaa21/Tbeats.git
   cd Tbeats
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Buat file `.env`** di root project
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 🗄️ Backend (Supabase)

TBeats menggunakan **Supabase** sebagai backend-as-a-service dengan:
- **Authentication** — Sign up & sign in berbasis email/password
- **PostgreSQL Database** — Tabel `profiles`, `medications`, `medication_history`
- **Row Level Security (RLS)** — Akses data dibatasi per role (`perawat` / `pasien`)

### Ringkasan API Service

| Method | Role | Deskripsi |
|---|---|---|
| `registerPerawat()` | Perawat | Registrasi akun perawat |
| `login()` | Semua | Login universal (deteksi role otomatis) |
| `daftarkanPasien()` | Perawat | Daftarkan pasien baru |
| `getDaftarPasienKu()` | Perawat | Ambil daftar pasien milik perawat |
| `tambahJadwalObat()` | Pasien | Tambah jadwal obat |
| `getJadwalObatKu()` | Pasien | Ambil jadwal obat aktif |
| `getMedicationsThisWeek()` | Pasien | Data obat minggu ini untuk checklist |
| `getHistoryMedication()` | Pasien | Riwayat kepatuhan minum obat |
| `updateMedicationStatus()` | Pasien | Update status laporan obat |
| `getProfileInfo()` | Semua | Ambil profil pengguna aktif |
| `updateProfile()` | Semua | Perbarui data profil |
| `hapusPasien()` | Perawat | Hapus pasien beserta data obatnya |
| `logout()` | Semua | Logout dari sesi aktif |

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **MIT**.
