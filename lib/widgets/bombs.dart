import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Bombs extends StatefulWidget {
  final double speed;
  final Function(Bombs)? onRemove;
  final double initX;
  final double initSize;
  const Bombs({
    super.key,
    this.onRemove,
    required this.speed,
    required this.initX,
    required this.initSize,
  });

  double get x => (key as GlobalKey<BombsState>?)?.currentState?.x ?? 0;
  double get y => (key as GlobalKey<BombsState>?)?.currentState?.y ?? 0;
  void stop() => (key as GlobalKey<BombsState>?)?.currentState?.stopMoving();

  @override
  BombsState createState() => BombsState();
}

class BombsState extends State<Bombs> with TickerProviderStateMixin {
  final String _bombsImage = "assets/bombs.png";

  double x = 0.0;
  double y = 0.0;
  double size = 0.0;

  Timer? timer;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initPosition();
    _updatePositionY();
  }

  @override
  void dispose() {
    timer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void stopMoving() {
    timer?.cancel();
  }

  void _initPosition() {
    x = widget.initX;
    y = -50.0;
    size = widget.initSize;
  }

  void _updatePositionY() {
    timer = Timer.periodic(Duration(milliseconds: 16), (_) {
      setState(() {
        y += widget.speed;
      });

      final screenHeight = MediaQuery.of(context).size.height;
      if (y > screenHeight) {
        timer?.cancel();
        widget.onRemove?.call(widget); // remove Item
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * pi,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(
                        alpha: 0.3 + (_pulseController.value * 0.3)),
                    blurRadius: 15,
                    spreadRadius: 5 * _pulseController.value,
                  ),
                ],
              ),
              child: Image.asset(
                _bombsImage,
                width: size,
                height: size,
              ),
            ),
          );
        },
      ),
    );
  }
}
