import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;

  const StatBadge({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    required this.icon,
    this.accentColor = CyberpunkTheme.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CyberpunkTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: CyberpunkTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: value,
                    style: TextStyle(
                      color: CyberpunkTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rajdhani',
                    ),
                    children: [
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: ' $unit',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
