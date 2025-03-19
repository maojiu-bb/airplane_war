import 'package:airplane_war/pages/splash_view.dart';
import 'package:airplane_war/states/game_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const AirplaneWar());
}

class AirplaneWar extends StatelessWidget {
  const AirplaneWar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Airplane war',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashView(),
      ),
    );
  }
}
