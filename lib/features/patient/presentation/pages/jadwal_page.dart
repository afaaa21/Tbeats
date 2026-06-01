import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/medication_icon.dart';
import '../../../../service/api_service.dart';
import 'tambah_obat_page.dart';
import 'lapor_page.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final ApiService _apiService = ApiService();
  List<Medication> _meds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final medsData = await _apiService.getJadwalObatKu();
      final loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();

      if (!mounted) return;
      setState(() {
        _meds = loadedMeds;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text('Gagal Memuat Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final meds = _meds;
    final belumDilaporkan = meds
        .where((m) =>
            m.status == MedicationStatus.terlambat ||
            m.status == MedicationStatus.belumDilaporkan)
        .toList();
    final terlewat =
        meds.where((m) => m.status == MedicationStatus.terlewat).toList();
    final sudah =
        meds.where((m) => m.status == MedicationStatus.sudahDiminum).toList();
    final belumWaktu =
        meds.where((m) => m.status == MedicationStatus.belumWaktunya).toList();

    final now = DateTime.now();
    final days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final months = ['Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TambahObatPage()));
          if (result == true) _loadData();
        },
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jadwal Minum Obat',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Pantau kepatuhan konsumsi obat harian Anda.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),

              if (meds.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('Belum ada jadwal obat ditambahkan.', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),

              if (belumDilaporkan.isNotEmpty) ...[
                _sectionHeader('Belum Dilaporkan',
                    AppColors.warning, belumDilaporkan.length),
                ...belumDilaporkan
                    .map((m) => _jadwalCard(context, m, false)),
                const SizedBox(height: 16),
              ],

              if (belumWaktu.isNotEmpty) ...[
                _sectionHeader('Belum Waktunya',
                    AppColors.textSecondary, belumWaktu.length),
                ...belumWaktu.map((m) => _jadwalCard(context, m, false)),
                const SizedBox(height: 16),
              ],

              if (terlewat.isNotEmpty) ...[
                _sectionHeader('Terlewat', AppColors.danger, terlewat.length),
                ...terlewat.map((m) => _jadwalCard(context, m, true)),
                const SizedBox(height: 16),
              ],

              if (sudah.isNotEmpty) ...[
                _sectionHeader('Sudah Dilaporkan',
                    AppColors.success, sudah.length),
                ...sudah.map((m) => _doneCard(m)),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _jadwalCard(BuildContext context, Medication med, bool isSusulan) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final min = med.time.minute.toString().padLeft(2, '0');
    final isReported = med.photoPath != null && med.photoPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicationIcon(medicationName: med.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${med.name} ${med.dose}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${med.schedule} • ${med.notes?.isNotEmpty == true ? med.notes! : '-'}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isSusulan
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text('$hour:$min WIB',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSusulan
                                  ? AppColors.danger
                                  : AppColors.warning,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditMedSheet(context, med);
                  } else if (val == 'delete') {
                    _confirmDeleteMed(context, med);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Ubah Jadwal'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text('Hapus Jadwal', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isReported
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text(
                          'Sudah Dilaporkan (Menunggu Verifikasi)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : isSusulan
                    ? OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LaporPage(medication: med)),
                        ).then((_) => _loadData()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: const Text('Lapor Susulan',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LaporPage(medication: med)),
                        ).then((_) => _loadData()),
                        icon: const Icon(Icons.camera_alt_rounded, size: 16),
                        label: const Text('Lapor Minum',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _doneCard(Medication med) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final min = med.time.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${med.name} ${med.dose}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.lineThrough)),
                Text('Selesai dilaporkan jam $hour:$min',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Selesai',
                style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (val) {
              if (val == 'edit') {
                _showEditMedSheet(context, med);
              } else if (val == 'delete') {
                _confirmDeleteMed(context, med);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Ubah Jadwal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Hapus Jadwal', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditMedSheet(BuildContext context, Medication med) {
    final nameCtrl = TextEditingController(text: med.name);
    final doseCtrl = TextEditingController(text: med.dose);
    TimeOfDay? selectedTime = med.time;
    String aturanMakan = med.notes?.isNotEmpty == true ? med.notes! : 'Sebelum makan pagi';
    bool saving = false;

    const aturanOptions = [
      'Sebelum makan pagi',
      'Sesudah makan pagi',
      'Sebelum makan siang',
      'Sesudah makan siang',
      'Sebelum makan malam',
      'Sesudah makan malam',
      'Kapan saja',
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),
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
                      context: ctx,
                      initialTime: selectedTime ?? const TimeOfDay(hour: 7, minute: 0),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primaryContainer),
                        ),
                        child: child!,
                      ),
                    );
                    if (t != null) setModalState(() => selectedTime = t);
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
                        selectedTime == null
                            ? 'Pilih Jam Minum'
                            : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} WIB',
                        style: TextStyle(
                          color: selectedTime == null ? AppColors.textSecondary : AppColors.textPrimary, fontSize: 14),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: aturanOptions.contains(aturanMakan) ? aturanMakan : 'Sebelum makan pagi',
                  decoration: const InputDecoration(
                    labelText: 'Aturan Makan',
                    prefixIcon: Icon(Icons.restaurant_menu_outlined)),
                  items: aturanOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) { if (v != null) setModalState(() => aturanMakan = v); },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (nameCtrl.text.trim().isEmpty || doseCtrl.text.trim().isEmpty || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Nama obat, dosis, dan jam wajib diisi.')));
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        final h = selectedTime!.hour.toString().padLeft(2, '0');
                        final m = selectedTime!.minute.toString().padLeft(2, '0');
                        await _apiService.updateMedicationDetails(
                          med.id,
                          nameCtrl.text.trim(),
                          doseCtrl.text.trim(),
                          '$h:$m',
                          aturanMakan,
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
                            content: Text('Gagal memperbarui obat: $e'), backgroundColor: AppColors.danger));
                        }
                      }
                    },
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

  void _confirmDeleteMed(BuildContext context, Medication med) {
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
}