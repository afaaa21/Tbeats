import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../data/app_data.dart';

class TambahObatPage extends StatefulWidget {
  const TambahObatPage({super.key});
  @override
  State<TambahObatPage> createState() => _TambahObatPageState();
}

class _TambahObatPageState extends State<TambahObatPage> {
  final _nameCtrl  = TextEditingController();
  final _doseCtrl  = TextEditingController();
  final _notesCtrl = TextEditingController();

  TimeOfDay? _selectedTime;
  DateTime?  _startDate;
  DateTime?  _endDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.primaryContainer),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
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
      setState(() {
        if (isStart) {
          _startDate = d;
        } else {
          _endDate = d;
        }
      });
    }
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _doseCtrl.text.trim().isNotEmpty &&
      _selectedTime != null;

  void _save() async {
    if (!_isValid) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final newMed = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      schedule: (_selectedTime!.hour < 12) ? 'Pagi' : 'Malam',
      time: _selectedTime!,
      notes: _notesCtrl.text.trim(),
      status: MedicationStatus.belumWaktunya,
    );
    AppData.todayMedications.add(newMed);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true); // sinyal: data berubah
  }

  @override
  Widget build(BuildContext context) {
    String? dateFormat(DateTime? d) => d == null
        ? null
        : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

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
            // Form card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lengkapi informasi obat untuk membantu Anda\ntetap disiplin dalam menjalani pengobatan.',
                    style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Nama Obat
                  _buildFieldLabel(Icons.medication_outlined, 'Nama Obat'),
                  const SizedBox(height: 8),
                  _buildInput(
                    controller: _nameCtrl,
                    hint: 'Contoh: Rifampisin',
                  ),
                  const SizedBox(height: 18),

                  // Dosis
                  _buildFieldLabel(Icons.science_outlined, 'Dosis'),
                  const SizedBox(height: 8),
                  _buildInput(
                    controller: _doseCtrl,
                    hint: 'Contoh: 1 Tablet (450mg)',
                  ),
                  const SizedBox(height: 18),

                  // Jam Minum
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
                              color: _selectedTime == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tanggal Mulai & Selesai
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel(Icons.calendar_today_outlined, 'Mulai'),
                            const SizedBox(height: 8),
                            _buildDateField(
                              value: dateFormat(_startDate),
                              hint: 'dd/mm/yyyy',
                              onTap: () => _pickDate(true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel(Icons.calendar_today_outlined, 'Selesai'),
                            const SizedBox(height: 8),
                            _buildDateField(
                              value: dateFormat(_endDate),
                              hint: 'dd/mm/yyyy',
                              onTap: () => _pickDate(false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Catatan
                  _buildFieldLabel(Icons.subject_rounded, 'Catatan Tambahan'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Diminum sesudah makan pagi',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primaryContainer, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
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
                border: Border.all(
                    color: AppColors.primaryContainer.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penting!',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.primaryContainer,
                            )),
                        SizedBox(height: 2),
                        Text(
                          'Pastikan jadwal minum obat sudah dikonsultasikan dengan dokter Anda.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary, height: 1.4),
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

      // Fixed bottom button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        color: AppColors.surface,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: (!_isValid || _saving) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValid
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: _saving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded,
                    color: Colors.white, size: 20),
            label: const Text('Simpan Obat',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(IconData icon, String label) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.outline),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.primaryContainer, width: 2)),
      ),
    );
  }

  Widget _buildDateField({
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(children: [
          Text(value ?? hint,
              style: TextStyle(
                fontSize: 13,
                color: value == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              )),
          const Spacer(),
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.outline, size: 18),
        ]),
      ),
    );
  }
}