import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MedicationIcon extends StatelessWidget {
  final String medicationName;
  final double size;

  const MedicationIcon({
    super.key,
    required this.medicationName,
    this.size = 48,
  });

  static Color _getColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('rifamp')) return const Color(0xFF2D9CDB);
    if (n.contains('isoniazid') || n.contains('inh')) return AppColors.primaryContainer;
    if (n.contains('pirazin')) return const Color(0xFFF2994A);
    if (n.contains('etamb')) return const Color(0xFF9B51E0);
    if (n.contains('strept')) return const Color(0xFFEB5757);
    return AppColors.primaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(medicationName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.medication_rounded,
        color: color,
        size: size * 0.55,
      ),
    );
  }
}