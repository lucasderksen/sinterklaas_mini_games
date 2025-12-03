// lib/widgets/congratulations_overlay.dart
import 'package:flutter/material.dart';
import 'waving_dad_child.dart';
import '../utils/constants.dart';

class CongratulationsOverlay extends StatefulWidget {
  final String title;
  final String emoji;
  final String message;
  final String? giftMessage;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color buttonColor;
  final bool showWavingAnimation;

  const CongratulationsOverlay({
    super.key,
    required this.title,
    required this.emoji,
    required this.message,
    this.giftMessage,
    required this.buttonText,
    required this.onButtonPressed,
    this.buttonColor = Colors.green,
    this.showWavingAnimation = true,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String emoji,
    required String message,
    String? giftMessage,
    required String buttonText,
    required VoidCallback onButtonPressed,
    Color? buttonColor,
    bool showWavingAnimation = true,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CongratulationsOverlay(
            title: title,
            emoji: emoji,
            message: message,
            giftMessage: giftMessage,
            buttonText: buttonText,
            onButtonPressed: () {
              Navigator.of(context).pop();
              onButtonPressed();
            },
            buttonColor: buttonColor ?? AppConstants.success,
            showWavingAnimation: showWavingAnimation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<CongratulationsOverlay> createState() => _CongratulationsOverlayState();
}

class _CongratulationsOverlayState extends State<CongratulationsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<double>(begin: 300, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Make the waving animation BIG - take up good portion of screen width
    final wavingHeight = screenHeight * 0.55; // 55% of screen height

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Stack(
        children: [
          // Main dialog content - positioned above the waving animation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: widget.showWavingAnimation ? wavingHeight - 20 : 0,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top colored banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.buttonColor,
                                widget.buttonColor.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emoji
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  widget.emoji,
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Message
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // Gift message
                              // if (widget.giftMessage != null) ...[
                              //   const SizedBox(height: 16),
                              //   Container(
                              //     padding: const EdgeInsets.all(14),
                              //     decoration: BoxDecoration(
                              //       color: AppConstants.accentGold
                              //           .withOpacity(0.15),
                              //       borderRadius: BorderRadius.circular(16),
                              //       border: Border.all(
                              //         color: AppConstants.accentGold
                              //             .withOpacity(0.3),
                              //         width: 2,
                              //       ),
                              //     ),
                              //     child: Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         const Text(
                              //           '🎁',
                              //           style: TextStyle(fontSize: 24),
                              //         ),
                              //         const SizedBox(width: 10),
                              //         Flexible(
                              //           child: Text(
                              //             widget.giftMessage!,
                              //             style: TextStyle(
                              //               color: AppConstants.textPrimary,
                              //               fontSize: 15,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ],

                              const SizedBox(height: 20),

                              // Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.buttonColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    elevation: 4,
                                    shadowColor: widget.buttonColor
                                        .withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    widget.buttonText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Waving animation - BIG and at absolute bottom!
          if (widget.showWavingAnimation)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  // Negative bottom padding to ignore safe area and touch edge
                  bottom: -bottomPadding + _slideAnimation.value,
                  child: child!,
                );
              },
              child: SizedBox(
                width: screenWidth,
                height: wavingHeight,
                child: WavingDadChild(
                  width: screenWidth, // Full width!
                  height: wavingHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
