import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../service/api_service.dart';

class LaporPage extends StatefulWidget {
  final Medication medication;
  const LaporPage({super.key, required this.medication});
  @override
  State<LaporPage> createState() => _LaporPageState();
}

class _LaporPageState extends State<LaporPage> {
  bool _photoTaken = false;
  bool _submitting = false;
  final _notesCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (image != null) {
        setState(() {
          _photoTaken = true;
          _pickedImagePath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback ke galeri jika kamera gagal/tidak tersedia
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
        );
        if (image != null) {
          setState(() {
            _photoTaken = true;
            _pickedImagePath = image.path;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto berhasil dipilih dari galeri'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengambil gambar: $err'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _photoTaken = false;
      _pickedImagePath = null;
    });
  }

  void _submit() async {
    if (!_photoTaken || _pickedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap ambil foto terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Menandai status obat sebagai 'belumDilaporkan' (menunggu verifikasi perawat)
      // Kita kirimkan path foto lokal dan keluhan catatan ke database
      await ApiService().updateMedicationStatus(
        widget.medication.id,
        'belumDilaporkan',
        photoPath: _pickedImagePath,
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Laporan Terkirim!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data Anda telah dikirim ke perawat pendamping.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context, true); // back to previous with success signal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim laporan: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    final hour = med.time.hour.toString().padLeft(2, '0');
    final minute = med.time.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lapor Minum Obat',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        '${med.dose} • $hour:$minute WIB',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Photo section
            const Row(
              children: [
                Text(
                  'Bukti Foto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary),
                ),
                Spacer(),
                Text('*Wajib',
                    style: TextStyle(color: AppColors.danger, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _photoTaken ? _retakePhoto : _takePhoto,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: _photoTaken
                      ? AppColors.success.withOpacity(0.08)
                      : AppColors.primaryContainer.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _photoTaken
                        ? AppColors.success
                        : AppColors.primaryContainer,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _photoTaken
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 12),
                          const Text('Foto Berhasil Diambil',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Tap untuk ambil ulang',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Corner brackets
                          SizedBox(
                            width: 160,
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: _corner(true, true),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _corner(true, false),
                                ),
                                Center(
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 28),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: _corner(false, true),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: _corner(false, false),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Ambil Foto',
                              style: TextStyle(
                                  color: AppColors.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text(
                            'Pastikan wajah dan obat\nterlihat jelas dalam satu bingkai',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            const Text(
              'Catatan (Opsional)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tambahkan keluhan atau efek samping jika ada...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.edit_note_rounded,
                      color: AppColors.textSecondary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primaryContainer),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Kirim Laporan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(width: 8),
                          Icon(Icons.send_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _corner(bool top, bool left) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    if (top && left) {
      canvas.drawLine(Offset(0, h), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    } else if (top && !left) {
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    } else if (!top && left) {
      canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    } else {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
