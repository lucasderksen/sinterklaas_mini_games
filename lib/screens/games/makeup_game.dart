import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/game_state.dart';
import '../game_complete_screen.dart';

enum MakeupPhase {
  pump,
  apply,
  clean,
  applyMask,
  removeMask,
  complete,
}

class MakeupGame extends StatefulWidget {
  final GameStateManager gameState;

  const MakeupGame({super.key, required this.gameState});

  @override
  State<MakeupGame> createState() => _MakeupGameState();
}

class _MakeupGameState extends State<MakeupGame> {
  MakeupPhase _phase = MakeupPhase.pump;
  int _pumpCount = 0;
  int _applicationCount = 0;
  double _cleanProgress = 0;
  bool _maskApplied = false;
  double _maskRemoveProgress = 0;

  String _getPhaseInstruction() {
    switch (_phase) {
      case MakeupPhase.pump:
        return '💄 Tik op de pomp om product te pakken!\n($_pumpCount/${AppConstants.makeupPumpTaps})';
      case MakeupPhase.apply:
        return '👤 Tik op het gezicht om makeup aan te brengen!\n($_applicationCount/${AppConstants.makeupApplicationTaps})';
      case MakeupPhase.clean:
        return '🧹 Swipe om het gezicht schoon te maken!';
      case MakeupPhase.applyMask:
        return '😷 Tik om het masker aan te brengen!';
      case MakeupPhase.removeMask:
        return '✨ Swipe om het masker te verwijderen!';
      case MakeupPhase.complete:
        return '🎉 Klaar!';
    }
  }

  void _handlePumpTap() {
    if (_phase != MakeupPhase.pump) return;

    setState(() {
      _pumpCount++;
      if (_pumpCount >= AppConstants.makeupPumpTaps) {
        _phase = MakeupPhase.apply;
      }
    });
  }

  void _handleFaceTap() {
    if (_phase != MakeupPhase.apply) return;

    setState(() {
      _applicationCount++;
      if (_applicationCount >= AppConstants.makeupApplicationTaps) {
        _phase = MakeupPhase.clean;
      }
    });
  }

  void _handleCleanSwipe(DragUpdateDetails details) {
    if (_phase != MakeupPhase.clean) return;

    setState(() {
      _cleanProgress += details.delta.dx.abs() / 500;
      if (_cleanProgress >= 1) {
        _phase = MakeupPhase.applyMask;
      }
    });
  }

  void _handleMaskTap() {
    if (_phase != MakeupPhase.applyMask) return;

    setState(() {
      _maskApplied = true;
      _phase = MakeupPhase.removeMask;
    });
  }

  void _handleMaskRemove(DragUpdateDetails details) {
    if (_phase != MakeupPhase.removeMask) return;

    setState(() {
      _maskRemoveProgress += details.delta.dx.abs() / 500;
      if (_maskRemoveProgress >= 1) {
        _phase = MakeupPhase.complete;
        _showCompletion();
      }
    });
  }

  void _showCompletion() {
    widget.gameState.completeGame('makeup', 'Makeup Set 💄');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameCompleteScreen(gameState: widget.gameState),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildGameArea(),
            ),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '💄 Makeup Game',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPhaseIndicator(MakeupPhase.pump, '💄'),
              Icon(Icons.arrow_forward, color: AppConstants.textSecondary),
              _buildPhaseIndicator(MakeupPhase.apply, '👤'),
              const Icon(Icons.arrow_forward, color: Colors.white),
              _buildPhaseIndicator(MakeupPhase.clean, '🧹'),
              Icon(Icons.arrow_forward, color: AppConstants.textSecondary),
              _buildPhaseIndicator(MakeupPhase.applyMask, '😷'),
              Icon(Icons.arrow_forward, color: AppConstants.textSecondary),
              _buildPhaseIndicator(MakeupPhase.removeMask, '✨'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(MakeupPhase phase, String emoji) {
    final isActive = _phase == phase;
    final isComplete = _phase.index > phase.index;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isComplete
            ? AppConstants.success
            : isActive
                ? AppConstants.accentGold
                : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_phase == MakeupPhase.pump) _buildPumpPhase(),
          if (_phase == MakeupPhase.apply) _buildApplyPhase(),
          if (_phase == MakeupPhase.clean) _buildCleanPhase(),
          if (_phase == MakeupPhase.applyMask) _buildMaskPhase(),
          if (_phase == MakeupPhase.removeMask) _buildRemoveMaskPhase(),
          if (_phase == MakeupPhase.complete) _buildCompletePhase(),
        ],
      ),
    );
  }

  Widget _buildPumpPhase() {
    return Column(
      children: [
        GestureDetector(
          onTap: _handlePumpTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink[300],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('💄', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PUMP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _pumpCount / AppConstants.makeupPumpTaps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation(AppConstants.success),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyPhase() {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleFaceTap,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('👤', style: TextStyle(fontSize: 100)),
                if (_applicationCount > 0)
                  Positioned(
                    top: 40,
                    child: Text(
                      '💄' * _applicationCount,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _applicationCount / AppConstants.makeupApplicationTaps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation(AppConstants.success),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanPhase() {
    return GestureDetector(
      onHorizontalDragUpdate: _handleCleanSwipe,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('👤', style: TextStyle(fontSize: 100)),
                Opacity(
                  opacity: 1 - _cleanProgress,
                  child: const Text(
                    '💄💄💄💄💄',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '⬅️ Swipe! ➡️',
            style: TextStyle(fontSize: 24, color: AppConstants.textPrimary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _cleanProgress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(AppConstants.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaskPhase() {
    return GestureDetector(
      onTap: _handleMaskTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text('😷', style: TextStyle(fontSize: 80)),
                SizedBox(height: 10),
                Text(
                  'Masker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveMaskPhase() {
    return GestureDetector(
      onHorizontalDragUpdate: _handleMaskRemove,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green[200],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('👤', style: TextStyle(fontSize: 100)),
                Opacity(
                  opacity: 1 - _maskRemoveProgress,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Text('😷', style: TextStyle(fontSize: 80))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '⬅️ Swipe om te verwijderen! ➡️',
            style: TextStyle(fontSize: 20, color: AppConstants.textPrimary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _maskRemoveProgress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(AppConstants.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePhase() {
    return const Column(
      children: [
        Text(
          '✨ PERFECT! ✨',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '🎉',
          style: TextStyle(fontSize: 100),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Text(
        _getPhaseInstruction(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
