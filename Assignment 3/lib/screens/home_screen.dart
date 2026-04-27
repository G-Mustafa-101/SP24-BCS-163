import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  String gender = "Male";
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  // ================= BMI CALCULATION =================
  void calculate() {
    double? heightInput = double.tryParse(heightController.text);
    double? weightInput = double.tryParse(weightController.text);

    if (heightInput == null || weightInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid numbers")),
      );
      return;
    }

    if (heightInput <= 0 || weightInput <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Values must be greater than 0")),
      );
      return;
    }

    double heightCm;
    double weightKg;
    String unitType;

    // ================= UNIT CONVERSION =================
    if (tabController.index == 0) {
      heightCm = heightInput * 2.54;
      weightKg = weightInput * 0.453592;
      unitType = "US";
    } else if (tabController.index == 1) {
      heightCm = heightInput;
      weightKg = weightInput;
      unitType = "Metric";
    } else {
      heightCm = heightInput * 100;
      weightKg = weightInput;
      unitType = "Other";
    }

    double bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

    String category;
    if (bmi < 18.5) {
      category = "Underweight";
    } else if (bmi < 24.9) {
      category = "Normal";
    } else if (bmi < 29.9) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          bmi: bmi,
          category: category,
          height: heightCm,
          weight: weightKg,
          unitType: unitType,
          gender: gender, // ✅ FIX ADDED
        ),
      ),
    );
  }

  // ================= INPUT UI =================
  Widget buildInputUI(String heightLabel, String weightLabel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AGE
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Age",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // GENDER
          Row(
            children: [
              const Text(
                "Gender:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Radio(
                value: "Male",
                groupValue: gender,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setState(() => gender = val.toString());
                },
              ),
              const Text("Male"),
              Radio(
                value: "Female",
                groupValue: gender,
                activeColor: Colors.pink,
                onChanged: (val) {
                  setState(() => gender = val.toString());
                },
              ),
              const Text("Female"),
            ],
          ),

          const SizedBox(height: 10),

          // HEIGHT
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: heightLabel,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // WEIGHT
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: weightLabel,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BUTTONS
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: calculate,
                child: const Text("Calculate"),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  heightController.clear();
                  weightController.clear();
                  ageController.clear();
                },
                child: const Text("Clear"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          )
        ],

        // ✅ FIX: WHITE TAB TEXT
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "US Units"),
            Tab(text: "Metric"),
            Tab(text: "Other"),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: TabBarView(
              controller: tabController,
              children: [
                buildInputUI("Height (inch)", "Weight (lbs)"),
                buildInputUI("Height (cm)", "Weight (kg)"),
                buildInputUI("Height (meters)", "Weight (kg)"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}