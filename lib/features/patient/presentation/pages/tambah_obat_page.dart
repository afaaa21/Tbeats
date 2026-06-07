import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../service/api_service.dart';

class TambahObatPage extends StatefulWidget {
  const TambahObatPage({super.key});
  @override
  State<TambahObatPage> createState() => _TambahObatPageState();
}

class _TambahObatPageState extends State<TambahObatPage> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final ApiService _apiService = ApiService();

  TimeOfDay? _selectedTime;
  String _aturanMakan = 'Sebelum makan pagi';
  bool _saving = false;

  static const _aturanOptions = [
    'Sebelum makan pagi',
    'Sesudah makan pagi',
    'Sebelum makan siang',
    'Sesudah makan siang',
    'Sebelum makan malam',
    'Sesudah makan malam',
    'Kapan saja',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primaryContainer),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _doseCtrl.text.trim().isNotEmpty &&
      _selectedTime != null;

  void _save() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    try {
      final hour   = _selectedTime!.hour.toString().padLeft(2, '0');
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      await _apiService.tambahJadwalObat(
        _nameCtrl.text.trim(),
        _doseCtrl.text.trim(),
        '$hour:$minute',
        _aturanMakan,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan obat: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Obat',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lengkapi informasi obat untuk membantu Anda\ntetap disiplin dalam menjalani pengobatan.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  _buildFieldLabel(Icons.medication_outlined, 'Nama Obat'),
                  const SizedBox(height: 8),
                  _buildInput(controller: _nameCtrl, hint: 'Contoh: Rifampisin'),
                  const SizedBox(height: 18),

                  _buildFieldLabel(Icons.science_outlined, 'Dosis'),
                  const SizedBox(height: 8),
                  _buildInput(controller: _doseCtrl, hint: 'Contoh: 1 Tablet (450mg)'),
                  const SizedBox(height: 18),

                  _buildFieldLabel(Icons.access_time_rounded, 'Jam Minum'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedTime == null
                                ? '--:-- --'
                                : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} WIB',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedTime == null ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.access_time_rounded, color: AppColors.outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildFieldLabel(Icons.restaurant_menu_outlined, 'Aturan Makan'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _aturanMakan,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        icon: const Icon(Icons.expand_more, color: AppColors.outline),
                        onChanged: (val) { if (val != null) setState(() => _aturanMakan = val); },
                        items: _aturanOptions.map((opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryContainer.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penting!',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryContainer)),
                        SizedBox(height: 2),
                        Text(
                          'Pastikan jadwal minum obat sudah dikonsultasikan dengan dokter Anda.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 12 : 28),
        color: AppColors.surface,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: (!_isValid || _saving) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValid ? AppColors.primaryContainer : AppColors.outlineVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: _saving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            label: const Text('Simpan Obat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(IconData icon, String label) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.outline),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildInput({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2)),
      ),
    );
  }
}
