import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class ApiService {
  final SupabaseClient _client = SupabaseConfig.client;

  // 1. REGISTER PERAWAT (Perawat Self-Register)
  Future<Map<String, dynamic>> registerPerawat(String name, String email, String password) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'perawat',
        },
      );
      return {'message': 'Perawat berhasil didaftarkan', 'user': res.user};
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  // 2. LOGIN GLOBAL (Perawat & Pasien)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final AuthResponse res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final userId = res.user?.id;
      if (userId == null) throw 'Login gagal, user tidak ditemukan.';

      // Ambil role dari tabel profiles
      final profile = await _client.from('profiles').select('role').eq('id', userId).single();

      return {
        'token': res.session?.accessToken,
        'role': profile['role'],
        'user': res.user,
      };
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  // 3. DAFTARKAN PASIEN (Oleh Perawat)
  Future<Map<String, dynamic>> daftarkanPasien(String name, String email, String password) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi perawat tidak ditemukan.';

      // Supabase tidak mengizinkan user biasa membuat user lain secara default via signUp biasa
      // Cara ideal: Supabase Admin API (Edge Function) ATAU jika RLS diatur longgar
      // Untuk simulasi ini, asumsi trigger handle_new_user akan menangkap meta_data
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'pasien',
          'perawat_id': currentUser.id,
        },
      );
      
      return {'message': 'Akun Pasien berhasil dibuat', 'pasien': res.user};
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Gagal mendaftarkan pasien: $e';
    }
  }

  // 4. GET DAFTAR PASIEN KU (Oleh Perawat)
  Future<List<dynamic>> getDaftarPasienKu() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi perawat tidak ditemukan.';

      final data = await _client.from('profiles').select().eq('perawat_id', currentUser.id);
      return data;
    } catch (e) {
      throw 'Gagal mengambil data pasien: $e';
    }
  }

  // 5. TAMBAH JADWAL OBAT (Oleh Pasien)
  Future<Map<String, dynamic>> tambahJadwalObat(String namaObat, String takaran, String jamMinum, String aturanMakan) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi pasien tidak ditemukan.';

      final data = await _client.from('medications').insert({
        'user_id': currentUser.id,
        'nama_obat': namaObat,
        'takaran': takaran,
        'jam_minum': jamMinum,
        'aturan_makan': aturanMakan,
      }).select();

      return {'message': 'Jadwal obat berhasil ditambahkan', 'medication': data.first};
    } catch (e) {
      throw 'Gagal menambah jadwal obat: $e';
    }
  }

  // 6. GET JADWAL OBAT KU (Oleh Pasien)
  Future<List<dynamic>> getJadwalObatKu() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi pasien tidak ditemukan.';

      final data = await _client.from('medications').select().eq('user_id', currentUser.id);
      return data;
    } catch (e) {
      throw 'Gagal mengambil jadwal obat: $e';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
