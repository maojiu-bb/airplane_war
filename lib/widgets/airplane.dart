// airplane widget
import 'package:flutter/material.dart';

class Airplane extends StatefulWidget {
  final double? x;
  final double? y;
  final Function(DragUpdateDetails details) onPanUpdate;
  final double size;

  final String _airplaneImage = "assets/airplane.png";
  const Airplane({
    super.key,
    this.x,
    this.y,
    this.size = 70.0,
    required this.onPanUpdate,
  });

  @override
  State<Airplane> createState() => _AirplaneState();
}

class _AirplaneState extends State<Airplane>
    with SingleTickerProviderStateMixin {
  late AnimationController _engineEffectController;

  @override
  void initState() {
    super.initState();
    _engineEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _engineEffectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 16),
      left: widget.x,
      bottom: widget.y,
      child: GestureDetector(
        onPanUpdate: widget.onPanUpdate,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Engine flame effect
            Positioned(
              bottom: -5,
              child: AnimatedBuilder(
                animation: _engineEffectController,
                builder: (context, child) {
                  return Container(
                    width: widget.size * 0.3,
                    height: widget.size * 0.4 * _engineEffectController.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange,
                          Colors.red,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(widget.size * 0.15),
                    ),
                  );
                },
              ),
            ),

            // Airplane image
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: .3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                widget._airplaneImage,
                width: widget.size,
                height: widget.size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
