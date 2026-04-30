import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Statistics"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            statCard(
              "Total Games",
              provider.totalGames.toString(),
              Colors.blue,
            ),

            statCard(
              "Wins 🎉",
              provider.wins.toString(),
              Colors.green,
            ),

            statCard(
              "Losses ❌",
              provider.loses.toString(),
              Colors.red,
            ),

            statCard(
              "Win Rate 📊",
              "${provider.winRate.toStringAsFixed(1)}%",
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 Reusable Stat Card
  Widget statCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}