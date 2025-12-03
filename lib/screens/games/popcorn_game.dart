// lib/screens/games/popcorn_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/constants.dart';
import '../../models/game_state.dart';
import '../../widgets/congratulations_overlay.dart';

enum PopcornPhase { dragSeeds, machineShaking, catchPopcorn, complete }

class PopcornGame extends StatefulWidget {
  final GameStateManager gameState;

  const PopcornGame({super.key, required this.gameState});

  @override
  State<PopcornGame> createState() => _PopcornGameState();
}

class _PopcornGameState extends State<PopcornGame>
    with TickerProviderStateMixin {
  PopcornPhase _phase = PopcornPhase.dragSeeds;
  int _popcornCaught = 0;
  final int _popcornTarget = AppConstants.popcornTarget;
  int _timeRemaining = AppConstants.popcornTimeSeconds;
  Timer? _timer;
  Timer? _spawnTimer;

  // Machine shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Bowl animation
  late AnimationController _bowlBounceController;
  late Animation<double> _bowlBounceAnimation;

  // Falling popcorn with their own controllers
  final List<FallingPopcornData> _fallingPopcorn = [];
  final Random _random = Random();

  // Seeds drag position
  Offset _seedsPosition = Offset.zero;
  bool _isDraggingSeeds = false;
  bool _seedsDropped = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Machine shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Bowl bounce animation
    _bowlBounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bowlBounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bowlBounceController, curve: Curves.easeOut),
    );
  }

  void _startMachineShake() {
    setState(() {
      _phase = PopcornPhase.machineShaking;
    });

    // Shake for 2 seconds then start popcorn
    int shakeCount = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _shakeController.forward().then((_) => _shakeController.reverse());
      shakeCount++;

      if (shakeCount >= 20) {
        timer.cancel();
        _startPopcornPhase();
      }
    });
  }

  void _startPopcornPhase() {
    setState(() {
      _phase = PopcornPhase.catchPopcorn;
    });

    // Start game timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          timer.cancel();
          _spawnTimer?.cancel();
          _endGame();
        }
      });
    });

    // Spawn popcorn periodically
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted || _phase != PopcornPhase.catchPopcorn) {
        timer.cancel();
        return;
      }
      _spawnPopcorn();
    });

    // Spawn first popcorn immediately
    _spawnPopcorn();
  }

  void _spawnPopcorn() {
    if (_fallingPopcorn.length >= 6) return; // Max 6 on screen

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Spawn from machine area (top center)
    final startX = (_random.nextDouble() * screenWidth - 20) + 10;

    // Create animation controller for this popcorn
    final controller = AnimationController(
      duration: Duration(milliseconds: 1500 + _random.nextInt(1500)),
      vsync: this,
    );

    // Horizontal wobble
    final wobbleController = AnimationController(
      duration: Duration(milliseconds: 600 + _random.nextInt(150)),
      vsync: this,
    )..repeat(reverse: true);

    // Rotation
    final rotationController = AnimationController(
      duration: Duration(milliseconds: 1200 + _random.nextInt(500)),
      vsync: this,
    )..repeat();

    final popcorn = FallingPopcornData(
      id: DateTime.now().microsecondsSinceEpoch.toString() +
          _random.nextInt(1000).toString(),
      startX: startX,
      startY: 0, // Start from machine
      endY: screenHeight + 50,
      fallController: controller,
      wobbleController: wobbleController,
      rotationController: rotationController,
      wobbleAmount: 20 + _random.nextDouble() * 50,
      useAltImage: _random.nextBool(),
    );

    setState(() {
      _fallingPopcorn.add(popcorn);
    });

    controller.forward();

    // Remove when animation completes
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removePopcorn(popcorn.id);
      }
    });
  }

  void _catchPopcorn(String id) {
    final popcorn = _fallingPopcorn.firstWhere(
      (p) => p.id == id,
      orElse: () => FallingPopcornData.empty(),
    );

    if (popcorn.id.isEmpty) return;

    setState(() {
      _popcornCaught++;
    });

    // Bowl bounce feedback
    _bowlBounceController.forward().then((_) {
      _bowlBounceController.reverse();
    });

    _removePopcorn(id);

    // Check win condition
    if (_popcornCaught >= _popcornTarget) {
      _timer?.cancel();
      _spawnTimer?.cancel();
      _endGame();
    }
  }

  void _removePopcorn(String id) {
    final index = _fallingPopcorn.indexWhere((p) => p.id == id);
    if (index != -1) {
      final popcorn = _fallingPopcorn[index];
      popcorn.fallController.dispose();
      popcorn.wobbleController.dispose();
      popcorn.rotationController.dispose();
      setState(() {
        _fallingPopcorn.removeAt(index);
      });
    }
  }

  void _endGame() {
    // Clean up remaining popcorn
    for (var popcorn in _fallingPopcorn) {
      popcorn.fallController.dispose();
      popcorn.wobbleController.dispose();
      popcorn.rotationController.dispose();
    }
    _fallingPopcorn.clear();

    setState(() {
      _phase = PopcornPhase.complete;
    });

    _showResult();
  }

  void _showResult() {
    final won = _popcornCaught >= _popcornTarget;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (won) {
        CongratulationsOverlay.show(
          context: context,
          title: '🎉 Gelukt!',
          emoji: '🍿',
          message: 'Hint voor de volgende code:\n\n${AppConstants.hintMakeup}',
          giftMessage: 'Popcorn Maker',
          buttonText: 'Terug naar start',
          buttonColor: AppConstants.success,
          onButtonPressed: () {
            widget.gameState.completeGame('popcorn', 'Popcorn Maker 🍿');
            Navigator.of(context).pop();
          },
        );
      } else {
        CongratulationsOverlay.show(
          context: context,
          title: '😅 Helaas!',
          emoji: '🍿',
          message:
              'Je hebt $_popcornCaught van de $_popcornTarget popcorn gevangen.',
          buttonText: '🔄 Opnieuw proberen',
          buttonColor: AppConstants.warning,
          showWavingAnimation: false,
          onButtonPressed: () {
            _resetGame();
          },
        );
      }
    });
  }

  void _resetGame() {
    _timer?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _phase = PopcornPhase.dragSeeds;
      _popcornCaught = 0;
      _timeRemaining = AppConstants.popcornTimeSeconds;
      _fallingPopcorn.clear();
      _seedsDropped = false;
      _isDraggingSeeds = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnTimer?.cancel();
    _shakeController.dispose();
    _bowlBounceController.dispose();
    for (var popcorn in _fallingPopcorn) {
      popcorn.fallController.dispose();
      popcorn.wobbleController.dispose();
      popcorn.rotationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: _buildCurrentPhase(),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case PopcornPhase.dragSeeds:
        return _buildDragSeedsPhase();
      case PopcornPhase.machineShaking:
        return _buildMachineShakingPhase();
      case PopcornPhase.catchPopcorn:
        return _buildCatchPhase();
      case PopcornPhase.complete:
        return _buildCompletePhase();
    }
  }

  Widget _buildDragSeedsPhase() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final machineY = constraints.maxHeight * 0.35;
        final seedsStartY = constraints.maxHeight * 0.7;
        final machineRect = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, machineY),
          width: 180,
          height: 200,
        );

        return Stack(
          children: [
            // Instruction
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Text('🌽', style: TextStyle(fontSize: 30)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sleep de zaden naar de machine!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Popcorn machine
            Positioned(
              top: machineY - 100,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/popcorn_maker.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Drop zone indicator
            Positioned(
              top: machineY - 80,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isDraggingSeeds
                        ? AppConstants.accentGold.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isDraggingSeeds
                          ? AppConstants.accentGold
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),

            // Seeds bag (draggable)
            if (!_seedsDropped)
              Positioned(
                left: _isDraggingSeeds
                    ? _seedsPosition.dx - 60
                    : constraints.maxWidth / 2 - 60,
                top: _isDraggingSeeds ? _seedsPosition.dy - 75 : seedsStartY,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isDraggingSeeds = true;
                      _seedsPosition = details.globalPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _seedsPosition = details.globalPosition;
                    });
                  },
                  onPanEnd: (details) {
                    // Check if dropped on machine
                    if (machineRect.contains(_seedsPosition)) {
                      setState(() {
                        _seedsDropped = true;
                      });
                      _startMachineShake();
                    } else {
                      setState(() {
                        _isDraggingSeeds = false;
                      });
                    }
                  },
                  child: AnimatedScale(
                    scale: _isDraggingSeeds ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/popcorn_seeds.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        if (!_isDraggingSeeds)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '👆 Sleep mij!',
                              style: TextStyle(
                                color: AppConstants.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Arrow indicator
            if (!_isDraggingSeeds && !_seedsDropped)
              Positioned(
                top: machineY + 60,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 20),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  onEnd: () {},
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 50,
                    color: AppConstants.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMachineShakingPhase() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Loading text
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation(AppConstants.primaryRed),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Popcorn wordt gemaakt...',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Shaking machine
            Center(
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/popcorn_maker.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Steam/heat effect
            Positioned(
              top: constraints.maxHeight * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value * 0.6,
                      child: Transform.scale(
                        scale: 0.8 + value * 0.4,
                        child: const Text(
                          '💨',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    );
                  },
                  onEnd: () {},
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCatchPhase() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // final bowlY = constraints.maxHeight - 180; // Unused

        return Stack(
          children: [
            // Header with timer and score
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _timeRemaining <= 5
                          ? AppConstants.danger
                          : AppConstants.warning,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${_timeRemaining}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _popcornCaught >= _popcornTarget
                            ? AppConstants.success
                            : AppConstants.textSecondary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🍿', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '$_popcornCaught / $_popcornTarget',
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Popcorn machine at top (smaller)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * 0.5, 0),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/popcorn_maker.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Falling popcorn
            ..._fallingPopcorn.map((popcorn) => _buildFallingPopcorn(popcorn)),

            // Bowl at bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _bowlBounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bowlBounceAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      // Show collected popcorn in bowl
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            _popcornCaught > 0
                                ? 'assets/popcorn_bowl.png'
                                : 'assets/empty_bowl.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '👆 Tik op de popcorn!',
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallingPopcorn(FallingPopcornData popcorn) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        popcorn.fallController,
        popcorn.wobbleController,
        popcorn.rotationController,
      ]),
      builder: (context, child) {
        final fallProgress =
            Curves.easeIn.transform(popcorn.fallController.value);
        final currentY =
            popcorn.startY + (popcorn.endY - popcorn.startY) * fallProgress;

        final wobble =
            sin(popcorn.wobbleController.value * pi * 2) * popcorn.wobbleAmount;
        final currentX = popcorn.startX + wobble;

        final rotation = popcorn.rotationController.value * pi * 4;

        // Larger hitbox for easier tapping (especially on mobile)
        const double hitboxSize = 100; // Tap area size
        const double visualSize = 50; // Visual popcorn size (unchanged)

        return Positioned(
          left: currentX - hitboxSize / 2,
          top: currentY - hitboxSize / 2,
          child: GestureDetector(
            onTapDown: (_) => _catchPopcorn(popcorn.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: hitboxSize,
              height: hitboxSize,
              alignment: Alignment.center,
              // Debug: uncomment to see hitbox
              // color: Colors.red.withOpacity(0.2),
              child: Transform.rotate(
                angle: rotation,
                child: Image.asset(
                  popcorn.useAltImage
                      ? 'assets/popcorn_1.png'
                      : 'assets/popcorn_2.png',
                  width: visualSize,
                  height: visualSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletePhase() {
    final won = _popcornCaught >= _popcornTarget;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show full bowl
          Image.asset(
            won ? 'assets/popcorn_bowl.png' : 'assets/empty_bowl.png',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            won ? '🎉' : '😅',
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 10),
          Text(
            '$_popcornCaught popcorn gevangen!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for falling popcorn with smooth animations
class FallingPopcornData {
  final String id;
  final double startX;
  final double startY;
  final double endY;
  final AnimationController fallController;
  final AnimationController wobbleController;
  final AnimationController rotationController;
  final double wobbleAmount;
  final bool useAltImage;

  FallingPopcornData({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endY,
    required this.fallController,
    required this.wobbleController,
    required this.rotationController,
    required this.wobbleAmount,
    required this.useAltImage,
  });

  // Empty constructor for null safety
  factory FallingPopcornData.empty() {
    return FallingPopcornData(
      id: '',
      startX: 0,
      startY: 0,
      endY: 0,
      fallController: AnimationController(vsync: _EmptyTickerProvider()),
      wobbleController: AnimationController(vsync: _EmptyTickerProvider()),
      rotationController: AnimationController(vsync: _EmptyTickerProvider()),
      wobbleAmount: 0,
      useAltImage: false,
    );
  }
}

// Helper class for empty FallingPopcornData
class _EmptyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
