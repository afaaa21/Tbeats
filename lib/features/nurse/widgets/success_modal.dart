import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class SuccessModal extends StatelessWidget {
  const SuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Akun Pasien Berhasil Dibuat!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data pasien telah tersimpan di sistem pemantauan TBeats.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            const SizedBox(height: 24),

            // Credential Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _CredentialRow(
                    label: 'EMAIL',
                    value: 'budi@example.com',
                    isLast: false,
                  ),
                  _CredentialRow(
                    label: 'PASSWORD',
                    value: 'xxxxxxxx',
                    isLast: false,
                  ),
                  _CredentialRow(
                    label: 'NO. REGISTRASI',
                    value: 'TBC-2026-083941',
                    isLast: true,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.warning_outlined, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan pasien mencatat atau menyimpan kredensial ini untuk login ke aplikasi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lihat Data Pasien'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Kembali ke Dashboard',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final bool isHighlight;

  const _CredentialRow({
    required this.label,
    required this.value,
    required this.isLast,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
                        color: isHighlight ? AppColors.success : AppColors.textPrimary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, color: AppColors.success, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil disalin'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: AppColors.success.withOpacity(0.1)),
      ],
    );
  }
}