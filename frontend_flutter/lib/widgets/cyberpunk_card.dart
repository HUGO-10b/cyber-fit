import 'package:flutter/material.dart';
import '../config/theme.dart';

class CyberpunkCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final bool hasGlow;

  const CyberpunkCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
    this.borderColor = CyberpunkTheme.neonGreen,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CyberpunkTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: hasGlow
            ? CyberpunkTheme.neonGlowShadow(color: borderColor, blur: 16)
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: CyberpunkTheme.neonGlowShadow(
                            color: borderColor,
                            blur: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title!.toUpperCase(),
                        style: TextStyle(
                          color: CyberpunkTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            Divider(
              height: 1,
              color: borderColor.withOpacity(0.15),
            ),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}
