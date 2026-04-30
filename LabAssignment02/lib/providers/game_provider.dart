import 'dart:math';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/game_model.dart';

class GameProvider extends ChangeNotifier {
  int target = 0;

  int maxAttempts = 5;
  int attempts = 0;

  List<int> guesses = [];

  // 🎯 NEW FEATURES (HIGH / LOW TRACKING)
  List<int> highGuesses = [];
  List<int> lowGuesses = [];

  int correctAtAttempt = 0;

  bool gameOver = false;
  bool isWin = false;

  String message = "";
  int score = 0;

  List<GameModel> history = [];

  final DBHelper db = DBHelper();

  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  // 🎮 START GAME
  void startGame(int maxNumber, int selectedAttempts) {
    target = Random().nextInt(maxNumber) + 1;

    maxAttempts = selectedAttempts;

    attempts = 0;
    guesses.clear();
    highGuesses.clear();
    lowGuesses.clear();

    correctAtAttempt = 0;

    gameOver = false;
    isWin = false;

    message = "Game Started!";
    score = 0;

    notifyListeners();
  }

  // 🎯 CORE GAME LOGIC (FIXED)
  Future<String> guessNumber(int guess) async {
    if (gameOver) return message;

    attempts++;
    guesses.add(guess);

    if (guess == target) {
      isWin = true;
      gameOver = true;

      correctAtAttempt = attempts;

      score = (100 - (attempts * 10)).clamp(10, 100);
      message = "Correct 🎉";

    } else if (guess > target) {
      highGuesses.add(guess);
      message = "Too High 🔴";

    } else {
      lowGuesses.add(guess);
      message = "Too Low 🔵";
    }

    // ❌ GAME OVER CONDITION
    if (attempts >= maxAttempts && !isWin) {
      gameOver = true;
      message = "Game Over ❌ Number was $target";
    }

    // 💾 SAVE TO SQLITE
    if (gameOver) {
      await db.insertGame(GameModel(
        attemptsList: guesses.join(", "),
        totalAttempts: attempts,
        result: isWin ? "WIN" : "LOSE",
        score: score,
        time: DateTime.now().toString(),
      ));
    }

    notifyListeners();
    return message;
  }

  // 📊 HISTORY
  Future<void> loadHistory() async {
    history = await db.getGames();
    notifyListeners();
  }

  Future<void> deleteOne(int id) async {
    final dbx = await db.database;
    await dbx.delete('games', where: 'id=?', whereArgs: [id]);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await db.deleteAll();
    await loadHistory();
  }

  // 📊 STATS
  int get totalGames => history.length;

  int get wins =>
      history.where((g) => g.result == "WIN").length;

  int get loses =>
      history.where((g) => g.result == "LOSE").length;

  double get winRate =>
      totalGames == 0 ? 0 : (wins / totalGames) * 100;
}