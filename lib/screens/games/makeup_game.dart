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

  double _maskSpreadProgress = 0;

  // Glow phase - timing game (improved)
  late AnimationController _timingBarController;
  double _timingBarPosition = 0; // -1 to 1
  bool _canTapTiming = true;
  int _timingAttempts = 0;
  bool _timingSuccess = false;
  String? _timingFeedback;

  // Improved timing game settings
  final double _targetZoneSize = 0.25; // Size of target zone (-0.25 to 0.25)
  final double _initialBarSpeed =
      500; // Initial duration in ms (slower = easier)
  double _currentBarSpeed = 500;
  bool _barMovingRight = true;
  double _lastTapPosition = 0;

  // Timer
  int _timeRemaining = 22;
  bool _gameOver = false;
  bool _gameWon = false;

  // Animations
  late AnimationController _pumpAnimController;
  late AnimationController _shakeController;

  late AnimationController _timerPulseController;
  late AnimationController _particleController;

  late Animation<double> _pumpBounce;
  late Animation<double> _shakeAnimation;

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

    // Improved timing bar - linear back and forth movement
    _timingBarController = AnimationController(
      duration: Duration(milliseconds: _initialBarSpeed.toInt()),
      vsync: this,
    )..addListener(_updateTimingBar);
  }

  void _updateTimingBar() {
    if (_phase != MakeupPhase.removeMask || _timingSuccess || _gameOver) return;

    setState(() {
      // Linear movement from -1 to 1 and back
      double progress = _timingBarController.value;

      if (_barMovingRight) {
        _timingBarPosition = -1 + (progress * 2);
      } else {
        _timingBarPosition = 1 - (progress * 2);
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
      _timeRemaining = 22;
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
      _currentBarSpeed = _initialBarSpeed;
      _barMovingRight = true;
      _initializeZits();
    });
    _shakeController.reset();
    _timingBarController.reset();
    _timingBarController.duration =
        Duration(milliseconds: _initialBarSpeed.toInt());
    _startTimer();
  }

  @override
  void dispose() {
    _pumpAnimController.dispose();
    _shakeController.dispose();

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
        return 'Pop alle puistjes! ($_poppedZits/$_totalZits)';
      case MakeupPhase.pump:
        return 'Pump het product! ($_pumpCount/$_requiredPumps)';
      case MakeupPhase.apply:
        return 'Breng makeup aan! ($_applicationCount/$_requiredApplications)';
      case MakeupPhase.clean:
        return 'Swipe om schoon te maken!';
      case MakeupPhase.applyMask:
        if (!_leftCucumberPlaced || !_rightCucumberPlaced) {
          return 'Sleep komkommers naar de ogen!';
        } else {
          return 'Swipe om masker uit te smeren!';
        }
      case MakeupPhase.removeMask:
        if (_timingSuccess) {
          return 'Perfect timing! ✨';
        }
        return 'Stop in het groene gebied!';
      case MakeupPhase.complete:
        return 'Perfect! Je bent klaar! 💄';
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
      _cleanProgress +=
          (details.delta.dx.abs() + details.delta.dy.abs()) / 2000;

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
          (details.delta.dx.abs() + details.delta.dy.abs()) / 2000;

      if (_maskSpreadProgress >= 1) {
        _startGlowPhase();
      }
    });
  }

  void _startGlowPhase() {
    setState(() {
      _phase = MakeupPhase.removeMask;
      _timingBarPosition = -1;
      _canTapTiming = true;
      _timingSuccess = false;
      _barMovingRight = true;
      _currentBarSpeed = _initialBarSpeed;
    });
    _timingBarController.duration =
        Duration(milliseconds: _currentBarSpeed.toInt());
    _timingBarController.reset();
    _startTimingBarLoop();
  }

  void _startTimingBarLoop() {
    if (_timingSuccess || _gameOver || _phase != MakeupPhase.removeMask) return;

    _timingBarController.forward().then((_) {
      if (!mounted || _timingSuccess || _gameOver) return;

      setState(() {
        _barMovingRight = !_barMovingRight;
      });
      _timingBarController.reset();
      _startTimingBarLoop();
    });
  }

  void _handleTimingTap() {
    if (_phase != MakeupPhase.removeMask || _gameOver) return;
    if (!_canTapTiming || _timingSuccess) return;

    // Store the position at tap moment for accurate detection
    _lastTapPosition = _timingBarPosition;

    setState(() {
      _timingAttempts++;

      // Check if within target zone with improved detection
      bool isInTargetZone = _lastTapPosition.abs() <= _targetZoneSize;

      // Add small tolerance for edge cases
      double tolerance = 0.05;
      bool isNearTargetZone =
          _lastTapPosition.abs() <= (_targetZoneSize + tolerance);

      if (isInTargetZone) {
        // Perfect hit!
        _timingSuccess = true;
        _timingFeedback = 'PERFECT! 🎉';
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
      } else if (isNearTargetZone) {
        // Close but not quite - give another immediate chance
        _timingFeedback = 'BIJNA! 💫';

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _phase == MakeupPhase.removeMask && !_timingSuccess) {
            setState(() {
              _timingFeedback = null;
            });
          }
        });
      } else {
        // Miss - disable tapping briefly
        _canTapTiming = false;
        _timingFeedback = 'GEMIST! ❌';

        // Speed up the bar slightly after each miss (but not too much)
        _currentBarSpeed = max(800, _currentBarSpeed - 100);
        _timingBarController.duration =
            Duration(milliseconds: _currentBarSpeed.toInt());

        Future.delayed(const Duration(milliseconds: 1200), () {
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
            'Je hebt het in ${22 - _timeRemaining} seconden gehaald!\n\nHint voor de volgende code:\n${AppConstants.hintFinalCodeLocation}',
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeaderBar(), // Combined timer and instructions
                Expanded(
                  child: _buildGameArea(),
                ),
              ],
            ),
            if (_gameOver && !_gameWon) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  // NEW: Combined header with timer and instructions horizontally
  Widget _buildHeaderBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Timer (compact)
          AnimatedBuilder(
            animation: _timerPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _timeRemaining <= 10 ? _timerPulse.value : 1.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getTimerColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getTimerColor(),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _timeRemaining <= 10
                            ? Icons.warning_rounded
                            : Icons.timer_rounded,
                        color: _getTimerColor(),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_timeRemaining',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _getTimerColor(),
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        's',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTimerColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          // Instructions (expanded)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _getPhaseColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
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
      color: AppConstants.textSecondary.withValues(alpha: 0.3),
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
                      : AppConstants.textSecondary.withValues(alpha: 0.3),
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
            color: Colors.black.withValues(alpha: 0.9),
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
                        'Je deed er te lang over!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
        const SizedBox(height: 20),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_pumpCount / $_requiredPumps',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryRed,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _handlePumpTap,
          child: AnimatedBuilder(
            animation: _pumpBounce,
            builder: (context, child) {
              return Transform.scale(
                scale: _pumpBounce.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppConstants.primaryRed,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryRed.withValues(alpha: 0.2),
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
                            width: 80,
                            height: 80,
                          ),
                          if (_pumpCount > 0)
                            Positioned(
                              top: 15,
                              right: -15,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 200),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Image.asset(
                                      MakeupAssets.productSpray,
                                      width: 25 + (value * 8),
                                      height: 25 + (value * 8),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app,
                                color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'PUMP!',
                              style: TextStyle(
                                fontSize: 20,
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
        const SizedBox(height: 20),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_applicationCount / $_requiredApplications',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.accentGold,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTapDown: _handleFaceTap,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBAC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.accentGold.withValues(alpha: 0.3),
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
                  width: 280,
                  height: 280,
                ),
                ..._makeupSpots.map((spot) {
                  return Positioned(
                    left: spot.dx - 12,
                    top: spot.dy - 12,
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
                              width: 24,
                              height: 24,
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
        const SizedBox(height: 20),
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
            'Maak schoon!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBAC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
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
                  width: 280,
                  height: 280,
                ),
                Opacity(
                  opacity: (1 - _cleanProgress).clamp(0.0, 1.0),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryRed.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ..._bubbles.map((bubble) {
                  return Positioned(
                    left: bubble.dx - 12,
                    top: bubble.dy - 12,
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
                              width: 16 + value * 8,
                              height: 16 + value * 8,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(MakeupAssets.arrowLeft, width: 28, height: 28),
              const SizedBox(width: 16),
              const Text(
                'Swipe!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(MakeupAssets.arrowRight, width: 28, height: 28),
            ],
          ),
          const SizedBox(height: 16),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Main game area
        SizedBox(
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Face with mask progress
              Positioned(
                top: 0,
                child: GestureDetector(
                  onPanUpdate: _handleMaskSpread,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBAC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.success.withValues(alpha: 0.2),
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
                          width: 280,
                          height: 280,
                        ),

                        // Mask overlay (shows progress)
                        if (_leftCucumberPlaced && _rightCucumberPlaced)
                          Opacity(
                            opacity: _maskSpreadProgress.clamp(0.0, 0.7),
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color:
                                    AppConstants.success.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                        // Left eye drop zone
                        if (!_leftCucumberPlaced)
                          Positioned(
                            left: 50,
                            top: 70,
                            child: DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                if (details.data == 'left') {
                                  setState(() {
                                    _leftCucumberPlaced = true;
                                  });
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: candidateData.isNotEmpty
                                        ? AppConstants.success
                                            .withValues(alpha: 0.5)
                                        : Colors.grey.withValues(alpha: 0.3),
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
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Right eye drop zone
                        if (!_rightCucumberPlaced)
                          Positioned(
                            right: 50,
                            top: 70,
                            child: DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                if (details.data == 'right') {
                                  setState(() {
                                    _rightCucumberPlaced = true;
                                  });
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: candidateData.isNotEmpty
                                        ? AppConstants.success
                                            .withValues(alpha: 0.5)
                                        : Colors.grey.withValues(alpha: 0.3),
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
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Placed cucumbers on eyes
                        if (_leftCucumberPlaced)
                          Positioned(
                            left: 50,
                            top: 70,
                            child: Image.asset(
                              MakeupAssets.cucumber,
                              width: 45,
                              height: 45,
                            ),
                          ),
                        if (_rightCucumberPlaced)
                          Positioned(
                            right: 50,
                            top: 70,
                            child: Image.asset(
                              MakeupAssets.cucumber,
                              width: 45,
                              height: 45,
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
                          width: 50,
                          height: 50,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 50,
                            height: 50,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),

                    const SizedBox(width: 30),

                    // Right cucumber to drag
                    if (!_rightCucumberPlaced)
                      Draggable<String>(
                        data: 'right',
                        feedback: Image.asset(
                          MakeupAssets.cucumber,
                          width: 50,
                          height: 50,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            MakeupAssets.cucumber,
                            width: 50,
                            height: 50,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Progress section
        if (_leftCucumberPlaced && _rightCucumberPlaced) ...[
          const Text(
            'Swipe in cirkels!',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
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
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text('Links', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              Icon(
                _rightCucumberPlaced
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color:
                    _rightCucumberPlaced ? AppConstants.success : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text('Rechts', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }

  // IMPROVED: More robust timing game
  Widget _buildGlowPhase() {
    return GestureDetector(
      onTap: _handleTimingTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const Text(
            'Perfect Timing!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Timing bar game - IMPROVED
          Container(
            width: 280,
            height: 70,
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.textSecondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Red zones on sides
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 280 * (0.5 - _targetZoneSize / 2),
                    decoration: BoxDecoration(
                      color: AppConstants.danger.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 280 * (0.5 - _targetZoneSize / 2),
                    decoration: BoxDecoration(
                      color: AppConstants.danger.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Target zone (center) - larger and more visible
                Center(
                  child: Container(
                    width: 280 * _targetZoneSize,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppConstants.success.withValues(alpha: 0.4),
                      border: Border.all(
                        color: AppConstants.success,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: AppConstants.success.withValues(alpha: 0.5),
                        size: 30,
                      ),
                    ),
                  ),
                ),

                // Moving indicator - more visible
                AnimatedBuilder(
                  animation: _timingBarController,
                  builder: (context, child) {
                    // Position from -1 to 1 mapped to actual pixels
                    double indicatorX = 140 + (_timingBarPosition * 120);

                    return Positioned(
                      left: indicatorX - 10,
                      top: 5,
                      child: Container(
                        width: 20,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _timingSuccess
                              ? AppConstants.success
                              : _canTapTiming
                                  ? AppConstants.primaryRed
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: (_timingSuccess
                                      ? AppConstants.success
                                      : AppConstants.primaryRed)
                                  .withValues(alpha: 0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Feedback message
          SizedBox(
            height: 50,
            child: _timingFeedback != null
                ? TweenAnimationBuilder<double>(
                    key: ValueKey(_timingFeedback),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _timingSuccess
                                ? AppConstants.success
                                : _timingFeedback == 'BIJNA! 💫'
                                    ? AppConstants.warning
                                    : AppConstants.danger,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _timingFeedback!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          // Cooldown indicator
          if (!_canTapTiming && !_timingSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppConstants.warning),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wacht...',
                    style: TextStyle(
                      color: AppConstants.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Tap button - bigger and more obvious
          if (!_timingSuccess)
            GestureDetector(
              onTap: _handleTimingTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                decoration: BoxDecoration(
                  color: _canTapTiming ? AppConstants.accentGold : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _canTapTiming
                      ? [
                          BoxShadow(
                            color:
                                AppConstants.accentGold.withValues(alpha: 0.5),
                            blurRadius: 12,
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
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TAP NU!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _canTapTiming ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_timingAttempts > 0 && !_timingSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Pogingen: $_timingAttempts',
                style: const TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 12,
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
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.accentGold,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.accentGold.withValues(alpha: 0.3),
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
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                  cos(angle) * 60 * animValue,
                                  sin(angle) * 60 * animValue,
                                ),
                                child: Opacity(
                                  opacity: animValue,
                                  child: Image.asset(
                                    MakeupAssets.sparkle,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        Image.asset(
                          MakeupAssets.crown,
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.success,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Klaar in ${22 - _timeRemaining} seconden!',
                        style: const TextStyle(
                          fontSize: 16,
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
      width: 220,
      height: 14,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220 * progress.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
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
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted
                ? color
                : AppConstants.textSecondary.withValues(alpha: 0.3),
            size: 18,
          ),
        );
      }),
    );
  }
}
