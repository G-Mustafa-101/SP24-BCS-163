import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: Colors.teal),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}