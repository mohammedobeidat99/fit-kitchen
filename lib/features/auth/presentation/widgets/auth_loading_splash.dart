import 'package:flutter/material.dart';

class AuthLoadingSplash extends StatefulWidget {
  final String label;
  const AuthLoadingSplash({super.key, required this.label});

  @override
  State<AuthLoadingSplash> createState() => _AuthLoadingSplashState();
}

class _AuthLoadingSplashState extends State<AuthLoadingSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing logo
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (_, __) => Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(70), width: 2),
                  ),
                  child: const Icon(Icons.kitchen_rounded, size: 55, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
