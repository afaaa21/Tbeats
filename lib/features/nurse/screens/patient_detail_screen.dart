import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'report_detail_screen.dart';
import '../../../models/models.dart';
import '../../../service/api_service.dart';
import '../../../core/config/supabase_config.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<Medication> _medications = [];
  List<Medication> _weekMedications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Query medications untuk patient.id dari Supabase
      final medsData = await SupabaseConfig.client
          .from('medications')
          .select()
          .eq('user_id', widget.patient.id);

      final loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();

      final weekData = await _apiService.getMedicationsThisWeek(widget.patient.id);
      final loadedWeekMeds = weekData.map((m) => Medication.fromSupabase(m)).toList();

      if (!mounted) return;
      setState(() {
        _medications = loadedMeds;
        _weekMedications = loadedWeekMeds;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEditPatientSheet() {
    final nameCtrl = TextEditingController(text: widget.patient.name);
    final phoneCtrl = TextEditingController(text: widget.patient.phone);
    final durationCtrl = TextEditingController(text: widget.patient.durationMonths.toString());
    final dokterCtrl = TextEditingController(text: widget.patient.dokterName);
    final clinicCtrl = TextEditingController(text: widget.patient.clinicName);
    final addressCtrl = TextEditingController(text: widget.patient.clinicAddress);
    const phaseOptions = ['Intensif', 'Lanjutan'];
    String phase = phaseOptions.contains(widget.patient.phase)
        ? widget.patient.phase
        : phaseOptions.first;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Ubah Data Pasien',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline_rounded)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Handphone',
                    prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: phase,
                  decoration: const InputDecoration(
                    labelText: 'Fase Pengobatan',
                    prefixIcon: Icon(Icons.show_chart_rounded)),
                  items: phaseOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (v) { if (v != null) setModalState(() => phase = v); },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi Pengobatan (Bulan)',
                    prefixIcon: Icon(Icons.calendar_today_outlined)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dokterCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dokter Penanggung Jawab',
                    prefixIcon: Icon(Icons.medical_services_outlined)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: clinicCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Klinik/Puskesmas',
                    prefixIcon: Icon(Icons.local_hospital_outlined)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Klinik',
                    prefixIcon: Icon(Icons.map_outlined)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Nama lengkap dan nomor handphone wajib diisi.')));
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        final duration = int.tryParse(durationCtrl.text.trim()) ?? 6;
                        final Map<String, dynamic> updates = {
                          'name': nameCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'phase': phase,
                          'duration_months': duration,
                          'dokter_name': dokterCtrl.text.trim(),
                          'clinic_name': clinicCtrl.text.trim(),
                          'clinic_address': addressCtrl.text.trim(),
                        };

                        await _apiService.updateProfile(widget.patient.id, updates);
                        
                        if (ctx.mounted) Navigator.pop(ctx);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Data pasien berhasil diubah'),
                            backgroundColor: AppColors.success,
                          ));
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        setModalState(() => saving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Gagal mengubah data pasien: $e'), backgroundColor: AppColors.danger));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Perubahan',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeletePatient() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Hapus Pasien?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus '),
              TextSpan(
                text: widget.patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const TextSpan(text: '?\n\nSemua jadwal obat dan riwayat kepatuhannya akan dihapus secara permanen.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _apiService.hapusPasien(widget.patient.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pasien ${widget.patient.name} berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus pasien: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddMedSheet() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    TimeOfDay? time;
    String aturan = 'Sebelum makan pagi';
    bool saving = false;

    const aturanOptions = [
      'Sebelum makan pagi', 'Sesudah makan pagi',
      'Sebelum makan siang', 'Sesudah makan siang',
      'Sebelum makan malam', 'Sesudah makan malam', 'Kapan saja',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Tambah Jadwal Obat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 4),
              Text('Untuk: ${widget.patient.name}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama Obat (contoh: Rifampisin)',
                  prefixIcon: Icon(Icons.medication_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: doseCtrl,
                decoration: const InputDecoration(
                  hintText: 'Dosis (contoh: 450mg)',
                  prefixIcon: Icon(Icons.science_outlined)),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx, initialTime: const TimeOfDay(hour: 7, minute: 0));
                  if (t != null) setModalState(() => time = t);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.outline, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      time == null
                          ? 'Pilih Jam Minum'
                          : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')} WIB',
                      style: TextStyle(
                        color: time == null ? AppColors.textSecondary : AppColors.textPrimary, fontSize: 14),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: aturan,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.restaurant_menu_outlined)),
                items: aturanOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) { if (v != null) setModalState(() => aturan = v); },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (nameCtrl.text.trim().isEmpty || doseCtrl.text.trim().isEmpty || time == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nama obat, dosis, dan jam wajib diisi.')));
                      return;
                    }
                    setModalState(() => saving = true);
                    try {
                      final h = time!.hour.toString().padLeft(2, '0');
                      final m = time!.minute.toString().padLeft(2, '0');
                      await _apiService.tambahObatPasien(
                        widget.patient.id,
                        nameCtrl.text.trim(),
                        doseCtrl.text.trim(),
                        '$h:$m',
                        aturan,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Jadwal obat berhasil ditambahkan'),
                          backgroundColor: AppColors.success,
                        ));
                      }
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
                      }
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Jadwal Obat',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMedicationSheet(Medication med) {
    final nameCtrl = TextEditingController(text: med.name);
    final doseCtrl = TextEditingController(text: med.dose);
    TimeOfDay? time = med.time;
    String aturan = med.notes?.isNotEmpty == true ? med.notes! : 'Sebelum makan pagi';
    bool saving = false;

    const aturanOptions = [
      'Sebelum makan pagi', 'Sesudah makan pagi',
      'Sebelum makan siang', 'Sesudah makan siang',
      'Sebelum makan malam', 'Sesudah makan malam', 'Kapan saja',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Ubah Jadwal Obat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 4),
              Text('Untuk: ${widget.patient.name}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Obat',
                  prefixIcon: Icon(Icons.medication_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: doseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  prefixIcon: Icon(Icons.science_outlined)),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx, initialTime: time ?? const TimeOfDay(hour: 7, minute: 0));
                  if (t != null) setModalState(() => time = t);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.outline, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      time == null
                          ? 'Pilih Jam Minum'
                          : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')} WIB',
                      style: TextStyle(
                        color: time == null ? AppColors.textSecondary : AppColors.textPrimary, fontSize: 14),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: aturanOptions.contains(aturan) ? aturan : 'Sebelum makan pagi',
                decoration: const InputDecoration(
                  labelText: 'Aturan Makan',
                  prefixIcon: Icon(Icons.restaurant_menu_outlined)),
                items: aturanOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) { if (v != null) setModalState(() => aturan = v); },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (nameCtrl.text.trim().isEmpty || doseCtrl.text.trim().isEmpty || time == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nama obat, dosis, dan jam wajib diisi.')));
                      return;
                    }
                    setModalState(() => saving = true);
                    try {
                      final h = time!.hour.toString().padLeft(2, '0');
                      final m = time!.minute.toString().padLeft(2, '0');
                      await _apiService.updateMedicationDetails(
                        med.id,
                        nameCtrl.text.trim(),
                        doseCtrl.text.trim(),
                        '$h:$m',
                        aturan,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Jadwal obat berhasil diperbarui'),
                          backgroundColor: AppColors.success,
                        ));
                      }
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
                      }
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Jadwal Obat',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMedication(Medication med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Hapus Jadwal Obat?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus jadwal obat '),
              TextSpan(
                text: med.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const TextSpan(text: '?\n\nTindakan ini tidak dapat dibatalkan.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _apiService.hapusMedication(med.id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Jadwal obat ${med.name} berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus obat: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String medId, MedicationStatus status) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.updateMedicationStatus(medId, status.toJsonString());
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == MedicationStatus.sudahDiminum
                ? 'Laporan berhasil dikonfirmasi'
                : 'Laporan berhasil ditolak/ditandai terlewat'),
            backgroundColor: status == MedicationStatus.sudahDiminum
                ? AppColors.success
                : AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate status: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.patient.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.patient.registrationNo,
              style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditPatientSheet(),
            tooltip: 'Ubah Data Pasien',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDeletePatient(),
            tooltip: 'Hapus Pasien',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Bukti Hari Ini'),
            Tab(text: 'Riwayat 7 Hari'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedSheet(),
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryContainer),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _TodayEvidenceTab(
                      patient: widget.patient,
                      medications: _medications,
                      onConfirm: (id) => _updateStatus(id, MedicationStatus.sudahDiminum),
                      onReject: (id) => _updateStatus(id, MedicationStatus.terlewat),
                      onRefresh: _loadData,
                      onEdit: (med) => _showEditMedicationSheet(med),
                      onDelete: (med) => _confirmDeleteMedication(med),
                    ),
                    _WeekHistoryTab(
                      patient: widget.patient,
                      weekMedications: _weekMedications,
                    ),
                  ],
                ),
    );
  }
}

class _TodayEvidenceTab extends StatelessWidget {
  final Patient patient;
  final List<Medication> medications;
  final Function(String) onConfirm;
  final Function(String) onReject;
  final Future<void> Function() onRefresh;
  final Function(Medication) onEdit;
  final Function(Medication) onDelete;

  const _TodayEvidenceTab({
    required this.patient,
    required this.medications,
    required this.onConfirm,
    required this.onReject,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startLabel = '${patient.startDate.day}/${patient.startDate.month}/${patient.startDate.year}';
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryContainer,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Patient Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: patient.phase.toLowerCase().contains('intensif')
                      ? AppColors.warning
                      : AppColors.primaryContainer,
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text(
                    patient.name
                        .split(' ')
                        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                        .take(2)
                        .join(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      Text(
                        'Terdaftar sejak $startLabel • ${patient.clinicName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: patient.phase.toLowerCase().contains('intensif')
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.primaryContainer.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    patient.phase.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: patient.phase.toLowerCase().contains('intensif')
                          ? AppColors.warning
                          : AppColors.primaryContainer,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verifikasi Obat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              Text(
                '${medications.length} Jenis Obat',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (medications.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Belum ada jadwal obat yang dikonfigurasi.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...medications.map((med) {
              final hour = med.time.hour.toString().padLeft(2, '0');
              final minute = med.time.minute.toString().padLeft(2, '0');
              final String timeLabel = '$hour:$minute WIB';

              MedicineStatus viewStatus = MedicineStatus.missed;
              if (med.status == MedicationStatus.sudahDiminum) {
                viewStatus = MedicineStatus.verified;
              } else if (med.status == MedicationStatus.belumDilaporkan) {
                viewStatus = MedicineStatus.needsVerification;
              } else if (med.status == MedicationStatus.belumWaktunya) {
                // If it is not reported and not checked but time hasn't passed, show as missed or pending
                viewStatus = MedicineStatus.missed;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MedicineVerificationCard(
                  med: med,
                  patient: patient,
                  medicineName: med.name,
                  status: viewStatus,
                  time: med.status == MedicationStatus.belumWaktunya ? null : timeLabel,
                  imageUrl: med.photoPath,
                  onConfirm: () => onConfirm(med.id),
                  onReject: () => onReject(med.id),
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(medication: med, patient: patient),
                      ),
                    );
                    if (res == true) {
                      onRefresh();
                    }
                  },
                  onEdit: () => onEdit(med),
                  onDelete: () => onDelete(med),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WeekHistoryTab extends StatelessWidget {
  final Patient patient;
  final List<Medication> weekMedications;

  const _WeekHistoryTab({required this.patient, required this.weekMedications});

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    final Map<String, Map<int, MedicationStatus>> medDayMap = {};
    for (var m in weekMedications) {
      if (m.createdAt == null) continue;
      final dayIndex = m.createdAt!.toLocal().difference(monday).inDays;
      if (dayIndex < 0 || dayIndex > 6) continue;
      final key = "${m.name} (${m.dose})";
      medDayMap.putIfAbsent(key, () => {});
      medDayMap[key]![dayIndex] = m.status;
    }

    final Map<String, List<MedicationStatus?>> checklist = {};
    for (var entry in medDayMap.entries) {
      checklist[entry.key] = List.generate(7, (i) => entry.value[i]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checklist Kepatuhan Mingguan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Menampilkan status kepatuhan pasien selama 7 hari terakhir.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans'),
          ),
          const SizedBox(height: 16),

          if (checklist.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Belum ada data kepatuhan terkumpul.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ...checklist.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        return Column(
                          children: [
                            Text(
                              dayLabels[i],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildDayDot(entry.value[i]),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDayDot(MedicationStatus? status) {
    if (status == null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
      );
    }
    switch (status) {
      case MedicationStatus.sudahDiminum:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      case MedicationStatus.terlambat:
      case MedicationStatus.belumDilaporkan:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove, color: Colors.white, size: 14),
        );
      case MedicationStatus.terlewat:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.danger,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        );
      default:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

enum MedicineStatus { verified, needsVerification, missed }

class _MedicineVerificationCard extends StatelessWidget {
  final Medication med;
  final Patient patient;
  final String medicineName;
  final MedicineStatus status;
  final String? time;
  final String? imageUrl;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicineVerificationCard({
    required this.med,
    required this.patient,
    required this.medicineName,
    required this.status,
    required this.time,
    required this.imageUrl,
    required this.onConfirm,
    required this.onReject,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    Color statusBg;

    switch (status) {
      case MedicineStatus.verified:
        statusColor = AppColors.success;
        statusLabel = 'Tepat Waktu';
        statusIcon = Icons.check_circle_outline;
        statusBg = AppColors.success.withOpacity(0.1);
        break;
      case MedicineStatus.needsVerification:
        statusColor = AppColors.warning;
        statusLabel = 'Butuh Verifikasi';
        statusIcon = Icons.warning_outlined;
        statusBg = AppColors.warning.withOpacity(0.1);
        break;
      case MedicineStatus.missed:
        statusColor = AppColors.danger;
        statusLabel = 'Terlewat';
        statusIcon = Icons.cancel_outlined;
        statusBg = AppColors.danger.withOpacity(0.1);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (time != null)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: status == MedicineStatus.verified
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.warning.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status == MedicineStatus.verified ? 'SUDAH DIMINUM' : 'TERLAMBAT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: status == MedicineStatus.verified
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 2),
                                Text(
                                  time!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              'Belum lapor',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.outline),
                      onSelected: (val) {
                        if (val == 'edit') {
                          onEdit();
                        } else if (val == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text('Ubah Obat'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Hapus Obat', style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (imageUrl != null)
            GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: _buildImage(imageUrl!),
                  ),
                  if (status == MedicineStatus.verified)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: AppColors.success, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Sudah Diverifikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else if (status != MedicineStatus.missed)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_photography_outlined, color: AppColors.outline, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada foto bukti diunggah',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),

          if (status == MedicineStatus.needsVerification)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                        backgroundColor: AppColors.danger.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Konfirmasi',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (status == MedicineStatus.missed && med.status != MedicationStatus.belumWaktunya)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tandai Terlewat',
                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        // Fallback simulated clinical proof image
        return Image.network(
          'https://images.unsplash.com/photo-1550572017-edd951b55104?w=800',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }
  }
}
