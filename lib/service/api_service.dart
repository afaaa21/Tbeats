import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class ApiService {
  final SupabaseClient _client = SupabaseConfig.client;

  // 1. REGISTER PERAWAT / DOKTER
  Future<Map<String, dynamic>> registerPerawat(
    String name,
    String email,
    String password,
    String phone, {
    String role = 'perawat',
    String? clinicName,
    String? clinicAddress,
  }) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
          'phone': phone,
          if (clinicName != null && clinicName.isNotEmpty)
            'clinic_name': clinicName,
          if (clinicAddress != null && clinicAddress.isNotEmpty)
            'clinic_address': clinicAddress,
        },
      );
      final user = res.user;
      if (user == null) throw 'Registrasi gagal.';

      await _ensureProfile(
        userId: user.id,
        email: email,
        name: name,
        role: role,
        phone: phone,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
      );

      return {'message': 'Berhasil didaftarkan', 'user': user};
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
          .maybeSingle();

      final profileData = profile ?? await _ensureProfileFromUser(res.user!);

      return {
        'token': res.session?.accessToken,
        'role': profileData['role'],
        'user': res.user,
      };
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  Future<Map<String, dynamic>> _ensureProfileFromUser(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    return _ensureProfile(
      userId: user.id,
      email: user.email ?? metadata['email']?.toString() ?? '',
      name: metadata['name']?.toString() ?? '',
      role: metadata['role']?.toString() ?? 'pasien',
      phone: metadata['phone']?.toString(),
      perawatId: metadata['perawat_id']?.toString(),
      clinicName: metadata['clinic_name']?.toString(),
      clinicAddress: metadata['clinic_address']?.toString(),
    );
  }

  Future<Map<String, dynamic>> _ensureProfile({
    required String userId,
    required String email,
    required String name,
    required String role,
    String? phone,
    String? perawatId,
    String? clinicName,
    String? clinicAddress,
  }) async {
    final data = <String, dynamic>{
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (perawatId != null && perawatId.isNotEmpty) 'perawat_id': perawatId,
      'clinic_name': clinicName?.isNotEmpty == true
          ? clinicName
          : 'Puskesmas Kecamatan',
      'clinic_address': clinicAddress?.isNotEmpty == true
          ? clinicAddress
          : 'Jl. Kesehatan No. 123',
    };

    final result = await _client
        .from('profiles')
        .upsert(data)
        .select()
        .single();
    return result;
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

      // tempClient khusus untuk signup pasien, tidak ganggu session perawat.
      // Gunakan implicit flow agar tidak butuh asyncStorage (PKCE hanya untuk main client).
      final tempClient = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseAnonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );

      final AuthResponse res = await tempClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': 'pasien', 'perawat_id': perawatId},
      );

      final patientId = res.user?.id;
      if (patientId == null) throw 'Gagal membuat akun pasien.';

      // Upsert profil langsung — tidak bergantung pada trigger.
      // Jika trigger sudah buat profil, ini akan update; jika belum, ini akan insert.
      await _client.from('profiles').upsert({
        'id': patientId,
        'name': name,
        'email': email,
        'role': 'pasien',
        'perawat_id': perawatId,
        ...?profileData,
      });

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
  Future<Map<String, dynamic>> tambahJadwalObat(
    String namaObat,
    String takaran,
    String jamMinum,
    String aturanMakan,
  ) async {
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
        'medication': data.first,
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

  // 7. GET MEDICATIONS THIS WEEK (Untuk Checklist Mingguan)
  Future<List<dynamic>> getMedicationsThisWeek(String? userId) async {
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) throw 'Sesi tidak ditemukan.';
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      return await _client
          .from('medications')
          .select()
          .eq('user_id', uid)
          .gte('created_at', monday.toIso8601String())
          .order('created_at', ascending: true);
    } catch (e) {
      throw 'Gagal mengambil data mingguan: $e';
    }
  }

  // NEW: Tambah obat untuk pasien (oleh Perawat/Dokter)
  Future<Map<String, dynamic>> tambahObatPasien(
    String patientId,
    String namaObat,
    String takaran,
    String jamMinum,
    String aturanMakan,
  ) async {
    try {
      final data = await _client.from('medications').insert({
        'user_id': patientId,
        'nama_obat': namaObat,
        'takaran': takaran,
        'jam_minum': jamMinum,
        'aturan_makan': aturanMakan,
      }).select();
      return {
        'message': 'Jadwal obat berhasil ditambahkan',
        'medication': data.first,
      };
    } catch (e) {
      throw 'Gagal menambah jadwal obat: $e';
    }
  }

  // NEW: Hitung verifikasi bulan ini untuk perawat
  Future<int> getVerifikasiCountBulanIni() async {
    try {
      final patients = await getDaftarPasienKu();
      if (patients.isEmpty) return 0;
      final patientIds = patients.map((p) => p['id'].toString()).toList();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final result = await _client
          .from('medications')
          .select()
          .inFilter('user_id', patientIds)
          .eq('status', 'sudahDiminum')
          .gte('created_at', startOfMonth.toIso8601String());
      return (result as List).length;
    } catch (e) {
      return 0;
    }
  }

  // 8. GET PROFILE INFO (Untuk Pasien & Perawat)
  Future<Map<String, dynamic>> getProfileInfo() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw 'Sesi tidak ditemukan.';

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();
      if (data == null) throw 'Profil tidak ditemukan.';
      return data;
    } catch (e) {
      throw 'Gagal mengambil data profil: $e';
    }
  }

  // 8. UPDATE PROFILE (Oleh Perawat untuk Pasien, atau update mandiri)
  Future<void> updateProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final Map<String, dynamic> upsertData = {'id': profileId, ...updates};
      await _client.from('profiles').upsert(upsertData);
    } catch (e) {
      throw 'Gagal mengupdate profil: $e';
    }
  }

  // 9. GET DETAIL PASIEN (Untuk Perawat)
  Future<Map<String, dynamic>> getPasienDetail(String pasienId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', pasienId)
          .maybeSingle();
      if (data == null) throw 'Pasien tidak ditemukan.';
      return data;
    } catch (e) {
      throw 'Gagal mengambil detail pasien: $e';
    }
  }

  // 10. UPDATE STATUS OBAT (Oleh Pasien/Perawat)
  Future<void> updateMedicationStatus(
    String medId,
    String status, {
    String? photoPath,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> updates = {'status': status};
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

  // HAPUS PASIEN (Oleh Perawat)
  Future<void> hapusPasien(String patientId) async {
    try {
      // 1. Hapus semua jadwal obat pasien terlebih dahulu
      await _client.from('medications').delete().eq('user_id', patientId);
      
      // 2. Hapus baris profil pasien secara langsung (diizinkan oleh kebijakan RLS DELETE profiles yang baru)
      await _client.from('profiles').delete().eq('id', patientId);
    } catch (e) {
      throw 'Gagal menghapus pasien: $e';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // UPDATE MEDICATION DETAILS (Oleh Pasien atau Perawat)
  Future<void> updateMedicationDetails(
    String medId,
    String namaObat,
    String takaran,
    String jamMinum,
    String aturanMakan,
  ) async {
    try {
      await _client.from('medications').update({
        'nama_obat': namaObat,
        'takaran': takaran,
        'jam_minum': jamMinum,
        'aturan_makan': aturanMakan,
      }).eq('id', medId);
    } catch (e) {
      throw 'Gagal memperbarui detail obat: $e';
    }
  }

  // HAPUS MEDICATION (Oleh Pasien atau Perawat)
  Future<void> hapusMedication(String medId) async {
    try {
      await _client.from('medications').delete().eq('id', medId);
    } catch (e) {
      throw 'Gagal menghapus obat: $e';
    }
  }
}

