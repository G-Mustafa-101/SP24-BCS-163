import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quiz2 App",

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),

      home: HomeScreen(),
    );
  }
}