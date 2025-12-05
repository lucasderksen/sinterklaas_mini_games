import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/game_state.dart';
import '../../widgets/congratulations_overlay.dart';

// Asset paths - Add your images to these locations
class MakeupAssets {
  static const String basePath = 'assets/images/makeup/';

  // Phase icons
  static const String iconPop = '${basePath}icon_pop.png';
  static const String iconPump = '${basePath}icon_pump.png';
  static const String iconApply = '${basePath}icon_apply.png';
  static const String iconClean = '${basePath}icon_clean.png';
  static const String iconMask = '${basePath}icon_mask.png';
  static const String iconGlow = '${basePath}icon_glow.png';

  // Faces
  static const String faceNeutral = '${basePath}face_neutral.png';
  static const String faceHappy = '${basePath}face_happy.png';
  static const String faceRelaxed = '${basePath}face_relaxed.png';
  static const String faceExcited = '${basePath}face_excited.png';
  static const String faceScared = '${basePath}face_scared.png';
  static const String faceMasked = '${basePath}face_masked.png';
  static const String faceWithCucumbers = '${basePath}face_with_cucumbers.png';

  // Items
  static const String pumpBottle = '${basePath}pump_bottle.png';
  static const String productSpray = '${basePath}product_spray.png';
  static const String sparkle = '${basePath}sparkle.png';
  static const String bubble = '${basePath}bubble.png';
  static const String cucumber = '${basePath}cucumber.png';
  static const String zit = '${basePath}zit.png';
  static const String zitPopped = '${basePath}zit_popped.png';
  static const String maskJar = '${basePath}mask_jar.png';

  // UI elements
  static const String arrowLeft = '${basePath}arrow_left.png';
  static const String arrowRight = '${basePath}arrow_right.png';
  static const String handPoint = '${basePath}hand_point.png';
  static const String crown = '${basePath}crown.png';
  static const String heartBroken = '${basePath}heart_broken.png';
  static const String targetZone = '${basePath}target_zone.png';
}

enum MakeupPhase {
  popZits,
  pump,
  apply,
  clean,
  applyMask,
  removeMask,
  complete,
}

class Zit {
  final Offset position;
  final double size;
  bool isPopped;
  bool isPopping;

  Zit({
    required this.position,
    required this.size,
    this.isPopped = false,
    this.isPopping = false,
  });
}

class PopParticle {
  Offset position;
  Offset velocity;
  double opacity;

  PopParticle({
    required this.position,
    required this.velocity,
    this.opacity = 1.0,
  });
}

class MakeupGame extends StatefulWidget {
  final GameStateManager gameState;

  const MakeupGame({super.key, required this.gameState});

  @override
  State<MakeupGame> createState() => _MakeupGameState();
}

class _MakeupGameState extends State<MakeupGame> with TickerProviderStateMixin {
  MakeupPhase _phase = MakeupPhase.popZits;

  // Game settings
  final int _requiredPumps = 20;
  final int _requiredApplications = 10;

  int _pumpCount = 0;
  int _applicationCount = 0;
  double _cleanProgress = 0;

  // Zit popping
  List<Zit> _zits = [];
  int _poppedZits = 0;
  final int _totalZits = 8;
  List<PopParticle> _particles = [];

  // Mask phase - drag cucumbers
  bool _leftCucumberPlaced = false;
  bool _rightCucumberPlaced = false;
  Offset? _draggingCucumberPosition;
  bool _isDraggingLeftCucumber = false;
  bool _isDraggingRightCucumber = false;
  double _maskSpreadProgress = 0;

  // Glow phase - timing game
  late AnimationController _timingBarController;
  double _timingBarPosition = 0; // -1 to 1
  bool _canTapTiming = true;
  int _timingAttempts = 0;
  bool _timingSuccess = false;
  String? _timingFeedback;

  // Timer
  int _timeRemaining = 90;
  bool _gameOver = false;
  bool _gameWon = false;

  // Animations
  late AnimationController _pumpAnimController;
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late AnimationController _timerPulseController;
  late AnimationController _particleController;

  late Animation<double> _pumpBounce;
  late Animation<double> _shakeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _timerPulse;

  final Random _random = Random();

  // Makeup sparkles positions
  List<Offset> _makeupSpots = [];

  // Cleaning bubbles
  List<Offset> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _initializeZits();
    _initializeAnimations();
    _startTimer();
  }

  void _initializeZits() {
    _zits = [];
    final positions = [
      const Offset(-50, -40),
      const Offset(50, -30),
      const Offset(-30, 20),
      const Offset(40, 35),
      const Offset(-55, 50),
      const Offset(60, -55),
      const Offset(0, 60),
      const Offset(-20, -60),
    ];

    for (int i = 0; i < _totalZits; i++) {
      _zits.add(Zit(
        position: positions[i % positions.length],
        size: 25 + _random.nextDouble() * 15,
      ));
    }
  }

  void _initializeAnimations() {
    _pumpAnimController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );

    _pumpBounce = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pumpAnimController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _timerPulse = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(_updateParticles);

    // Timing bar for glow phase
    _timingBarController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..addListener(() {
        if (_phase == MakeupPhase.removeMask && !_timingSuccess) {
          setState(() {
            // Oscillate between -1 and 1
            _timingBarPosition = sin(_timingBarController.value * 2 * pi);
          });
        }
      });
  }

  void _updateParticles() {
    if (_particles.isEmpty) return;
    setState(() {
      for (var particle in _particles) {
        particle.position += particle.velocity;
        particle.velocity = Offset(
          particle.velocity.dx * 0.95,
          particle.velocity.dy + 0.5,
        );
        particle.opacity -= 0.02;
      }
      _particles.removeWhere((p) => p.opacity <= 0);
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _gameOver || _gameWon) return false;

      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 10) {
          _timerPulseController.forward().then((_) {
            _timerPulseController.reverse();
          });
        }
        if (_timeRemaining <= 0) {
          _handleGameOver();
        }
      });
      return _timeRemaining > 0 && !_gameWon && !_gameOver;
    });
  }

  void _handleGameOver() {
    if (_gameOver) return;
    setState(() {
      _gameOver = true;
    });
    _timingBarController.stop();
    _shakeController.forward();
  }

  void _restartGame() {
    setState(() {
      _phase = MakeupPhase.popZits;
      _pumpCount = 0;
      _applicationCount = 0;
      _cleanProgress = 0;
      _poppedZits = 0;
      _gameOver = false;
      _gameWon = false;
      _timeRemaining = 90;
      _particles = [];
      _makeupSpots = [];
      _bubbles = [];
      _leftCucumberPlaced = false;
      _rightCucumberPlaced = false;
      _maskSpreadProgress = 0;
      _timingBarPosition = 0;
      _canTapTiming = true;
      _timingAttempts = 0;
      _timingSuccess = false;
      _timingFeedback = null;
      _initializeZits();
    });
    _shakeController.reset();
    _timingBarController.reset();
    _startTimer();
  }

  @override
  void dispose() {
    _pumpAnimController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    _timerPulseController.dispose();
    _particleController.dispose();
    _timingBarController.dispose();
    super.dispose();
  }

  void _spawnPopParticles(Offset center) {
    for (int i = 0; i < 12; i++) {
      double angle = (i / 12) * 2 * pi;
      double speed = 3 + _random.nextDouble() * 5;
      _particles.add(PopParticle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      ));
    }
    _particleController.reset();
    _particleController.forward();
  }

  String _getPhaseInstruction() {
    switch (_phase) {
      case MakeupPhase.popZits:
        return 'Pop alle puistjes! ($_poppedZits/$_totalZits)\nTik snel op de puistjes!';
      case MakeupPhase.pump:
        return 'Pump het product! ($_pumpCount/$_requiredPumps)\nTik snel op de pomp!';
      case MakeupPhase.apply:
        return 'Breng makeup aan! ($_applicationCount/$_requiredApplications)\nTik op het gezicht!';
      case MakeupPhase.clean:
        return 'Maak het gezicht schoon!\nSwipe over het gezicht!';
      case MakeupPhase.applyMask:
        if (!_leftCucumberPlaced || !_rightCucumberPlaced) {
          return 'Sleep de komkommers naar de ogen!\nDaarna smeer je het masker uit.';
        } else {
          return 'Smeer het masker uit!\nSwipe in cirkels over het gezicht.';
        }
      case MakeupPhase.removeMask:
        if (_timingSuccess) {
          return 'Perfect timing!';
        }
        return 'Stop de balk in het groene gebied!\nTik op het juiste moment.';
      case MakeupPhase.complete:
        return 'Perfect! Je bent klaar!';
    }
  }

  void _handleZitPop(int index) {
    if (_phase != MakeupPhase.popZits || _gameOver) return;
    if (_zits[index].isPopped || _zits[index].isPopping) return;

    setState(() {
      _zits[index].isPopping = true;
    });

    final zit = _zits[index];
    _spawnPopParticles(Offset(110 + zit.position.dx, 110 + zit.position.dy));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _zits[index].isPopped = true;
        _zits[index].isPopping = false;
        _poppedZits++;

        if (_poppedZits >= _totalZits) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _phase = MakeupPhase.pump;
              });
            }
          });
        }
      });
    });
  }

  void _handlePumpTap() {
    if (_phase != MakeupPhase.pump || _gameOver) return;

    _pumpAnimController.forward().then((_) => _pumpAnimController.reverse());

    setState(() {
      _pumpCount++;
      if (_pumpCount >= _requiredPumps) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _phase = MakeupPhase.apply;
            });
          }
        });
      }
    });
  }

  void _handleFaceTap(TapDownDetails details) {
    if (_phase != MakeupPhase.apply || _gameOver) return;

    setState(() {
      _makeupSpots.add(details.localPosition);
      _applicationCount++;
      if (_applicationCount >= _requiredApplications) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _phase = MakeupPhase.clean;
            });
          }
        });
      }
    });
  }

  void _handleCleanSwipe(DragUpdateDetails details) {
    if (_phase != MakeupPhase.clean || _gameOver) return;

    setState(() {
      _cleanProgress += (details.delta.dx.abs() + details.delta.dy.abs()) / 300;

      if (_random.nextDouble() > 0.7) {
        _bubbles.add(Offset(
          _random.nextDouble() * 180 + 20,
          _random.nextDouble() * 180 + 20,
        ));
        if (_bubbles.length > 15) {
          _bubbles.removeAt(0);
        }
      }

      if (_cleanProgress >= 1) {
        _bubbles.clear();
        _phase = MakeupPhase.applyMask;
      }
    });
  }

  void _handleMaskSpread(DragUpdateDetails details) {
    if (_phase != MakeupPhase.applyMask || _gameOver) return;
    if (!_leftCucumberPlaced || !_rightCucumberPlaced) return;

    setState(() {
      // Circular motion detection - any swipe counts
      _maskSpreadProgress +=
          (details.delta.dx.abs() + details.delta.dy.abs()) / 400;

      if (_maskSpreadProgress >= 1) {
        _startGlowPhase();
      }
    });
  }

  void _startGlowPhase() {
    setState(() {
      _phase = MakeupPhase.removeMask;
      _timingBarPosition = 0;
      _canTapTiming = true;
      _timingSuccess = false;
    });
    _timingBarController.repeat();
  }

  void _handleTimingTap() {
    if (_phase != MakeupPhase.removeMask || _gameOver) return;
    if (!_canTapTiming || _timingSuccess) return;

    setState(() {
      _timingAttempts++;

      // Check if within target zone (-0.15 to 0.15 is the sweet spot)
      if (_timingBarPosition.abs() <= 0.18) {
        // Success!
        _timingSuccess = true;
        _timingFeedback = 'PERFECT!';
        _timingBarController.stop();

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _gameWon = true;
              _phase = MakeupPhase.complete;
            });
            _showCompletion();
          }
        });
      } else {
        // Miss - disable tapping for 2 seconds
        _canTapTiming = false;
        _timingFeedback = 'GEMIST!';

        // Speed up the bar slightly after each miss
        _timingBarController.duration = Duration(
          milliseconds: max(600, 1200 - (_timingAttempts * 100)),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _phase == MakeupPhase.removeMask && !_timingSuccess) {
            setState(() {
              _canTapTiming = true;
              _timingFeedback = null;
            });
          }
        });
      }
    });
  }

  void _showCompletion() {
    widget.gameState.completeGame('makeup', 'Makeup Set');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      CongratulationsOverlay.show(
        context: context,
        title: 'Prachtig!',
        emoji: '💄',
        message:
            'Je hebt het in ${90 - _timeRemaining} seconden gehaald!\n\nHint voor de laatste code:\n${AppConstants.hintFinalCodeLocation}',
        giftMessage: 'Makeup Set',
        buttonText: 'Terug naar start',
        buttonColor: AppConstants.success,
        onButtonPressed: () {
          Navigator.of(context).pop();
        },
      );
    });
  }

  Color _getTimerColor() {
    if (_timeRemaining <= 10) return AppConstants.danger;
    if (_timeRemaining <= 25) return AppConstants.warning;
    return AppConstants.success;
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case MakeupPhase.popZits:
        return AppConstants.danger;
      case MakeupPhase.pump:
        return AppConstants.primaryRed;
      case MakeupPhase.apply:
        return AppConstants.accentGold;
      case MakeupPhase.clean:
        return Colors.blue;
      case MakeupPhase.applyMask:
        return AppConstants.success;
      case MakeupPhase.removeMask:
        return AppConstants.accentGold;
      case MakeupPhase.complete:
        return AppConstants.accentGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon:
              const Icon(Icons.arrow_back_ios, color: AppConstants.textPrimary),
        ),
        title: const Text(
          'Makeup Salon',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTimer(),
                _buildPhaseProgress(),
                Expanded(
                  child: _buildGameArea(),
                ),
                _buildInstructions(),
              ],
            ),
            if (_gameOver && !_gameWon) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return AnimatedBuilder(
      animation: _timerPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _timeRemaining <= 10 ? _timerPulse.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _getTimerColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTimerColor(),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _timeRemaining <= 10
                      ? Icons.warning_rounded
                      : Icons.timer_rounded,
                  color: _getTimerColor(),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  '$_timeRemaining',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getTimerColor(),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'sec',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getTimerColor(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPhaseIndicator(
              MakeupPhase.popZits, MakeupAssets.iconPop, 'Pop'),
          _buildPhaseArrow(),
          _buildPhaseIndicator(MakeupPhase.pump, MakeupAssets.iconPump, 'Pump'),
          _buildPhaseArrow(),
          _buildPhaseIndicator(
              MakeupPhase.apply, MakeupAssets.iconApply, 'Apply'),
          _buildPhaseArrow(),
          _buildPhaseIndicator(
              MakeupPhase.clean, MakeupAssets.iconClean, 'Clean'),
          _buildPhaseArrow(),
          _buildPhaseIndicator(
              MakeupPhase.applyMask, MakeupAssets.iconMask, 'Mask'),
          _buildPhaseArrow(),
          _buildPhaseIndicator(
              MakeupPhase.removeMask, MakeupAssets.iconGlow, 'Glow'),
        ],
      ),
    );
  }

  Widget _buildPhaseArrow() {
    return Icon(
      Icons.chevron_right,
      color: AppConstants.textSecondary.withOpacity(0.3),
      size: 16,
    );
  }

  Widget _buildPhaseIndicator(
      MakeupPhase phase, String assetPath, String label) {
    final isActive = _phase == phase;
    final isComplete = _phase.index > phase.index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isComplete
                ? AppConstants.success
                : isActive
                    ? _getPhaseColor()
                    : AppConstants.cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isComplete
                  ? AppConstants.success
                  : isActive
                      ? _getPhaseColor()
                      : AppConstants.textSecondary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              assetPath,
              color: isComplete || isActive
                  ? Colors.white
                  : AppConstants.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? _getPhaseColor() : AppConstants.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverOverlay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeAnimation.value) * 5, 0),
          child: Container(
            color: Colors.black.withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Image.asset(
                          MakeupAssets.faceScared,
                          width: 120,
                          height: 120,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'TIJD IS OP!',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.danger,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        MakeupAssets.heartBroken,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'De klant is boos weggelopen...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Je was bij fase: ${_phase.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Probeer Opnieuw!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Terug naar menu',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_phase == MakeupPhase.popZits) _buildZitPhase(),
            if (_phase == MakeupPhase.pump) _buildPumpPhase(),
            if (_phase == MakeupPhase.apply) _buildApplyPhase(),
            if (_phase == MakeupPhase.clean) _buildCleanPhase(),
            if (_phase == MakeupPhase.applyMask) _buildMaskPhase(),
            if (_phase == MakeupPhase.removeMask) _buildGlowPhase(),
            if (_phase == MakeupPhase.complete) _buildCompletePhase(),
          ],
        ),
      ),
    );
  }

  Widget _buildZitPhase() {
    return Column(
      children: [
        const Text(
          'Puistjes Alert!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pop ze allemaal voordat de tijd om is!',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Face
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDBAC),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      MakeupAssets.faceNeutral,
                      width: 400,
                      height: 400,
                    ),
                  ),
                ),
              ),
              // Zits
              ..._zits.asMap().entries.map((entry) {
                int index = entry.key;
                Zit zit = entry.value;
                if (zit.isPopped) return const SizedBox.shrink();

                return Positioned(
                  left: 110 + zit.position.dx - zit.size / 2,
                  top: 110 + zit.position.dy - zit.size / 2,
                  child: GestureDetector(
                    onTap: () => _handleZitPop(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: zit.isPopping ? zit.size * 1.5 : zit.size,
                      height: zit.isPopping ? zit.size * 1.5 : zit.size,
                      child: Image.asset(
                        zit.isPopping
                            ? MakeupAssets.zitPopped
                            : MakeupAssets.zit,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              }),
              // Pop particles
              ..._particles.map((particle) {
                return Positioned(
                  left: particle.position.dx - 8,
                  top: particle.position.dy - 8,
                  child: Opacity(
                    opacity: particle.opacity.clamp(0.0, 1.0),
                    child: Image.asset(
                      MakeupAssets.sparkle,
                      width: 16,
                      height: 16,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildProgressBar(_poppedZits / _totalZits, AppConstants.danger),
        const SizedBox(height: 10),
        _buildProgressDots(_totalZits, _poppedZits, AppConstants.danger),
      ],
    );
  }

  Widget _buildPumpPhase() {
    return Column(
      children: [
        const Text(
          'Pump het product!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_pumpCount / $_requiredPumps',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryRed,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _handlePumpTap,
          child: AnimatedBuilder(
            animation: _pumpBounce,
            builder: (context, child) {
              return Transform.scale(
                scale: _pumpBounce.value,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppConstants.primaryRed,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryRed.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Image.asset(
                            MakeupAssets.pumpBottle,
                            width: 100,
                            height: 100,
                          ),
                          if (_pumpCount > 0)
                            Positioned(
                              top: 20,
                              right: -20,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 200),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Image.asset(
                                      MakeupAssets.productSpray,
                                      width: 30 + (value * 10),
                                      height: 30 + (value * 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app,
                                color: Colors.white, size: 28),
                            SizedBox(width: 10),
                            Text(
                              'PUMP!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        _buildProgressBar(_pumpCount / _requiredPumps, AppConstants.primaryRed),
      ],
    );
  }

  Widget _buildApplyPhase() {
    return Column(
      children: [
        const Text(
          'Breng de makeup aan!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_applicationCount / $_requiredApplications',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.accentGold,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTapDown: _handleFaceTap,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBAC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.accentGold.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  MakeupAssets.faceHappy,
                  width: 300,
                  height: 300,
                ),
                ..._makeupSpots.map((spot) {
                  return Positioned(
                    left: spot.dx - 15,
                    top: spot.dy - 15,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Image.asset(
                              MakeupAssets.sparkle,
                              width: 30,
                              height: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildProgressBar(
          _applicationCount / _requiredApplications,
          AppConstants.accentGold,
        ),
      ],
    );
  }

  Widget _buildCleanPhase() {
    return GestureDetector(
      onPanUpdate: _handleCleanSwipe,
      child: Column(
        children: [
          const Text(
            'Maak het gezicht schoon!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBAC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  MakeupAssets.faceRelaxed,
                  width: 300,
                  height: 300,
                ),
                Opacity(
                  opacity: (1 - _cleanProgress).clamp(0.0, 1.0),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryRed.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ..._bubbles.map((bubble) {
                  return Positioned(
                    left: bubble.dx - 15,
                    top: bubble.dy - 15,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -value * 20),
                          child: Opacity(
                            opacity: (1 - value).clamp(0.0, 1.0),
                            child: Image.asset(
                              MakeupAssets.bubble,
                              width: 20 + value * 10,
                              height: 20 + value * 10,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(MakeupAssets.arrowLeft, width: 32, height: 32),
              const SizedBox(width: 20),
              const Text(
                'Swipe!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Image.asset(MakeupAssets.arrowRight, width: 32, height: 32),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(_cleanProgress, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMaskPhase() {
    return Column(
      children: [
        const Text(
          'Tijd voor een masker!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 20),

        // Main game area
        SizedBox(
          height: 350,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Face with mask progress
              Positioned(
                top: 0,
                child: GestureDetector(
                  onPanUpdate: _handleMaskSpread,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBAC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.success.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Base face
                        Image.asset(
                          _leftCucumberPlaced && _rightCucumberPlaced
                              ? MakeupAssets.faceWithCucumbers
                              : MakeupAssets.faceRelaxed,
                          width: 300,
                          height: 300,
                        ),

                        // Mask overlay (shows progress)
                        if (_leftCucumberPlaced && _rightCucumberPlaced)
                          Opacity(
                            opacity: _maskSpreadProgress.clamp(0.0, 0.7),
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: AppConstants.success.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                        // Left eye drop zone
                        if (!_leftCucumberPlaced)
                          Positioned(
                            left: 55,
                            top: 80,
                            child: DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                if (details.data == 'left') {
                                  setState(() {
                                    _leftCucumberPlaced = true;
                                    _isDraggingLeftCucumber = false;
                                  });
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: candidateData.isNotEmpty
                                        ? AppConstants.success.withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? AppConstants.success
                                          : Colors.grey,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Right eye drop zone
                        if (!_rightCucumberPlaced)
                          Positioned(
                            right: 55,
                            top: 80,
                            child: DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                if (details.data == 'right') {
                                  setState(() {
                                    _rightCucumberPlaced = true;
                                    _isDraggingRightCucumber = false;
                                  });
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: candidateData.isNotEmpty
                                        ? AppConstants.success.withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? AppConstants.success
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Placed cucumbers on eyes
                        if (_leftCucumberPlaced)
                          Positioned(
                            left: 55,
                            top: 80,
                            child: Image.asset(
                              MakeupAssets.cucumber,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        if (_rightCucumberPlaced)
                          Positioned(
                            right: 55,
                            top: 80,
                            child: Image.asset(
                              MakeupAssets.cucumber,
                              width: 50,
                              height: 50,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Cucumber sources at bottom
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left cucumber to drag
                    if (!_leftCucumberPlaced)
                      Draggable<String>(
                        data: 'left',
                        feedback: Image.asset(
                          MakeupAssets.cucumber,
                          width: 60,
                          height: 60,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.success,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),

                    const SizedBox(width: 40),

                    // Right cucumber to drag
                    if (!_rightCucumberPlaced)
                      Draggable<String>(
                        data: 'right',
                        feedback: Image.asset(
                          MakeupAssets.cucumber,
                          width: 60,
                          height: 60,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.success,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Progress section
        if (_leftCucumberPlaced && _rightCucumberPlaced) ...[
          const Text(
            'Swipe in cirkels om het masker uit te smeren!',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _buildProgressBar(_maskSpreadProgress, AppConstants.success),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _leftCucumberPlaced
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: _leftCucumberPlaced ? AppConstants.success : Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text('Linker oog'),
              const SizedBox(width: 24),
              Icon(
                _rightCucumberPlaced
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color:
                    _rightCucumberPlaced ? AppConstants.success : Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text('Rechter oog'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGlowPhase() {
    return GestureDetector(
      onTap: _handleTimingTap,
      child: Column(
        children: [
          const Text(
            'Perfect Timing!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _timingSuccess ? 'Geweldig!' : 'Stop de balk in het groene gebied!',
            style: TextStyle(
              fontSize: 16,
              color: _timingSuccess
                  ? AppConstants.success
                  : AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 30),

          // Timing bar game
          Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.textSecondary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Target zone (center)
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppConstants.success.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppConstants.success,
                        width: 3,
                      ),
                    ),
                  ),
                ),

                // Moving indicator
                AnimatedBuilder(
                  animation: _timingBarController,
                  builder: (context, child) {
                    // Position from -1 to 1 mapped to actual pixels
                    double indicatorX = 150 + (_timingBarPosition * 120);

                    return Positioned(
                      left: indicatorX - 8,
                      top: 10,
                      child: Container(
                        width: 16,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _timingSuccess
                              ? AppConstants.success
                              : AppConstants.primaryRed,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (_timingSuccess
                                      ? AppConstants.success
                                      : AppConstants.primaryRed)
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feedback message
          if (_timingFeedback != null)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _timingSuccess
                          ? AppConstants.success
                          : AppConstants.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timingFeedback!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Cooldown indicator
          if (!_canTapTiming && !_timingSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppConstants.warning),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Wacht even...',
                    style: TextStyle(
                      color: AppConstants.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          // Tap button
          if (!_timingSuccess)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: _canTapTiming ? AppConstants.accentGold : Colors.grey,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _canTapTiming
                    ? [
                        BoxShadow(
                          color: AppConstants.accentGold.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: _canTapTiming ? Colors.white : Colors.grey[400],
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'TAP!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _canTapTiming ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

          if (_timingAttempts > 0 && !_timingSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Pogingen: $_timingAttempts',
                style: const TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletePhase() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.accentGold,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.accentGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'PRACHTIG!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(8, (index) {
                          double angle = (index / 8) * 2 * pi;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 500 + (index * 100),
                            ),
                            builder: (context, animValue, child) {
                              return Transform.translate(
                                offset: Offset(
                                  cos(angle) * 70 * animValue,
                                  sin(angle) * 70 * animValue,
                                ),
                                child: Opacity(
                                  opacity: animValue,
                                  child: Image.asset(
                                    MakeupAssets.sparkle,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        Image.asset(
                          MakeupAssets.crown,
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.success,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Klaar in ${90 - _timeRemaining} seconden!',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppConstants.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double progress, Color color) {
    return Container(
      width: 250,
      height: 16,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 250 * progress.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots(int total, int completed, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isCompleted = index < completed;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted
                ? color
                : AppConstants.textSecondary.withOpacity(0.3),
            size: 20,
          ),
        );
      }),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _getPhaseColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPhaseColor(),
            width: 2,
          ),
        ),
        child: Text(
          _getPhaseInstruction(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
