import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Summary"),
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🏆 RESULT HEADER
            Text(
              p.isWin ? "🎉 YOU WON" : "❌ GAME OVER",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: p.isWin ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // 📊 SUMMARY CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Score: ${p.score}"),
                    Text("Total Attempts: ${p.attempts}"),
                    Text("Allowed Attempts: ${p.maxAttempts}"),
                    Text(
                      "Correct At Attempt: "
                      "${p.correctAtAttempt == 0 ? 'Not Found' : p.correctAtAttempt}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🎯 ALL GUESSES
            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    "All Guesses",
                    p.guesses,
                  ),
                  _buildCard(
                    "High Guesses 🔴",
                    p.highGuesses,
                  ),
                  _buildCard(
                    "Low Guesses 🔵",
                    p.lowGuesses,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔁 PLAY AGAIN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // restart properly
                  p.startGame(100, p.maxAttempts);

                  Navigator.pop(context);
                },
                child: const Text("Play Again"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<int> list) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          list.isEmpty ? "None" : list.join(", "),
        ),
      ),
    );
  }
}