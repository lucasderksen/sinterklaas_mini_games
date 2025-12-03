import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'models/game_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SinterklaasApp());
}

class SinterklaasApp extends StatelessWidget {
  const SinterklaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameStateManager();

    return MaterialApp(
      title: 'Sinterklaas Surprise',
      theme: SinterklaasTheme.theme,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(gameState: gameState),
    );
  }
}
