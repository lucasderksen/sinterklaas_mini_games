import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _showEnglish = false;
  String? _errorMessage;

  static const String _dutchPoem = """
Lieve Daniela, de Sint is hier,
Met cadeautjes en heel veel plezier!

Op je werk ging jij vooruit,
Jouw talent stak er bovenuit!
Global Brand Manager, wat een eer,
Jouw groei verbaast ons keer op keer!

Je Sip en Swap was een groot feest,
Wijn en kleding ruilen - jij bent een beest!
Door jou helpen wij nu Kevin mee,
Als wereldouders - wat een goed idee!

Mama kwam dit jaar vaak langs,
Van Breda naar Brussel, wat een dans!
Samen lunchen was zo fijn,
Al mag de gratis oppas nu even niet meer zijn!

Maar wacht, er waren ook wat streken,
Die Sint toch even moet bespreken!
Met AI nam je ons in de maling,
Neppe inbrekers - wat een verhaling!

Sint vond het stiekem best wel grappig,
Maar belonen? Nee, dat is te slappig!
Je cadeau krijg je dus niet zomaar,
Tech-piet maakte iets speciaals klaar!

Zoek de QR-codes, scan ze snel,
Speel de spellen, doe het wel!
Pas dan krijg je de hint te pakken,
En mag je je cadeautje uitpakken!

Veel succes en plezier,
Groetjes Sint - hij was graag hier!""";

  static const String _englishPoem = """
Dear Daniela, Sint is here,
With gifts and lots of cheer!
At work you really made your mark,
Your talent shone, a real spark!
Global Brand Manager, what an honor,
Your growth amazes us, you're a stunner!
Your Sip and Swap was quite the party,
Wine and clothes swapping - you're a smarty!
Thanks to you we now help Kevin too,
As world parents - what a thing to do!
Mom came to visit quite a lot,
From Breda to Brussels, not an easy shot!
Lunching together was such a delight,
Though the free babysitter is no longer in sight!
But wait, there were some pranks as well,
That Sint really needs to tell!
With AI you fooled us all,
Fake intruders - you had a ball!
Sint found it secretly quite funny,
But reward you? No, that costs too much money!
Your gift won't come to you with ease,
Tech-piet made something special, if you please!
Find the QR codes, scan them fast,
Play the games until the last!
Only then you'll get the clue,
And unwrap the gift that's meant for you!
Good luck and have some fun,
Greetings from Sint - his work is done!""";

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

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
    _audioPlayer.dispose();
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
                      ExpansionTile(
                        title: Text(
                          '📜 Gedicht van Sint',
                          style: TextStyle(
                            color: AppConstants.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 0.0,
                                bottom: 16.0),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    size: 48,
                                    color: AppConstants.primaryRed,
                                  ),
                                  onPressed: () async {
                                    if (_isPlaying) {
                                      await _audioPlayer.pause();
                                    } else {
                                      await _audioPlayer
                                          .play(AssetSource('sinterklaas.mp3'));
                                    }
                                    setState(() {
                                      _isPlaying = !_isPlaying;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Luister naar Sint!",
                                  style: TextStyle(
                                    color: AppConstants.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showEnglish = !_showEnglish;
                                    });
                                  },
                                  icon: const Icon(Icons.translate),
                                  label: Text(_showEnglish
                                      ? "Switch to Dutch"
                                      : "Vertaal naar Engels"),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _showEnglish ? _englishPoem : _dutchPoem,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                      "Hint voor je eerste code:\n\n${AppConstants.hintKindle}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppConstants.textSecondary)),
                                ),
                              ],
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
