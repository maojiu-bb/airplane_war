import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/game_state.dart';
import 'game_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  String _difficulty = 'Normal'; // default
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    final gameState = Provider.of<GameState>(context, listen: false);

    // Set game parameters based on difficulty
    switch (_difficulty) {
      case 'Easy':
        gameState.moveSpeed = 1.5;
        gameState.ammoFireSpeed = 350; // Slower firing for easier gameplay
        gameState.ammoMoveSpeed = 6;
        break;
      case 'Normal':
        gameState.moveSpeed = 2.0;
        gameState.ammoFireSpeed = 300; // Matches the default in GameState
        gameState.ammoMoveSpeed = 8;
        break;
      case 'Hard':
        gameState.moveSpeed = 3.0;
        gameState.ammoFireSpeed = 250; // Faster firing for harder gameplay
        gameState.ammoMoveSpeed = 10;
        break;
    }

    // navigator to game view
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // game title
                const Text(
                  'AIRPLANE WAR',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.blue,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // airplane image
                Image.asset(
                  'assets/airplane.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 50),

                // select difficulty
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15, left: 10),
                        child: Text(
                          'Select Difficulty:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          _buildDifficultyOption('Easy', Colors.green),
                          _buildDifficultyOption('Normal', Colors.orange),
                          _buildDifficultyOption('Hard', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // start game button
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String difficulty, Color color) {
    return RadioListTile<String>(
      title: Text(
        difficulty,
        style: TextStyle(
          color: Colors.white,
          fontWeight:
              _difficulty == difficulty ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      value: difficulty,
      groupValue: _difficulty,
      activeColor: color,
      onChanged: (value) {
        setState(() {
          _difficulty = value!;
        });
      },
    );
  }
}
