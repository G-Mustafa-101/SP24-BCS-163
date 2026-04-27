import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/bmi_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BMIModel> list = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    list = await DBHelper().getAll();
    setState(() {});
  }

  // 🔴 DELETE ALL WITH CONFIRMATION
  void deleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete All"),
        content: const Text("Are you sure you want to delete all records?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper().deleteAll();
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ✏️ UPDATE DIALOG (IMPROVED)
  void showUpdateDialog(BMIModel item) {
    TextEditingController h =
        TextEditingController(text: item.height.toString());
    TextEditingController w =
        TextEditingController(text: item.weight.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: h,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Height (cm)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: w,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              double height = double.parse(h.text);
              double weight = double.parse(w.text);

              double bmi = weight / ((height / 100) * (height / 100));

              String category;
              if (bmi < 18.5) category = "Underweight";
              else if (bmi < 24.9) category = "Normal";
              else if (bmi < 29.9) category = "Overweight";
              else category = "Obese";

              await DBHelper().update(
                BMIModel(
                  id: item.id,
                  bmi: bmi,
                  category: category,
                  height: height,
                  weight: weight,
                ),
              );

              Navigator.pop(context);
              loadData();
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  // 🎨 COLOR FUNCTION
  Color getColor(String category) {
    switch (category) {
      case "Normal":
        return Colors.green;
      case "Overweight":
        return Colors.orange;
      case "Obese":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI History"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: deleteAll,
            icon: const Icon(Icons.delete_forever),
          )
        ],
      ),

      // 📦 BODY
      body: list.isEmpty
          ? const Center(
              child: Text(
                "No Records Yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final item = list[i];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    // 🟢 BMI CIRCLE
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: getColor(item.category),
                      child: Text(
                        item.bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 📊 TEXT
                    title: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Height: ${item.height} cm\nWeight: ${item.weight} kg",
                    ),

                    // ⚙️ ACTIONS
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ✏️ UPDATE
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showUpdateDialog(item),
                        ),

                        // ❌ DELETE ONE (WITH CONFIRMATION)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
                                    onPressed: () async {
                                      await DBHelper()
                                          .delete(item.id!);
                                      Navigator.pop(context);
                                      loadData();
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}