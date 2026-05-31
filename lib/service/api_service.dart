import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class ApiService {
  final SupabaseClient _client = SupabaseConfig.client;

  // 1. REGISTER PERAWAT (Perawat Self-Register)
  Future<Map<String, dynamic>> registerPerawat(
      String name, String email, String password, String phone) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'perawat',
          'phone': phone,
        },
      );

      if (res.user == null) throw 'Registrasi gagal.';

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
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

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
  Future<Map<String, dynamic>> daftarkanPasien(
    String name,
    String email,
    String password, {
    Map<String, dynamic>? profileData,
    List<Map<String, dynamic>>? defaultMeds,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi perawat tidak ditemukan.';

      final perawatId = currentUser.id;

      // tempClient khusus untuk signup pasien, tidak ganggu session perawat
      final tempClient = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseAnonKey,
      );

      final AuthResponse res = await tempClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'pasien',
          'perawat_id': perawatId,
        },
      );

      final patientId = res.user?.id;
      if (patientId == null) throw 'Gagal membuat akun pasien.';

      // Tunggu trigger selesai buat profil
      await Future.delayed(const Duration(seconds: 1));

      // Update data klinis menggunakan session perawat
      if (profileData != null && profileData.isNotEmpty) {
        await _client.from('profiles').update(profileData).eq('id', patientId);
      }

      // Insert medications menggunakan session perawat
      if (defaultMeds != null) {
        for (var med in defaultMeds) {
          await _client.from('medications').insert({
            ...med,
            'user_id': patientId,
          });
        }
      }

      await tempClient.dispose();

      return {'message': 'Akun Pasien berhasil dibuat'};
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

      final data = await _client
          .from('profiles')
          .select()
          .eq('perawat_id', currentUser.id);
      return data;
    } catch (e) {
      throw 'Gagal mengambil data pasien: $e';
    }
  }

  // 5. TAMBAH JADWAL OBAT (Oleh Pasien)
  Future<Map<String, dynamic>> tambahJadwalObat(String namaObat, String takaran,
      String jamMinum, String aturanMakan) async {
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

      return {
        'message': 'Jadwal obat berhasil ditambahkan',
        'medication': data.first
      };
    } catch (e) {
      throw 'Gagal menambah jadwal obat: $e';
    }
  }

  // 6. GET JADWAL OBAT KU (Oleh Pasien)
  Future<List<dynamic>> getJadwalObatKu() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi pasien tidak ditemukan.';

      final data = await _client
          .from('medications')
          .select()
          .eq('user_id', currentUser.id);
      return data;
    } catch (e) {
      throw 'Gagal mengambil jadwal obat: $e';
    }
  }

  // 7. GET PROFILE INFO (Untuk Pasien & Perawat)
  Future<Map<String, dynamic>> getProfileInfo() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi tidak ditemukan.';

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();
      return data;
    } catch (e) {
      throw 'Gagal mengambil data profil: $e';
    }
  }

  // 8. UPDATE PROFILE (Oleh Perawat untuk Pasien, atau update mandiri)
  Future<void> updateProfile(
      String profileId, Map<String, dynamic> updates) async {
    try {
      final Map<String, dynamic> upsertData = {
        'id': profileId,
        ...updates,
      };
      await _client.from('profiles').upsert(upsertData);
    } catch (e) {
      throw 'Gagal mengupdate profil: $e';
    }
  }

  // 9. GET DETAIL PASIEN (Untuk Perawat)
  Future<Map<String, dynamic>> getPasienDetail(String pasienId) async {
    try {
      final data =
          await _client.from('profiles').select().eq('id', pasienId).single();
      return data;
    } catch (e) {
      throw 'Gagal mengambil detail pasien: $e';
    }
  }

  // 10. UPDATE STATUS OBAT (Oleh Pasien/Perawat)
  Future<void> updateMedicationStatus(String medId, String status,
      {String? photoPath, String? notes}) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status,
      };
      if (photoPath != null) updates['photo_path'] = photoPath;
      if (notes != null) updates['notes'] = notes;

      // Jika dilaporkan atau selesai, tandai waktu pelaporannya
      if (status == 'sudahDiminum' ||
          status == 'belumDilaporkan' ||
          status == 'terlambat') {
        updates['reported_at'] = DateTime.now().toIso8601String();
      }

      await _client.from('medications').update(updates).eq('id', medId);
    } catch (e) {
      throw 'Gagal mengupdate status obat: $e';
    }
  }

  // 11. GET RIWAYAT OBAT (Untuk Riwayat Kepatuhan)
  Future<List<dynamic>> getHistoryMedication(String userId) async {
    try {
      final data = await _client
          .from('medications')
          .select()
          .eq('user_id', userId)
          .order('reported_at', ascending: false);
      return data;
    } catch (e) {
      throw 'Gagal mengambil riwayat obat: $e';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
