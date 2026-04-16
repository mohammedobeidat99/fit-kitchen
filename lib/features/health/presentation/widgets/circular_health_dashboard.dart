import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_container.dart';

class CircularHealthDashboard extends StatelessWidget {
  final int calories;
  final int targetCalories;
  final double protein;
  final double targetProtein;
  final double carbs;
  final double targetCarbs;

  const CircularHealthDashboard({
    super.key,
    required this.calories,
    required this.targetCalories,
    required this.protein,
    required this.targetProtein,
    required this.carbs,
    required this.targetCarbs,
  });

  @override
  Widget build(BuildContext context) {
    final caloriePercent = (calories / targetCalories).clamp(0.0, 1.0);
    final proteinPercent = (protein / targetProtein).clamp(0.0, 1.0);
    final carbsPercent = (carbs / targetCarbs).clamp(0.0, 1.0);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: 0.1,
      child: Row(
        children: [
          // Large Calorie Ring
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _RingPainter(
                    percent: caloriePercent,
                    color: Colors.white,
                    backgroundColor: Colors.white.withAlpha(30),
                    width: 10,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$calories',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Macro Progress
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MacroRow(
                  label: 'Protein',
                  value: '${protein.toInt()}g',
                  percent: proteinPercent,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                _MacroRow(
                  label: 'Carbs',
                  value: '${carbs.toInt()}g',
                  percent: carbsPercent,
                  color: AppTheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;

  const _MacroRow({required this.label, required this.value, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color backgroundColor;
  final double width;

  _RingPainter({
    required this.percent,
    required this.color,
    required this.backgroundColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - width) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
