import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A3D2E), Color(0xFF1B7A4F), Color(0xFF27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: MediaQuery.of(context).size,
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(60), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.kitchen_rounded,
                          size: 65,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name + tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) => Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          'FitKitchen',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(50),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SlideTransition(
                          position: _taglineSlide,
                          child: Text(
                            'Eat Smart. Live Better.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withAlpha(180),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progressValue.value,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Preparing your kitchen...',
                        style: TextStyle(
                          color: Colors.white.withAlpha(130),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> _particles = List.generate(
    18,
    (i) => _Particle(
      x: (i * 137.508) % 1.0,
      y: (i * 73.3) % 1.0,
      radius: 1.5 + (i % 4) * 1.2,
      speed: 0.12 + (i % 5) * 0.04,
      phase: i * 0.35,
    ),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(30);
    for (final p in _particles) {
      final dy = ((p.y + progress * p.speed + p.phase) % 1.0);
      final dx = p.x + sin(progress * 2 * pi + p.phase) * 0.03;
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}
