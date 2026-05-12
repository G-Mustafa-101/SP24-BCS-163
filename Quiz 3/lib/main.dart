import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/portal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Replace with actual credentials provided in the .env or by the user
  await Supabase.initialize(
    url: 'https://wywntswhywhkmvstgvqj.supabase.co',
    anonKey: 'sb_publishable_CD2mrdqtMbnqb6xWgeMAQA_rOZlYjj2',
  );

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSC303 Quiz 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF764BA2),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const PortalScreen(),
    );
  }
}
