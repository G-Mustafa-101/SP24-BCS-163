import 'package:flutter/material.dart';

void main() {
  runApp(const AssignmentCounterApp());
}

class AssignmentCounterApp extends StatelessWidget {
  const AssignmentCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;
  int step = 1;

  final TextEditingController stepController =
      TextEditingController(text: "1");

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void updateStep() {
    int? value = int.tryParse(stepController.text);
    if (value != null && value > 0) {
      setState(() {
        step = value;
      });
    } else {
      showMessage("Enter a valid positive number");
    }
  }

  void increment() {
    if (counter + step <= 999999) {
      setState(() {
        counter += step;
      });
    } else {
      showMessage("Maximum Limit Reached!");
    }
  }

  void decrement() {
    if (counter - step >= -999999) {
      setState(() {
        counter -= step;
      });
    } else {
      showMessage("Minimum Limit Reached!");
    }
  }

  void reset() {
    setState(() {
      counter = 0;
    });
    showMessage("Counter Reset");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff141E30), Color(0xff243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 20,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              width: 340,
              height: 420,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Assignment 1",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Advanced Counter App",
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      "$counter",
                      key: ValueKey<int>(counter),
                      style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: stepController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter Step Value",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (value) => updateStep(),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn1",
                        onPressed: decrement,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.remove),
                      ),
                      FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: reset,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.refresh),
                      ),
                      FloatingActionButton(
                        heroTag: "btn3",
                        onPressed: increment,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Range: -999999 to +999999",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
