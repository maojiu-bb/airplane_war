import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late List<Star> stars;
  late AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    stars = [];
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateStars();
    });
  }

  void _generateStars() {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Generate 100 stars with random positions and sizes
    for (int i = 0; i < 100; i++) {
      stars.add(
        Star(
          x: random.nextDouble() * screenWidth,
          y: random.nextDouble() * screenHeight,
          size: random.nextDouble() * 2 + 1,
          twinkleSpeed: random.nextDouble() * 2 + 0.5,
          twinkleDelay: random.nextDouble(),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B0B3B), // Deep space blue
            Color(0xFF000000), // Black
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _twinkleController,
        builder: (context, child) {
          return CustomPaint(
            painter: StarPainter(
              stars: stars,
              twinkleValue: _twinkleController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double twinkleDelay;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleDelay,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double twinkleValue;

  StarPainter({required this.stars, required this.twinkleValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      // Calculate individual star twinkle based on its speed and delay
      final starTwinkle =
          (twinkleValue * star.twinkleSpeed + star.twinkleDelay) % 1.0;
      final opacity = 0.3 + (starTwinkle * 0.7);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.twinkleValue != twinkleValue;
  }
}
