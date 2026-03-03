// Importing required libraries
import 'dart:math'; // Used to generate random dice number
import 'package:flutter/material.dart'; // Flutter UI library
import 'package:share_plus/share_plus.dart'; // Used to share dice result

// Main function - Starting point of the application
void main() {
  runApp(const DiceApp());
}

// Root widget of the application
class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        fontFamily: 'Roboto', // Clean font as required in assignment
        useMaterial3: true,
      ),
      home: const DiceHomePage(),
    );
  }
}

// Stateful widget because dice image will change dynamically using setState()
class DiceHomePage extends StatefulWidget {
  const DiceHomePage({super.key});

  @override
  State<DiceHomePage> createState() => _DiceHomePageState();
}

class _DiceHomePageState extends State<DiceHomePage> {

  // Stores current dice number (1 to 6)
  int diceNumber = 1;

  // Stores total number of rolls
  int totalRolls = 0;

  // Stores last 5 rolls
  List<int> history = [];

  // Stores complete roll history
  List<int> fullHistory = [];

  // Function to roll dice and generate random number from 1 to 6
  void rollDice() {
    setState(() {
      diceNumber = Random().nextInt(6) + 1; // Random number between 1–6
      totalRolls++;

      // Adding latest roll to top of last 5 history list
      history.insert(0, diceNumber);
      if (history.length > 5) history.removeLast();

      // Adding roll to full history list
      fullHistory.add(diceNumber);
    });
  }

  // Function to show full roll history in dialog box
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
                  'assets/images/${fullHistory[index]}.png', // Dice images from assets/images/
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

  // Function to reset all dice values and history
  void resetAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Dice?"),
        content: const Text("Are you sure you want to reset all rolls?"),
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
                });
                Navigator.pop(context);
              },
              child: const Text("Yes")),
        ],
      ),
    );
  }

  // Function to share last roll or full roll history
  void shareResult({bool full = false}) {
    if (full && fullHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No rolls to share!")),
      );
      return;
    }

    final text = full
        ? "🎲 My Full Dice Rolls:\n${fullHistory.asMap().entries.map((e) => 'Roll ${e.key + 1}: ${e.value}').join('\n')}"
        : "🎲 My Last Roll: $diceNumber";

    Share.share(text, subject: "Dice Roller Result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient for simple responsive UI
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
                  const Text(
                    "🎲 Dice Roller",
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Dice image that changes using setState()
                  GestureDetector(
                    onTap: rollDice,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          'assets/images/$diceNumber.png', // Dice images from assets/images/
                          key: ValueKey(diceNumber),
                          width: 140,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Displaying rolled number
                  Text(
                    "You Rolled: $diceNumber",
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Tap to view total roll history
                  GestureDetector(
                    onTap: showFullHistory,
                    child: Text(
                      "Total Rolls: $totalRolls (Tap to view)",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Last 5 Rolls",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Showing last 5 dice rolls
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

                  // Roll Dice Button
                  _buildGradientButton("🎲 Roll Dice", Colors.pinkAccent,
                      Colors.deepPurple, rollDice),

                  const SizedBox(height: 15),

                  // Reset Button
                  _buildGradientButton(
                      "🧹 Reset All", Colors.orangeAccent, Colors.redAccent, resetAll),

                  const SizedBox(height: 15),

                  // Share Button
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

  // Helper function to build gradient buttons
  Widget _buildGradientButton(
      String text, Color start, Color end, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}