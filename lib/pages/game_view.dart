import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/game_state.dart';
import '../widgets/airplane.dart';
import '../widgets/ammo.dart';
import '../widgets/appbar.dart';
import '../widgets/full_screen_explosion.dart';
import '../widgets/space_background.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late GameState gameState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameState = Provider.of<GameState>(context, listen: false);
      gameState.initGame(context);
    });
  }

  // Show game over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .8),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.deepPurple.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: .5),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.shade400,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with animated glow effect
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Colors.blue.shade300, Colors.purple.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      "GAME OVER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Airplane image with rotation animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 3),
                    tween: Tween(begin: 0, end: 2 * 3.14),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 0.1 * (value < 3.14 ? 1 : -1),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: .3),
                            spreadRadius: 5,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/airplane.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Game over message
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "You have no health points to continue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Score display - Enhanced version
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade900,
                          Colors.purple.shade900,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: .6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "FINAL SCORE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Consumer<GameState>(
                          builder: (context, gameState, child) {
                            return TweenAnimationBuilder<int>(
                              duration: const Duration(seconds: 1),
                              tween: IntTween(begin: 0, end: gameState.score),
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "$value",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.blue.shade300,
                                            blurRadius: 15,
                                            offset: const Offset(0, 0),
                                          ),
                                          Shadow(
                                            color: Colors.purple.shade300,
                                            blurRadius: 15,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGameOverButton(
                        label: "BACK",
                        icon: Icons.arrow_back,
                        color: Colors.redAccent,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                      _buildGameOverButton(
                        label: "RESTART",
                        icon: Icons.refresh,
                        color: Colors.greenAccent,
                        onPressed: () {
                          Navigator.pop(context);
                          // Reset game state
                          Provider.of<GameState>(context, listen: false)
                              .initGame(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build game over dialog buttons
  Widget _buildGameOverButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Stack(
          children: [
            // Button glow effect
            Container(
              height: 55,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .6),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Button with hover effect
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.95 + (0.05 * value),
                  child: child,
                );
              },
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(15),
                child: Ink(
                  height: 55,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: .7),
                        color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Check if health points are zero or less and dialog not shown yet
        if (gameState.healthPoints <= 0 &&
            !gameState.isShowFullScreenExplosion &&
            !gameState.isGameOverDialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gameState.isGameOverDialogShown = true;
            gameState.stopGame(context);
            _showGameOverDialog();
          });
        }

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Space background with stars
                const SpaceBackground(),

                // Game elements
                Positioned.fill(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // App bar
                      AppBarWidget(
                        key: gameState.appBarKey,
                        score: gameState.score,
                        healthPoints: gameState.healthPoints,
                      ),

                      // Player airplane
                      Airplane(
                        x: gameState.airplaneX,
                        y: gameState.airplaneY,
                        onPanUpdate: gameState.updateAirplanePosition,
                        size: gameState.airplaneSize,
                      ),

                      // Ammo/bullets
                      ...gameState.ammos.map(
                        (ammo) => Ammo(
                          x: ammo.x,
                          y: ammo.y,
                          ammoWidth: gameState.ammoWidth,
                          ammoHeight: gameState.ammoHeight,
                        ),
                      ),

                      // Game items
                      ...gameState.items,

                      // Explosions
                      ...gameState.explosions,

                      // Bombs
                      ...gameState.bombs,

                      // Full screen explosion effect
                      if (gameState.isShowFullScreenExplosion)
                        FullScreenExplosion(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
