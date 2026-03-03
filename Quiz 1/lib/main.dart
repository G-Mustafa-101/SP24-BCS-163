// Importing required libraries
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const DiceHomePage(),
    );
  }
}

class DiceHomePage extends StatefulWidget {
  const DiceHomePage({super.key});

  @override
  State<DiceHomePage> createState() => _DiceHomePageState();
}

class _DiceHomePageState extends State<DiceHomePage> {
  int diceNumber = 1;
  int totalRolls = 0;

  List<int> history = [];
  List<int> fullHistory = [];

  int? selectedNumber; // User chosen number (nullable initially)
  double score = 0; // Score in $

  // 🔹 Function to show number selection modal
  void chooseNumber() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(6, (index) {
            int num = index + 1;
            bool isSelected = selectedNumber == num;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedNumber = num;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  "$num",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void rollDice() {
    setState(() {
      diceNumber = Random().nextInt(6) + 1;
      totalRolls++;

      // Update last 5 rolls
      history.insert(0, diceNumber);
      if (history.length > 5) history.removeLast();

      // Update full history
      fullHistory.add(diceNumber);

      // 🔥 Bonus logic: $ only if guess matches dice
      if (selectedNumber != null && diceNumber == selectedNumber) {
        double bonus = diceNumber * 2;
        score += bonus;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎉 Correct Guess! Bonus: \$${bonus.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        score += diceNumber.toDouble();
      }
    });
  }

  void showFullHistory() {
    if (fullHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No rolls yet!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Full Roll History"),
        content: SizedBox(
          height: 250,
          width: 250,
          child: ListView.builder(
            itemCount: fullHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.asset(
                  'assets/images/${fullHistory[index]}.png',
                  width: 30,
                ),
                title: Text("Roll ${index + 1}: ${fullHistory[index]}"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
  }

  void resetAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Dice?"),
        content: const Text("Are you sure you want to reset all rolls and score?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
              onPressed: () {
                setState(() {
                  diceNumber = 1;
                  totalRolls = 0;
                  history.clear();
                  fullHistory.clear();
                  score = 0;
                  selectedNumber = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Yes")),
        ],
      ),
    );
  }

  void shareResult({bool full = false}) {
    final text = full
        ? "🎲 My Full Dice Rolls:\n${fullHistory.asMap().entries.map((e) => 'Roll ${e.key + 1}: ${e.value}').join('\n')}\n\nTotal Score: \$${score.toStringAsFixed(2)}"
        : "🎲 My Last Roll: $diceNumber\nTotal Score: \$${score.toStringAsFixed(2)}";

    Share.share(text, subject: "Dice Roller Result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "🎲 Dice Roller",
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    "Score: \$${score.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow),
                  ),

                  const SizedBox(height: 15),

                  // 🔹 User Choose Number Button
                  GestureDetector(
                    onTap: chooseNumber,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        selectedNumber == null
                            ? "Choose Your Number"
                            : "Your Guess: $selectedNumber",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: rollDice,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        'assets/images/$diceNumber.png',
                        key: ValueKey(diceNumber),
                        width: 140,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "You Rolled: $diceNumber",
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: showFullHistory,
                    child: Text(
                      "Total Rolls: $totalRolls (Tap to view)",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: history
                        .map(
                          (num) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/images/$num.png',
                              width: 40,
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 30),

                  _buildGradientButton("🎲 Roll Dice", Colors.pinkAccent,
                      Colors.deepPurple, rollDice),

                  const SizedBox(height: 15),

                  _buildGradientButton(
                      "🧹 Reset All", Colors.orangeAccent, Colors.redAccent, resetAll),

                  const SizedBox(height: 15),

                  _buildGradientButton("📤 Share Result", Colors.greenAccent,
                      Colors.teal, () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SizedBox(
                        height: 150,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.casino),
                              title: const Text("Share Last Roll"),
                              onTap: () {
                                shareResult(full: false);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: const Text("Share Full History"),
                              onTap: () {
                                shareResult(full: true);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, Color start, Color end, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(40),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
