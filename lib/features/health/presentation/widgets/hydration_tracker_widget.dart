import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class HydrationTrackerWidget extends StatefulWidget {
  final int currentGlasses;
  final int targetGlasses;
  final Function(int) onUpdate;

  const HydrationTrackerWidget({
    super.key,
    required this.currentGlasses,
    required this.targetGlasses,
    required this.onUpdate,
  });

  @override
  State<HydrationTrackerWidget> createState() => _HydrationTrackerWidgetState();
}

class _HydrationTrackerWidgetState extends State<HydrationTrackerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentGlasses / widget.targetGlasses).clamp(0.0, 1.0);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Row(
        children: [
          // Wave Animation
          SizedBox(
            width: 70,
            height: 70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(color: Colors.white.withAlpha(20)),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, animatedProgress, child) {
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(70, 70),
                            painter: _WavePainter(
                              progress: animatedProgress,
                              waveOffset: _controller.value,
                              color: Colors.blue.withAlpha(150),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Center(
                    child: Icon(Icons.water_drop_rounded, 
                      color: progress > 0.5 ? Colors.white : Colors.blue.withAlpha(100), 
                      size: 24
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Water Hydration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${widget.currentGlasses} of ${widget.targetGlasses} glasses', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onUpdate(widget.currentGlasses + 1),
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primary, size: 32),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final double waveOffset;
  final Color color;

  _WavePainter({required this.progress, required this.waveOffset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final fillHeight = size.height * (1 - progress);
    final waveHeight = 4.0;

    path.moveTo(0, size.height);
    path.lineTo(0, fillHeight);
    
    for (double i = 0; i <= size.width; i++) {
                final dx = i;
                final dy = fillHeight + math.sin((i / size.width * 2 * math.pi) + (waveOffset * 2 * math.pi)) * waveHeight;
                path.lineTo(dx, dy);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
