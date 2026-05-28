import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/success_modal.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  bool _isIntensif = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
      body: Form(
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
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Email',
                  hint: 'contoh@email.com',
                  keyboardType: TextInputType.emailAddress,
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
                            keyboardType: TextInputType.phone,
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
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Min. 8 karakter',
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
                      initialValue: 'TBC-2026-XXXXXX',
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
                      onTap: () async {
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pilih tanggal',
                        suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.outline),
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
                      initialValue: '6',
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.expand_more, color: AppColors.outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: '6', child: Text('6 Bulan')),
                        DropdownMenuItem(value: '9', child: Text('9 Bulan')),
                      ],
                      onChanged: (_) {},
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
                      hint: const Text('Pilih Dokter'),
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.medical_services_outlined, color: AppColors.outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'dr1', child: Text('dr. Bambang Sugeng, Sp.P')),
                        DropdownMenuItem(value: 'dr2', child: Text('dr. Siti Rahma, Sp.P')),
                        DropdownMenuItem(value: 'dr3', child: Text('dr. Ahmad Fikri, Sp.P')),
                      ],
                      onChanged: (_) {},
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.surface,
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const SuccessModal(),
            );
          },
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
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}