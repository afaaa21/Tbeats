# TBeats - Flutter App

Aplikasi pendamping pengobatan TBC untuk pasien.

## Struktur Project

```
lib/
├── main.dart                    # Entry point
├── theme.dart                   # Warna & tema aplikasi
├── models/
│   └── models.dart              # Model data (Medication, Patient, dll)
├── data/
│   └── app_data.dart            # Data dummy/mock
├── widgets/
│   └── medication_icon.dart     # Widget ikon obat reusable
└── screens/
    ├── onboarding_screen.dart   # 3 slide onboarding
    ├── login_screen.dart        # Halaman login
    ├── home_screen.dart         # Beranda + bottom nav
    ├── jadwal_screen.dart       # Jadwal minum obat
    ├── riwayat_screen.dart      # Riwayat pengobatan
    ├── profil_screen.dart       # Profil pasien
    └── lapor_screen.dart        # Form lapor minum obat
```

## Cara Menjalankan

1. Pastikan Flutter SDK terinstall (>=3.0.0)
2. Clone/copy project ini
3. Jalankan:
   ```bash
   flutter pub get
   flutter run
   ```

## Akun Demo Login
- Email: `pasien@email.com`
- Password: `12345678`

## Fitur yang Diimplementasi

### Onboarding (3 slide)
- Slide 1: Selamat Datang di TBeats
- Slide 2: Pantau Setiap Langkah Pengobatan  
- Slide 3: Sembuh Itu Perjalanan Bersama
- Tombol Lewati & Lanjut/Mulai Sekarang

### Login
- Email + password dengan show/hide password
- Validasi & error message (merah di bawah)
- Loading state saat login
- Lupa kata sandi (dialog info)

### Beranda
- Greeting dengan nama pasien & no registrasi
- Progress kepatuhan (donut chart) - 85%
- Statistik: Tepat / Telat / Lewat
- Jadwal hari ini dengan status warna-warni
- Badge notifikasi
- Tombol Lapor untuk obat yang belum

### Jadwal
- Grouping by status: Belum Dilaporkan / Belum Waktunya / Terlewat / Sudah Dilaporkan
- Counter per group
- Tombol Lapor Minum / Lapor Susulan
- Thumbnail foto untuk yang sudah dilaporkan

### Lapor Minum Obat
- Info obat di atas
- Area foto dengan corner brackets (tap untuk ambil foto)
- Simulasi ambil foto + konfirmasi
- Catatan opsional
- Submit dengan loading + dialog sukses

### Riwayat
- Filter bulan (Jan-Des)
- Donut chart kepatuhan dengan persentase **di tengah** ✓
- Weekly checklist per obat (7 hari)
- Daftar riwayat dengan **ikon obat** (bukan foto) ✓
- Status badge berwarna

### Profil
- Avatar inisial
- Status pengobatan aktif
- Info pribadi (HP, email)
- Detail perawatan (tanggal mulai, durasi, fase)
- Tim medis (perawat + klinik)
- Tombol telepon perawat
- Tombol keluar dengan konfirmasi

## Perbaikan Sesuai Permintaan
1. ✅ Riwayat: gambar obat = ikon (bukan foto)
2. ✅ Riwayat: angka % kepatuhan di tengah donut (Stack + alignment center)
3. ✅ Semua fitur berfungsi dengan state management dasar
4. ✅ Khusus fitur pasien (bukan petugas kesehatan)
