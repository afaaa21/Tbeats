# 🩺 TBeats
> **"Pendamping Setia Perjalanan Pengobatan TBC demi Kesembuhan Paripurna"**

[![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Material 3](https://img.shields.io/badge/Material--3-Approved-7D5260?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#)

---

## 🎯 Tentang TBeats (The "Hook")

**TBC (Tuberkulosis)** adalah salah satu penyakit menular dengan masa pengobatan terlama—minimal 6 bulan tanpa putus. Kegagalan atau ketidakteraturan minum obat dapat memicu resistensi obat (*Multi-Drug Resistant TB* / MDR-TB) yang berakibat fatal. 

**TBeats** hadir sebagai solusi digital berbasis mobile yang dirancang khusus untuk menjembatani kesenjangan komunikasi antara **Pasien TBC** dan **Tenaga Medis (Perawat)**. Melalui sistem pelaporan minum obat harian berbasis foto verifikasi, pemantauan tingkat kepatuhan secara *real-time*, dan pencatatan riwayat pengobatan yang dinamis, TBeats memastikan setiap dosis obat dikonsumsi tepat waktu.

Aplikasi ini mengubah pengobatan TBC yang melelahkan menjadi sebuah perjalanan kolaboratif yang teratur, terpantau, aman, dan penuh dukungan hingga kesembuhan total tercapai.

---

## 🛠️ Tech Stack & Library

Aplikasi ini dibangun menggunakan ekosistem pengembangan mobile modern:

*   **Core Framework:** [Flutter SDK](https://flutter.dev) (versi `>=3.0.0 <4.0.0`) dengan **Dart**
*   **Design System:** Google Material 3 UI Guidelines
*   **Font Utama:** `Plus Jakarta Sans` (diintegrasikan via `google_fonts`) untuk keterbacaan tinggi dan tampilan yang premium.
*   **Penyimpanan Lokal (Local State):** `shared_preferences` untuk persistensi sesi login dan pelaporan.
*   **Visualisasi Progres:** `percent_indicator` untuk grafik kepatuhan interaktif.
*   **Integrasi Perangkat:** `image_picker` untuk akses kamera/galeri sebagai bukti minum obat.
*   **Lokalisasi Waktu:** `intl` untuk format tanggal, jam, dan kalender pengobatan Indonesia.

---

## 📁 Struktur Proyek (Clean & Feature-First Architecture)

TBeats diimplementasikan menggunakan arsitektur berbasis fitur (**Feature-First**) untuk memastikan skalabilitas kode, kemudahan kolaborasi tim, dan modularitas yang tinggi.

```text
lib/
├── core/
│   └── theme/
│       └── app_theme.dart       # Design System: Palet warna Material 3 & tipografi utama
├── data/
│   └── app_data.dart            # Mock/Dummy data (pasien, riwayat, rekam medis harian)
├── models/
│   └── models.dart              # Model data inti (Patient, Medication, MedicationHistory)
├── service/
│   └── api_service.dart         # Layanan API (siap digunakan untuk integrasi backend REST API)
├── widgets/
│   └── medication_icon.dart     # Widget reusable berupa ikon obat interaktif & dinamis
├── features/
│   ├── onboarding/              # Modul Pengenalan Aplikasi
│   │   └── presentation/pages/
│   │       └── onboarding_page.dart # 3-Slide onboarding animasi pembuka
│   ├── auth/                    # Modul Autentikasi & Registrasi
│   │   └── presentation/pages/
│   │       ├── login_page.dart    # Login Multi-Role (Pasien & Perawat) dengan loading state
│   │       └── register_page.dart # Pendaftaran Perawat medis baru
│   ├── patient/                 # Modul Pasien (Self-Reporting & Progress tracking)
│   │   └── presentation/pages/
│   │       ├── patient_main_wrapper.dart # Bottom Navigation bar pasien
│   │       ├── beranda_page.dart        # Dashboard utama pasien, ringkasan hari ini, donut chart kepatuhan 85%
│   │       ├── jadwal_page.dart         # Jadwal obat harian dikelompokkan berdasarkan status minum obat
│   │       ├── lapor_page.dart          # Formulir laporan minum obat dilengkapi fitur ambil bukti foto (kamera)
│   │       ├── riwayat_page.dart        # Log kepatuhan bulanan & checklist mingguan terperinci
│   │       ├── profil_page.dart         # Data klinis pasien, riwayat fase obat, & kontak darurat perawat
│   │       └── tambah_obat_page.dart    # Tambah resep obat tambahan secara mandiri
│   └── nurse/                   # Modul Perawat (Monitoring & Clinical Dashboard)
│       └── screens/
│           ├── nurse_dashboard_screen.dart # Dashboard pemantauan seluruh pasien aktif secara real-time
│           ├── add_patient_screen.dart     # Formulir registrasi pasien TBC baru (nomor register & fase pengobatan)
│           ├── nurse_profile_screen.dart   # Profil perawat medis & pengaturan keluar sesi
│           ├── patient_detail_screen.dart  # Deteksi detail klinis pasien, chart kepatuhan, & status log harian
│           ├── report_detail_screen.dart   # Lembar verifikasi & detail foto laporan minum obat pasien
│           └── report_screen.dart          # Log kepatuhan & rekapitulasi laporan minum obat seluruh pasien
└── main.dart                    # Entrypoint aplikasi Flutter
```

---

## 🔑 Akun Demo Login

Untuk memudahkan pengujian dan presentasi aplikasi tanpa harus melakukan setup database backend terlebih dahulu, gunakan akun demo berikut di halaman Login:

| Peran (Role) | Email Pengguna | Kata Sandi (Password) | Hak Akses & Fitur Utama |
| :--- | :--- | :--- | :--- |
| **Pasien (Patient)** | `pasien@email.com` | `12345678` | Mengisi laporan minum obat, melihat jadwal harian, melampirkan foto bukti minum obat, memantau skor kepatuhan pribadi (85%), serta riwayat bulanan. |
| **Perawat (Nurse)** | `perawat@email.com` | `12345678` | Memantau seluruh pasien, melakukan pendaftaran pasien baru, memverifikasi foto laporan minum obat harian, melihat grafik kepatuhan klinis masing-masing pasien. |

> [!NOTE]
> *Akun pasien dibuat secara eksklusif oleh perawat medis yang mendampinginya demi menjaga validitas data rekam medis pasien.*

---

## ✨ Fitur-Fitur yang Diimplementasikan

### 1. Sistem Onboarding Interaktif (3 Slide)
*   **Slide 1: Selamat Datang di TBeats** – Memperkenalkan visi aplikasi pendamping pengobatan.
*   **Slide 2: Pantau Setiap Langkah Pengobatan** – Edukasi pelaporan harian menggunakan foto bukti konsumsi obat.
*   **Slide 3: Sembuh Itu Perjalanan Bersama** – Menjelaskan integrasi langsung dengan pemantauan perawat medis.
*   *Navigasi praktis berupa tombol lewati cepat (Skip) dan tombol masuk.*

### 2. Autentikasi Cerdas (Multi-Role)
*   **Login Terpadu:** Sistem secara otomatis mendeteksi email untuk mengarahkan pengguna ke Portal Pasien atau Dashboard Perawat.
*   **UI Keamanan:** Form kata sandi dilengkapi fitur tampilkan/sembunyikan (*obscure password toggle*).
*   **Sistem Validasi:** Pesan kesalahan interaktif (warna merah di bawah kolom) dengan animasi transisi yang mulus.
*   **Simulasi API:** Memiliki *loading state* (CircularProgressIndicator) berdurasi `800ms` untuk memberikan impresi pengerjaan di balik layar.
*   **Registrasi Perawat:** Formulir registrasi terdedikasi untuk pendaftaran staf medis baru.

### 3. Portal Pasien (Patient Suite)
*   **Beranda Utama:**
    *   Sapaan personal dengan nama pasien, nomor registrasi TBC unik, dan nama perawat pendamping.
    *   **Donut Chart Kepatuhan:** Ringkasan statistik kepatuhan (85%) menggunakan visualisasi grafik persentase interaktif.
    *   **Quick Counter:** Statistik klasifikasi konsumsi obat (Tepat / Terlambat / Terlewat).
    *   **Jadwal Hari Ini:** Status obat berwarna-warni sesuai panduan medis (*Sudah Diminum*, *Terlambat*, *Terlewat*, *Belum Waktunya*).
*   **Modul Pelaporan (Lapor Minum Obat):**
    *   Integrasi kamera via `image_picker` untuk mengambil bukti fisik konsumsi obat secara langsung.
    *   Tampilan area bidik kamera dengan *corner bracket overlay* yang elegan.
    *   Formulir input catatan tambahan opsional (seperti efek samping: mual, pusing, dll).
    *   Dialog konfirmasi sukses pelaporan bermotif ilustrasi medis.
*   **Modul Jadwal & Riwayat:**
    *   Pengelompokan otomatis daftar obat harian berdasarkan waktu dan status konsumsi.
    *   **Weekly Checklist:** Tabel pelacakan kepatuhan mingguan (Senin–Minggu) dengan representasi warna indikatif.
    *   Log riwayat bulanan berdesain minimalis menggunakan representasi ikon obat dinamis.
*   **Detail Profil Klinis:**
    *   Informasi mendalam fase pengobatan aktif (misal: *Fase Intensif*), durasi pengobatan (misal: *6 Bulan*), serta tanggal mulai.
    *   **Integrasi Kontak:** Tombol panggil cepat untuk menghubungi perawat via telepon seluler.

### 4. Portal Perawat (Clinical Suite)
*   **Nurse Dashboard:**
    *   Rekapitulasi cepat jumlah pasien aktif, laporan hari ini yang perlu diverifikasi, dan rata-rata persentase kepatuhan klinik.
    *   Daftar pasien aktif beserta status pengobatan harian mereka.
*   **Sistem Pendaftaran Pasien:**
    *   Input data nama pasien, email, nomor HP, tanggal mulai pengobatan, durasi, dan fase terapi obat.
*   **Pemeriksaan Kepatuhan Pasien Terperinci:**
    *   Melihat profil lengkap pasien terpantau, grafik tren kepatuhan, dan daftar lengkap riwayat laporan minum obat.
    *   **Verifikasi Bukti Foto:** Menampilkan foto bukti fisik minum obat yang diunggah oleh pasien beserta catatan kondisinya sebelum disetujui.

---

## 🚀 Cara Menjalankan Proyek

Pastikan perangkat Anda sudah terinstal Flutter SDK dengan versi minimum `3.0.0`.

### Langkah 1: Kloning Repositori
Masuk ke terminal atau command prompt dan kloning proyek ini:
```bash
git clone https://github.com/afaaa21/Tbeats.git
cd Tbeats
```

### Langkah 2: Dapatkan Dependensi Flutter
Unduh semua pustaka yang dideklarasikan di `pubspec.yaml`:
```bash
flutter pub get
```

### Langkah 3: Periksa Kesiapan Perangkat (Opsional)
Pastikan emulator atau perangkat fisik Anda terdeteksi dengan baik oleh Flutter:
```bash
flutter doctor
```

### Langkah 4: Jalankan Aplikasi
Jalankan aplikasi di perangkat tujuan (Android emulator / perangkat fisik / web browser):
```bash
flutter run
```

---

## ⚙️ Konfigurasi & Environment Variables

### Mode Pengembangan (Current State)
Saat ini, proyek TBeats berjalan penuh menggunakan **Mock/Dummy Data** yang tersimpan di [app_data.dart](file:///d:/Kuliah/Semester_4/Workshop_Pemrogaman_Perangkat_Bergerak/TBeats/Tbeats/lib/data/app_data.dart). Ini bertujuan untuk mempermudah evaluasi UI/UX serta logika navigasi pada fase workshop/kuliah. 

### Rencana Migrasi Backend & API
Untuk mengintegrasikan aplikasi ini dengan server produksi (API RESTful), Anda dapat memanfaatkan file konfigurasi environment berikut:

1.  Buat file `.env` di direktori akar proyek:
    ```env
    API_BASE_URL=https://api.tbeats-clinic.com/v1
    TIMEOUT_MS=10000
    ENABLE_CRASHLYTICS=true
    ```
2.  Tambahkan pustaka `flutter_dotenv` pada `pubspec.yaml`:
    ```yaml
    dependencies:
      flutter_dotenv: ^5.1.0
    ```
3.  Ubah inisialisasi pada [main.dart](file:///d:/Kuliah/Semester_4/Workshop_Pemrogaman_Perangkat_Bergerak/TBeats/Tbeats/lib/main.dart) untuk memuat variabel lingkungan:
    ```dart
    import 'package:flutter_dotenv/flutter_dotenv.dart';
    
    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
      runApp(const MyApp());
    }
    ```
4.  Hubungkan instansiasi di [api_service.dart](file:///d:/Kuliah/Semester_4/Workshop_Pemrogaman_Perangkat_Bergerak/TBeats/Tbeats/lib/service/api_service.dart) dengan menggunakan `dotenv.env['API_BASE_URL']`.

---

> [!TIP]
> **Kepatuhan TBC Menyelamatkan Nyawa.** Aplikasi TBeats dirancang dengan ketulusan untuk mendukung program eliminasi Tuberkulosis nasional. Mari bantu mereka meraih kembali hari-hari yang sehat! 💚
