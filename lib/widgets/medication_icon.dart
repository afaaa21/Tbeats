import 'package:flutter/material.dart';
import '../theme.dart';

class MedicationIcon extends StatelessWidget {
  final String medicationName;
  final double size;

  const MedicationIcon({
    super.key,
    required this.medicationName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = getMedicationColor(medicationName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
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
