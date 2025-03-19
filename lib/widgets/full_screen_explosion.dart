import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';

class FullScreenExplosion extends StatefulWidget {
  final Function? onComplete;

  const FullScreenExplosion({super.key, this.onComplete});

  @override
  _FullScreenExplosionState createState() => _FullScreenExplosionState();
}

class _FullScreenExplosionState extends State<FullScreenExplosion>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<ExplosionParticle> _particles = [];
  final Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Create explosion particles
    _createParticles();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Scale animation for the explosion
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _shakeController.forward();

    // Add listener to handle completion
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  void _createParticles() {
    // Create 50 random particles
    for (int i = 0; i < 50; i++) {
      _particles.add(ExplosionParticle(
        position: Offset(_random.nextDouble(), _random.nextDouble()),
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 0.05,
          (_random.nextDouble() * 2 - 1) * 0.05,
        ),
        color: _getRandomExplosionColor(),
        size: _random.nextDouble() * 20 + 5,
      ));
    }
  }

  Color _getRandomExplosionColor() {
    final colors = [
      Colors.red.shade700,
      Colors.orange,
      Colors.yellow,
      Colors.amber.shade900,
      Colors.deepOrange,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_fadeController, _scaleController, _shakeAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(_shakeAnimation.value * math.pi * 8) *
                  10 *
                  (1 - _shakeAnimation.value),
              math.cos(_shakeAnimation.value * math.pi * 6) *
                  10 *
                  (1 - _shakeAnimation.value),
            ),
            child: FadeTransition(
              opacity: _fadeController,
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.orange.shade500,
                          Colors.red.shade900,
                          Colors.black54,
                        ],
                        stops: [0.0, 0.2, 0.6, 1.0],
                        center: Alignment.center,
                        radius: 0.8 * _scaleController.value,
                      ),
                    ),
                  ),

                  // Explosion image in the center
                  Center(
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.5,
                        end: 2.5,
                      ).animate(CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.easeOutBack,
                      )),
                      child: Opacity(
                        opacity: (1.0 - _scaleController.value * 0.7)
                            .clamp(0.0, 1.0),
                        child: Image.asset(
                          'assets/explosion.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                  ),

                  // Explosion particles
                  CustomPaint(
                    painter: ExplosionPainter(
                      particles: _particles,
                      progress: _scaleController.value,
                    ),
                    size: Size.infinite,
                  ),

                  // Text effect
                  Center(
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.0,
                        end: 1.5,
                      ).animate(CurvedAnimation(
                        parent: _scaleController,
                        curve: Interval(0.1, 0.6, curve: Curves.elasticOut),
                      )),
                      child: Text(
                        "BOOM!",
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 20.0,
                              color: Colors.red.shade900,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExplosionParticle {
  Offset position; // Normalized position (0-1)
  final Offset velocity;
  final Color color;
  final double size;

  ExplosionParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update(double progress) {
    // Move particle outward as animation progresses
    final directionX = position.dx - 0.5;
    final directionY = position.dy - 0.5;
    final distance =
        math.sqrt(directionX * directionX + directionY * directionY);

    if (distance > 0) {
      final normalizedX = directionX / distance;
      final normalizedY = directionY / distance;

      position = Offset(
        position.dx + normalizedX * 0.03 * progress + velocity.dx,
        position.dy + normalizedY * 0.03 * progress + velocity.dy,
      );
    }
  }
}

class ExplosionPainter extends CustomPainter {
  final List<ExplosionParticle> particles;
  final double progress;

  ExplosionPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.update(progress);

      // Calculate actual position on screen
      final actualX = particle.position.dx * size.width;
      final actualY = particle.position.dy * size.height;

      // Calculate particle opacity based on progress
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      // Draw particle
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(actualX, actualY),
        particle.size * (1.0 + progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
