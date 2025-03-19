// explosion
import 'dart:math';

import 'package:flutter/material.dart';

class Explosion extends StatefulWidget {
  final double x;
  final double y;
  final Color color;
  final Function(Explosion)? onComplete;

  const Explosion({
    super.key,
    required this.x,
    required this.y,
    required this.color,
    this.onComplete,
  });

  @override
  State<Explosion> createState() => _ExplosionState();
}

class _ExplosionState extends State<Explosion> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  final String explosionImage = "assets/explosion.png";

  @override
  void initState() {
    super.initState();

    // Create explosion particles
    _createParticles();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call(widget);
        }
      });

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start all animations
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.forward();
  }

  void _createParticles() {
    // Create 12 particles that fly outward from explosion center
    for (int i = 0; i < 12; i++) {
      final angle = i * (pi * 2 / 12);
      final speed = 1.0 + _random.nextDouble() * 2.0;
      final size = 3.0 + _random.nextDouble() * 5.0;

      _particles.add(Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: widget.color.withValues(alpha: .8),
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x - 25,
      top: widget.y - 25,
      child: Stack(
        children: [
          // Main explosion image
          AnimatedBuilder(
            animation: Listenable.merge(
                [_fadeController, _scaleController, _rotateController]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeController.value,
                child: Transform.rotate(
                  angle: _rotateController.value * 0.5,
                  child: Transform.scale(
                    scale: 0.5 + _scaleController.value * 1.5,
                    child: Image.asset(
                      explosionImage,
                      color: widget.color,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              );
            },
          ),

          // Particles
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _fadeController.value,
                ),
                size: Size(100, 100),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Calculate position based on angle, speed and animation progress
      final distance = particle.speed * 50 * progress;
      final dx = cos(particle.angle) * distance;
      final dy = sin(particle.angle) * distance;

      final position = center + Offset(dx, dy);
      final opacity = (1.0 - progress) * 0.9;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          position, particle.size * (1.0 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
