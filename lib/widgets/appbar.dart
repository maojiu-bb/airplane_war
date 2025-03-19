// app bar widget
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final int score;
  final int healthPoints;

  const AppBarWidget({
    super.key,
    this.score = 0,
    this.healthPoints = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Enhanced Score container
              Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade800,
                      Colors.deepPurple.shade900
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: .6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated star icon
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500),
                      tween: Tween(begin: 0.8, end: 1.2),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Score text with glow effect
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [Colors.white, Colors.lightBlueAccent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: Text(
                        "$score",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.blue.shade300,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Health points container
              Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade800, Colors.redAccent.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: .5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ...List.generate(
                      healthPoints,
                      (index) => Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    ...List.generate(
                      5 - healthPoints,
                      (index) => Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
