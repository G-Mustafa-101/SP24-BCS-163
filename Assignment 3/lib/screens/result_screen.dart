import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/bmi_model.dart';
import '../widgets/bmi_gauge.dart';

class ResultScreen extends StatelessWidget {
  final double bmi;
  final String category;
  final double height;
  final double weight;
  final String unitType;
  final String gender; // ✅ ADDED

  const ResultScreen({
    super.key,
    required this.bmi,
    required this.category,
    required this.height,
    required this.weight,
    required this.unitType,
    required this.gender, // ✅ ADDED
  });

  List<String> getTheory() {
    if (unitType == "US") {
      return [
        "• BMI calculated using US units",
        "• Height converted from inches to cm",
        "• Weight converted from pounds to kg",
        "• Gender: $gender", // ✅ ADDED
        "• Healthy BMI range: 18.5 – 25",
      ];
    } else if (unitType == "Metric") {
      return [
        "• BMI calculated using Metric units",
        "• Height in cm, weight in kg",
        "• Gender: $gender", // ✅ ADDED
        "• Healthy BMI range: 18.5 – 25",
      ];
    } else {
      return [
        "• BMI calculated using meters",
        "• Height converted to cm internally",
        "• Gender: $gender", // ✅ ADDED
        "• Healthy BMI range: 18.5 – 25",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              child: Text(
                "BMI = ${bmi.toStringAsFixed(1)} ($category)",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            BMIGauge(bmi: bmi),

            const SizedBox(height: 20),

            Text("BMI = ${bmi.toStringAsFixed(1)}",
                style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 15),

            ...getTheory().map((e) => Text(e)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await DBHelper().insert(
                  BMIModel(
                    bmi: bmi,
                    category: category,
                    height: height,
                    weight: weight,
                  ),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Saved")));
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}