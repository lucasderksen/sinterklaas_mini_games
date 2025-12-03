import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/game_state.dart';
import 'home_screen.dart';

class GameCompleteScreen extends StatelessWidget {
  final GameStateManager gameState;

  const GameCompleteScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'GEFELICITEERD!',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Je hebt alle spellen voltooid!',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppConstants.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Je hebt gewonnen:',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...gameState.prizesWon.map((prize) => _buildPrizeCard(prize)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎅',
                          style: TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Van Sinterklaas\nmet veel liefs!',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          gameState.reset();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(gameState: gameState),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('Opnieuw spelen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrizeCard(String prize) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.accentGold.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Text('🎁', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              prize,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppConstants.success,
            size: 30,
          ),
        ],
      ),
    );
  }
}
