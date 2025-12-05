import 'package:flutter/material.dart';
import 'package:sinterklaas_mini_games/widgets/congratulations_overlay.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../models/game_state.dart';

enum KindleGamePhase { intro, transition, playing }

class KindleGame extends StatefulWidget {
  final GameStateManager gameState;

  const KindleGame({super.key, required this.gameState});

  @override
  State<KindleGame> createState() => _KindleGameState();
}

class _KindleGameState extends State<KindleGame> with TickerProviderStateMixin {
  KindleGamePhase _phase = KindleGamePhase.intro;
  int _currentPage = 1;
  final int _targetPages = AppConstants.kindleTargetPages;
  int _timeRemaining = AppConstants.kindleTimeSeconds;
  Timer? _timer;
  bool _buttonPressed = false;

  // Animation controllers
  late AnimationController _transitionController;
  late AnimationController _kindleAppearController;
  late AnimationController _pulseController;
  late AnimationController _pageFlipController;
  late AnimationController
      _sisterPressController; // NEW: For sister press animation

  // Animations
  late Animation<double> _standingFadeOut;
  late Animation<double> _sittingFadeIn;
  late Animation<Offset> _kindleSlideIn;
  late Animation<double> _kindleScale;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pageFlipScale;
  late Animation<double> _sisterPressScale; // NEW: Subtle scale on press

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Transition from standing to sitting
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _standingFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _sittingFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    // Kindle appearing
    _kindleAppearController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _kindleSlideIn = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _kindleAppearController,
      curve: Curves.elasticOut,
    ));

    _kindleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _kindleAppearController,
        curve: Curves.easeOutBack,
      ),
    );

    // Couch pulse animation for intro
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Page flip feedback
    _pageFlipController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _pageFlipScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pageFlipController, curve: Curves.easeInOut),
    );

    // NEW: Sister press animation - subtle scale effect
    _sisterPressController = AnimationController(
      duration: const Duration(milliseconds: 30), // Very fast for rapid tapping
      vsync: this,
    );

    _sisterPressScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _sisterPressController, curve: Curves.easeInOut),
    );
  }

  void _onTapCouch() {
    if (_phase != KindleGamePhase.intro) return;

    _pulseController.stop();

    setState(() {
      _phase = KindleGamePhase.transition;
    });

    // Sister sits down
    _transitionController.forward().then((_) {
      // Kindle appears
      _kindleAppearController.forward().then((_) {
        setState(() {
          _phase = KindleGamePhase.playing;
        });
        _startTimer();
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _timer?.cancel();
          _showResult(false);
        }
      });
    });
  }

  // Fast tap handler - using Listener for zero debounce
  void _onTapDown() {
    if (_phase != KindleGamePhase.playing) return;

    setState(() {
      _buttonPressed = true;
      _currentPage++;
    });

    // Quick scale animations
    _pageFlipController.forward();
    _sisterPressController.forward(); // NEW: Animate sister

    if (_currentPage >= _targetPages) {
      _timer?.cancel();
      _showResult(true);
    }
  }

  void _onTapUp() {
    setState(() {
      _buttonPressed = false;
    });
    _pageFlipController.reverse();
    _sisterPressController.reverse(); // NEW: Reset sister animation
  }

  void _showResult(bool won) {
    if (won) {
      CongratulationsOverlay.show(
        context: context,
        title: '🎉 Gelukt!',
        emoji: '📖',
        message: 'Hint voor de volgende code:\n\n${AppConstants.hintPopcorn}',
        giftMessage: 'Kindle Page Turner',
        buttonText: 'Terug naar start',
        buttonColor: AppConstants.success,
        onButtonPressed: () {
          widget.gameState.completeGame('kindle', 'Kindle Page Turner 📖');
          Navigator.of(context).pop();
        },
      );
    } else {
      // For failure, use a simpler dialog without waving animation
      CongratulationsOverlay.show(
        context: context,
        title: '😅 Helaas!',
        emoji: '📚',
        message:
            'Je hebt $_currentPage van de $_targetPages pagina\'s gelezen.',
        buttonText: '🔄 Opnieuw proberen',
        buttonColor: AppConstants.warning,
        showWavingAnimation: false, // No waving on failure
        onButtonPressed: () {
          _resetGame();
        },
      );
    }
  }

  void _resetGame() {
    _transitionController.reset();
    _kindleAppearController.reset();
    _pulseController.repeat(reverse: true);

    setState(() {
      _phase = KindleGamePhase.intro;
      _currentPage = 1;
      _timeRemaining = AppConstants.kindleTimeSeconds;
      _buttonPressed = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _transitionController.dispose();
    _kindleAppearController.dispose();
    _pulseController.dispose();
    _pageFlipController.dispose();
    _sisterPressController.dispose(); // NEW: Don't forget to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header - only show during playing
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _phase == KindleGamePhase.playing ? null : 0,
                  child: _phase == KindleGamePhase.playing
                      ? _buildHeader()
                      : const SizedBox.shrink(),
                ),

                // Game area
                Expanded(
                  child: _buildGameArea(constraints),
                ),

                // Bottom area
                _buildBottomArea(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _currentPage / _targetPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _timeRemaining <= 10
                      ? AppConstants.danger
                      : AppConstants.warning,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_timeRemaining}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Page counter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.textSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$_currentPage / $_targetPages',
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0
                    ? AppConstants.success
                    : AppConstants.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    // Calculate responsive sizes
    final couchHeight = screenHeight * 0.35;
    final sisterStandingHeight = screenHeight * 0.5;
    final sisterSittingHeight = screenHeight * 0.4;
    final kindleHeight = screenHeight * 0.28;

    return Stack(
      fit: StackFit.expand,
      children: [
        // === INTRO PHASE: Standing sister + empty couch ===
        if (_phase == KindleGamePhase.intro) ...[
          // Empty couch (tappable with pulse)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _onTapCouch,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.accentGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/empty_couch.png',
                    height: couchHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Standing sister
          Positioned(
            bottom: couchHeight * 0.3,
            left: screenWidth * 0.05,
            child: Image.asset(
              'assets/sister_standing.png',
              height: sisterStandingHeight,
              fit: BoxFit.contain,
            ),
          ),

          // Instruction bubble
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildInstructionBubble(
              '👆 Tik op de bank!',
              'Ga lekker zitten om te lezen',
              Icons.weekend,
            ),
          ),
        ],

        // === TRANSITION & PLAYING: Sitting sister ===
        if (_phase == KindleGamePhase.transition ||
            _phase == KindleGamePhase.playing) ...[
          // Standing sister fading out
          if (_transitionController.value < 0.5)
            Positioned(
              bottom: couchHeight * 0.3,
              left: screenWidth * 0.05,
              child: AnimatedBuilder(
                animation: _standingFadeOut,
                builder: (context, child) {
                  return Opacity(
                    opacity: _standingFadeOut.value,
                    child: Image.asset(
                      'assets/sister_standing.png',
                      height: sisterStandingHeight,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

          // Sister sitting on couch - NOW WITH PRESS ANIMATION
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildSittingSister(sisterSittingHeight),
          ),

          // Kindle sliding in from top
          Positioned(
            top: _phase == KindleGamePhase.playing ? 20 : 40,
            right: 20,
            child: SlideTransition(
              position: _kindleSlideIn,
              child: ScaleTransition(
                scale: _kindleScale,
                child: _buildKindle(kindleHeight),
              ),
            ),
          ),
        ],

        // === PLAYING: Show "Get ready" then game ===
        if (_phase == KindleGamePhase.transition)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '📖',
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Maak je klaar...',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // NEW: Separate widget for sitting sister with press animation
  Widget _buildSittingSister(double height) {
    // During transition phase, show fade-in animation
    if (_phase == KindleGamePhase.transition) {
      return AnimatedBuilder(
        animation: _sittingFadeIn,
        builder: (context, child) {
          return Opacity(
            opacity: _sittingFadeIn.value,
            child: Image.asset(
              'assets/sister_sitting_couch.png',
              height: height,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    }

    // During playing phase, toggle between normal and pressing image
    return AnimatedBuilder(
      animation: _sisterPressScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _sisterPressScale.value,
          alignment:
              Alignment.bottomCenter, // Scale from bottom so she stays grounded
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 30), // Very fast switch
            child: Image.asset(
              _buttonPressed
                  ? 'assets/sister_sitting_couch_pressing.png'
                  : 'assets/sister_sitting_couch.png',
              key: ValueKey<bool>(
                  _buttonPressed), // Important for AnimatedSwitcher
              height: height,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildKindle(double height) {
    // Calculate relative dimensions based on the device height
    final screenWidth = height * 0.55;
    final screenHeight = height * 0.75;

    return AnimatedBuilder(
      animation: _pageFlipScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _pageFlipScale.value,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LAYER 1: The Screen Content (BEHIND the image)
          Positioned(
            top: -0,
            left: -1,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-0.6)
                ..rotateX(0.4)
                ..rotateZ(-0.02),
              child: Container(
                width: screenWidth,
                height: screenHeight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pagina',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        color: Colors.grey[600],
                        fontSize: height * 0.06,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '$_currentPage',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        color: Colors.black87,
                        fontSize: height * 0.18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          Image.asset(
            'assets/kindle.png',
            height: height,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBubble(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryRed.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    if (_phase == KindleGamePhase.playing) {
      return _buildTapButton();
    }

    return Container(
      padding: const EdgeInsets.all(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTapButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Listener(
        onPointerDown: (_) => _onTapDown(),
        onPointerUp: (_) => _onTapUp(),
        onPointerCancel: (_) => _onTapUp(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: _buttonPressed
                ? AppConstants.primaryRed.withValues(alpha: 0.9)
                : AppConstants.primaryRed,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryRed
                    .withValues(alpha: _buttonPressed ? 0.2 : 0.4),
                blurRadius: _buttonPressed ? 5 : 15,
                offset: Offset(0, _buttonPressed ? 2 : 4),
              ),
            ],
          ),
          transform: Matrix4.translationValues(0, _buttonPressed ? 4 : 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                child: Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: _buttonPressed ? 40 : 50,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '📖 TAP OM PAGINA OM TE SLAAN!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
