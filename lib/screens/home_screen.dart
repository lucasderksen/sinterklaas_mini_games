import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'games/kindle_game.dart';
import '../models/game_state.dart';

class HomeScreen extends StatelessWidget {
  final GameStateManager gameState;

  const HomeScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎅',
                  style: TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sinterklaas Surprise!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Voor mijn lieve zus',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Speel 3 mini-games\nen win je cadeaus!',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConstants.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KindleGame(gameState: gameState),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Start Spel! 🎮'),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward,
                          color: AppConstants.textSecondary),
                      const SizedBox(width: 10),
                      const Text('🍿', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward,
                          color: AppConstants.textSecondary),
                      const SizedBox(width: 10),
                      const Text('💄', style: TextStyle(fontSize: 30)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
