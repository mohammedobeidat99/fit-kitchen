import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: isDark ? color.withAlpha(20) : color.withAlpha(15), // Soft colored glow!
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : AppTheme.getSubtitleColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
