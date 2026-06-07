import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/success_modal.dart';
import '../../../service/api_service.dart';
import '../../../core/config/supabase_config.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isIntensif = true;
  bool _obscurePassword = true;
  bool _isSaving = false;

  DateTime _startDate = DateTime.now();
  String _durationMonths = '6';
  String _selectedDoctor = 'dr. Bambang Sugeng, Sp.P';
  String _registrationNo = '';
  String _clinicName = 'Puskesmas Kecamatan';
  String _clinicAddress = 'Jl. Kesehatan No. 123, Jakarta Selatan';

  @override
  void initState() {
    super.initState();
    final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _registrationNo = 'TBC-2026-$rand';
    _loadNurseProfile();
  }

  Future<void> _loadNurseProfile() async {
    try {
      final profile = await _apiService.getProfileInfo();
      if (mounted) {
        setState(() {
          _clinicName = profile['clinic_name'] ?? _clinicName;
          _clinicAddress = profile['clinic_address'] ?? _clinicAddress;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.primaryContainer),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() => _startDate = d);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      final name = _nameCtrl.text.trim();

      // 1. Siapkan data klinis pasien ke profiles
      final Map<String, dynamic> profileUpdates = {
        'phone': '+62 ${_phoneCtrl.text.trim()}',
        'registration_no': _registrationNo,
        'start_date': _startDate.toIso8601String(),
        'duration_months': int.parse(_durationMonths),
        'phase': _isIntensif ? 'Intensif' : 'Lanjutan',
        'dokter_name': _selectedDoctor,
        'clinic_name': _clinicName,
        'clinic_address': _clinicAddress,
      };

      // 2. Jadwal obat default berdasarkan fase: Intensif = 4 obat, Lanjutan = 2 obat
      final List<Map<String, dynamic>> defaultMeds = _isIntensif ? [
        {
          'nama_obat': 'Rifampisin',
          'takaran': '450mg',
          'jam_minum': '07:00',
          'aturan_makan': 'Sebelum makan pagi',
          'status': 'belumWaktunya',
        },
        {
          'nama_obat': 'Isoniazid',
          'takaran': '300mg',
          'jam_minum': '07:30',
          'aturan_makan': 'Sebelum makan pagi',
          'status': 'belumWaktunya',
        },
        {
          'nama_obat': 'Pirazinamid',
          'takaran': '1500mg',
          'jam_minum': '08:00',
          'aturan_makan': 'Sesudah makan pagi',
          'status': 'belumWaktunya',
        },
        {
          'nama_obat': 'Etambutol',
          'takaran': '750mg',
          'jam_minum': '20:00',
          'aturan_makan': 'Sesudah makan malam',
          'status': 'belumWaktunya',
        },
      ] : [
        {
          'nama_obat': 'Rifampisin',
          'takaran': '450mg',
          'jam_minum': '07:00',
          'aturan_makan': 'Sebelum makan pagi',
          'status': 'belumWaktunya',
        },
        {
          'nama_obat': 'Isoniazid',
          'takaran': '300mg',
          'jam_minum': '07:30',
          'aturan_makan': 'Sebelum makan pagi',
          'status': 'belumWaktunya',
        },
      ];

      // 3. Daftarkan akun, profil, dan obat secara otomatis dalam satu transaksi terisolasi via ApiService
      await _apiService.daftarkanPasien(
        name,
        email,
        password,
        profileData: profileUpdates,
        defaultMeds: defaultMeds,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Tampilkan dialog sukses dengan kredensial asli
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessModal(
          email: email,
          password: password,
          registrationNo: _registrationNo,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pendaftaran gagal: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final startStr = '${_startDate.day}/${_startDate.month}/${_startDate.year}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Pasien Baru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryContainer),
                  SizedBox(height: 16),
                  Text('Sedang membuat akun & jadwal obat...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                children: [
                  // ===== SECTION: Data Akun Pasien =====
                  const Row(
                    children: [
                      Icon(Icons.person_add_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Data Akun Pasien',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    children: [
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama sesuai KTP',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Email',
                        hint: 'contoh@email.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email harus diisi';
                          if (!value.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nomor Handphone (WhatsApp)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+62',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value == null || value.trim().isEmpty ? 'Nomor HP harus diisi' : null,
                                  decoration: const InputDecoration(hintText: '812xxxx'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password harus diisi';
                              if (value.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Min. 6 karakter',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.outline,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== SECTION: Data Pengobatan =====
                  const Row(
                    children: [
                      Icon(Icons.medical_information_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Data Pengobatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    children: [
                      // No Registrasi (disabled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nomor Registrasi Pasien',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _registrationNo,
                            enabled: false,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                            decoration: InputDecoration(
                              fillColor: AppColors.surfaceContainerLow,
                              filled: true,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dihasilkan otomatis oleh sistem.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tanggal Mulai
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Mulai Pengobatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: InputDecoration(
                              hintText: startStr,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Durasi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Durasi Pengobatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _durationMonths,
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.expand_more, color: AppColors.outline),
                            ),
                            items: const [
                              DropdownMenuItem(value: '6', child: Text('6 Bulan')),
                              DropdownMenuItem(value: '9', child: Text('9 Bulan')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _durationMonths = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Fase Pengobatan (Segmented)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fase Pengobatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isIntensif = true),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isIntensif ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _isIntensif
                                            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                            : [],
                                      ),
                                      child: Text(
                                        'Intensif',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isIntensif ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                          fontFamily: 'PlusJakartaSans',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isIntensif = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isIntensif ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: !_isIntensif
                                            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                            : [],
                                      ),
                                      child: Text(
                                        'Lanjutan',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: !_isIntensif ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                          fontFamily: 'PlusJakartaSans',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dokter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dokter Penanggung Jawab',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: 'dr1',
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.medical_services_outlined, color: AppColors.outline),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'dr1', child: Text('dr. Bambang Sugeng, Sp.P')),
                              DropdownMenuItem(value: 'dr2', child: Text('dr. Siti Rahma, Sp.P')),
                              DropdownMenuItem(value: 'dr3', child: Text('dr. Ahmad Fikri, Sp.P')),
                            ],
                            onChanged: (val) {
                              if (val == 'dr1') _selectedDoctor = 'dr. Bambang Sugeng, Sp.P';
                              if (val == 'dr2') _selectedDoctor = 'dr. Siti Rahma, Sp.P';
                              if (val == 'dr3') _selectedDoctor = 'dr. Ahmad Fikri, Sp.P';
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Illustration
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _isSaving
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 10 : 20),
              color: AppColors.surface,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Buat Akun Pasien'),
              ),
            ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ?? (value) => value == null || value.trim().isEmpty ? '$label harus diisi' : null,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}