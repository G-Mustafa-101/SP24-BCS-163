import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  int maxNumber = 50;
  int selectedAttempts = 5;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false)
          .startGame(maxNumber, selectedAttempts);
    });
  }

  // 🎯 SUBMIT GUESS
  void submitGuess() async {
    if (controller.text.isEmpty) {
      showMsg("Enter a number");
      return;
    }

    int? guess = int.tryParse(controller.text);

    if (guess == null) {
      showMsg("Invalid input");
      return;
    }

    var provider = Provider.of<GameProvider>(context, listen: false);

    await provider.guessNumber(guess);

    controller.clear();

    // 🟢 instant feedback
    showMsg(provider.message);

    // 🏁 go result screen after every game end
    if (provider.gameOver) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Guess Game"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              provider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              provider.toggleTheme();
            },
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6a11cb), Color(0xff2575fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🎚 DIFFICULTY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: maxNumber,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 50, child: Text("Easy (1-50)")),
                  DropdownMenuItem(value: 100, child: Text("Medium (1-100)")),
                  DropdownMenuItem(value: 200, child: Text("Hard (1-200)")),
                ],
                onChanged: (value) {
                  setState(() {
                    maxNumber = value!;
                  });

                  provider.startGame(maxNumber, selectedAttempts);
                },
              ),
            ),

            const SizedBox(height: 15),

            // 🎯 ATTEMPTS SELECTOR (NEW FEATURE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: selectedAttempts,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 5, child: Text("5 Attempts")),
                  DropdownMenuItem(value: 10, child: Text("10 Attempts")),
                  DropdownMenuItem(value: 15, child: Text("15 Attempts")),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedAttempts = val!;
                  });

                  provider.startGame(maxNumber, selectedAttempts);
                },
              ),
            ),

            const SizedBox(height: 30),

            // 🧩 INPUT CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  const Text(
                    "Guess the Number",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter number...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitGuess,
                      child: const Text("Submit Guess"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔘 ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    provider.startGame(maxNumber, selectedAttempts);
                    controller.clear();
                    showMsg("New Game Started");
                  },
                  child: const Text("New Game"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryScreen()),
                    );
                  },
                  child: const Text("History"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}