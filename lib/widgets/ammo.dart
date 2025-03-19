// ammo data class
import 'package:flutter/material.dart';

class AmmoData {
  double x;
  double y;

  AmmoData({required this.x, required this.y});
}

class Ammo extends StatefulWidget {
  final double x;
  final double y;
  final double ammoWidth;
  final double ammoHeight;
  final Color color;

  const Ammo({
    super.key,
    required this.x,
    required this.y,
    this.ammoWidth = 5,
    this.ammoHeight = 15,
    this.color = Colors.amber,
  });

  @override
  State<Ammo> createState() => _AmmoState();
}

class _AmmoState extends State<Ammo> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 16),
      left: widget.x,
      bottom: widget.y,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main ammo
              Container(
                width: widget.ammoWidth,
                height: widget.ammoHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: .7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.ammoWidth / 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: .7),
                      blurRadius: 5.0 * _pulseController.value,
                      spreadRadius: 1.0 * _pulseController.value,
                    ),
                  ],
                ),
              ),

              // Trail effect
              Container(
                width: widget.ammoWidth * 0.6,
                height: widget.ammoHeight * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.color.withValues(alpha: .7),
                      widget.color.withValues(alpha: .0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.ammoWidth / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
