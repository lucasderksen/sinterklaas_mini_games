// lib/widgets/waving_dad_child.dart
import 'package:flutter/material.dart';
import 'dart:async';

class WavingDadChild extends StatefulWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const WavingDadChild({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  State<WavingDadChild> createState() => _WavingDadChildState();
}

class _WavingDadChildState extends State<WavingDadChild> {
  int _currentFrame = 0;
  Timer? _timer;

  // Frame sequence: 1 -> 2 -> 3 -> 2 -> (repeat)
  static const List<String> _frames = [
    'assets/dad_child_wave_1.png',
    'assets/dad_child_wave_2.png',
    'assets/dad_child_wave_3.png',
    'assets/dad_child_wave_2.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _frames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Just a simple Image - NO AnimatedSwitcher, instant frame change!
    return Image.asset(
      _frames[_currentFrame],
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
