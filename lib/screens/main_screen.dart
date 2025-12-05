import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/game_state.dart';
import 'games/kindle_game.dart';
import 'games/popcorn_game.dart';
import 'games/makeup_game.dart';
import 'final_hint_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GameStateManager _gameState = GameStateManager();
  String? _errorMessage;

  void _handleCodeSubmit() {
    final code = _codeController.text.trim().toUpperCase();
    setState(() {
      _errorMessage = null;
    });

    Widget? nextScreen;

    switch (code) {
      case AppConstants.codeKindle:
        nextScreen = KindleGame(gameState: _gameState);
        break;
      case AppConstants.codePopcorn:
        nextScreen = PopcornGame(gameState: _gameState);
        break;
      case AppConstants.codeMakeup:
        nextScreen = MakeupGame(gameState: _gameState);
        break;
      case AppConstants.codeGift:
        nextScreen = const FinalHintScreen();
        break;
      default:
        setState(() {
          _errorMessage = 'Dat klopt niet. Probeer opnieuw!';
        });
        return;
    }

    // nextScreen is guaranteed to be non-null here because of the return in default case
    _codeController.clear();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => nextScreen!),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
              AppConstants.primaryRed,
              AppConstants.primaryRed.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Welkom Daniela!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryRed,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vul de code in om je cadeautje te vinden',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppConstants.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Vul hier je code in',
                          border: const OutlineInputBorder(),
                          errorText: _errorMessage,
                          prefixIcon: const Icon(Icons.vpn_key),
                        ),
                        onSubmitted: (_) => _handleCodeSubmit(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleCodeSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Start Spel!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const ExpansionTile(
                        title: Text(
                          '📜 Gedicht van Sint',
                          style: TextStyle(
                            color: AppConstants.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Lieve Daniela,\n\n"
                              "Sinterklaas is weer in het land,\n"
                              "En heeft iets leuks voor jou gepland.\n"
                              "Geen chocoladeletter of marsepein,\n"
                              "Maar een digitaal spel, dat is pas fijn!\n\n"
                              "Je moet codes zoeken, heel goed speuren,\n"
                              "Om te zien wat er gaat gebeuren.\n"
                              "Drie spellen staan er voor je klaar,\n"
                              "Met elk een code, is dat niet raar?\n\n"
                              "De eerste code krijg je cadeau,\n"
                              "Voor je e-reader, dat maakt je blij zo.\n"
                              "Vul 'E-READER' in en ga snel van start,\n"
                              "Sint wenst je veel plezier met heel zijn hart!",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
