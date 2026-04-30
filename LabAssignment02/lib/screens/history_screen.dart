import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = "All";

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<GameProvider>(context, listen: false)
            .loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    // 🔍 FILTER LOGIC (WIN / LOSE / ALL)
    List<GameModel> filteredList = provider.history.where((g) {
      if (filter == "Win") return g.result == "WIN";
      if (filter == "Lose") return g.result == "LOSE";
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),

        // 🗑 CLEAR ALL
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear History"),
                  content:
                      const Text("Are you sure you want to delete all?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔽 FILTER DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: filter,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: "All", child: Text("All")),
                  DropdownMenuItem(value: "Win", child: Text("Wins")),
                  DropdownMenuItem(value: "Lose", child: Text("Losses")),
                ],
                onChanged: (val) {
                  setState(() {
                    filter = val!;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 📋 LIST
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No History Found"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      var game = filteredList[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          // 🎯 TITLE
                          title: Text(
                            game.result == "WIN"
                                ? "🎉 WIN GAME"
                                : "❌ LOST GAME",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: game.result == "WIN"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          // 📊 FULL DETAILS (UPDATED AS YOU ASKED)
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                "Attempts: ${game.totalAttempts}",
                              ),

                              Text(
                                "Guesses: ${game.attemptsList}",
                              ),

                              Text(
                                "Result: ${game.result}",
                              ),

                              Text(
                                "Score: ${game.score}",
                              ),
                            ],
                          ),

                          // 🗑 DELETE ONE
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete"),
                                  content: const Text(
                                      "Delete this record?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteOne(game.id!);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}