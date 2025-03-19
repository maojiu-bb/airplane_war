// item widget
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final double speed;
  final double initX;
  final double initSize;
  final Function(Item)? onRemove;

  const Item({
    super.key,
    required this.initSize,
    required this.speed,
    this.onRemove,
    required this.initX,
  });

  double get x => (key as GlobalKey<ItemState>?)?.currentState?.x ?? 0;
  double get y => (key as GlobalKey<ItemState>?)?.currentState?.y ?? 0;
  double get size => (key as GlobalKey<ItemState>?)?.currentState?.size ?? 0;
  Color get color =>
      (key as GlobalKey<ItemState>?)?.currentState?.color ?? Colors.white;
  void stop() => (key as GlobalKey<ItemState>?)?.currentState?.stopMoving();

  @override
  State<Item> createState() => ItemState();
}

class ItemState extends State<Item> {
  double size = 0.0;
  Color color = Colors.white;
  double x = 0;
  double y = 0;

  Timer? moveTimer;

  @override
  void initState() {
    super.initState();
    _initializeItem();
    _startMoving();
  }

  void stopMoving() {
    moveTimer?.cancel();
  }

  void _initializeItem() {
    final random = Random();
    size = widget.initSize;
    x = widget.initX;
    y = -50.0;

    color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void _startMoving() {
    moveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        y += widget.speed;
      });

      final screenHeight = MediaQuery.of(context).size.height;
      if (y > screenHeight) {
        moveTimer?.cancel();
        widget.onRemove?.call(widget); // remove Item
      }
    });
  }

  @override
  void dispose() {
    moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color,
                    color.withValues(alpha: .7),
                    color.withValues(alpha: .3),
                  ],
                  stops: [0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .7),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.star,
                  color: Colors.white.withValues(alpha: .9),
                  size: size * 0.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
