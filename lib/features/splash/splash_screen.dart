import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../home/presentation/home_page_new.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate to home after splash duration
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF0A0A1A),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(_controller.value),
                  );
                },
              ),
            ),
            // Blue light streak effect
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.5,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00B4FF).withOpacity(0.3 * _fadeAnimation.value),
                          const Color(0xFF0066FF).withOpacity(0.6 * _fadeAnimation.value),
                          const Color(0xFF00B4FF).withOpacity(0.3 * _fadeAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4FF).withOpacity(0.5 * _fadeAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Full screen logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/splash_logo.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B4FF),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 * animationValue)
      ..style = PaintingStyle.fill;

    // Draw particles
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7 + animationValue * 100) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
