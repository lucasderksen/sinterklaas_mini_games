import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FinalHintScreen extends StatelessWidget {
  const FinalHintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryRed.withValues(alpha: 0.1),
              AppConstants.accentGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: AppConstants.primaryRed,
                ),
                const SizedBox(height: 32),
                Text(
                  'Gefeliciteerd!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppConstants.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.hintGift,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Terug naar start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
