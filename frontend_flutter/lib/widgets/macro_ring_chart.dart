import 'package:flutter/material.dart';
import '../config/theme.dart';

class MacroRingChart extends StatelessWidget {
  final double consumedCalories;
  final double targetCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MacroRingChart({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (consumedCalories / targetCalories).clamp(0.0, 1.5);
    final bool isExceeded = consumedCalories > targetCalories;
    final Color progressColor = isExceeded ? CyberpunkTheme.neonRed : CyberpunkTheme.neonGreen;

    return Row(
      children: [
        // Circular progress with neon glow
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: (percentage > 1.0) ? 1.0 : percentage,
                  strokeWidth: 10,
                  backgroundColor: CyberpunkTheme.cardSurfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${consumedCalories.toInt()}',
                    style: TextStyle(
                      color: CyberpunkTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: progressColor.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '/ ${targetCalories.toInt()} kcal',
                    style: const TextStyle(
                      color: CyberpunkTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  if (isExceeded)
                    const Text(
                      'SUPERADO',
                      style: TextStyle(
                        color: CyberpunkTheme.neonRed,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Macros Breakdown
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMacroItem(
                label: 'PROTEÍNAS',
                grams: proteinG,
                color: CyberpunkTheme.neonCyan,
                percent: 0.35,
              ),
              const SizedBox(height: 10),
              _buildMacroItem(
                label: 'CARBOHIDRATOS',
                grams: carbsG,
                color: CyberpunkTheme.neonYellow,
                percent: 0.45,
              ),
              const SizedBox(height: 10),
              _buildMacroItem(
                label: 'GRASAS',
                grams: fatG,
                color: CyberpunkTheme.neonRed,
                percent: 0.20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required String label,
    required double grams,
    required Color color,
    required double percent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${grams.toStringAsFixed(1)} g',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: CyberpunkTheme.cardSurfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
