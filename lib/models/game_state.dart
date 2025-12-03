import 'package:flutter/foundation.dart';

class GameStateManager extends ChangeNotifier {
  final List<String> _completedGames = [];
  final List<String> _prizesWon = [];

  List<String> get completedGames => List.unmodifiable(_completedGames);
  List<String> get prizesWon => List.unmodifiable(_prizesWon);

  bool get allGamesComplete => _completedGames.length >= 3;

  void completeGame(String gameId, String prize) {
    if (!_completedGames.contains(gameId)) {
      _completedGames.add(gameId);
      _prizesWon.add(prize);
      notifyListeners();
    }
  }

  void reset() {
    _completedGames.clear();
    _prizesWon.clear();
    notifyListeners();
  }
}
