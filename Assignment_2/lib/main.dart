import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const ProfileCardApp());
}

class ProfileCardApp extends StatelessWidget {
  const ProfileCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'G Mustafa - Professional CV',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
      ),
      home: const ProfileCardScreen(),
    );
  }
}

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 1000,
            height: 700,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                // ===== LEFT PANEL =====
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ===== Profile Picture with change option =====
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orangeAccent, width: 3),
                              ),
                              child: ClipOval(
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 2.0,
                                  child: _profileImage != null
                                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                                      : Image.asset('assets/profile.jpg', fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap image to change",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "G Mustafa",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Mobile & Web Developer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          const Divider(
                            height: 30,
                            thickness: 1,
                            color: Colors.white38,
                          ),

                          // Contact Info
                          contactItem(Icons.phone, "+92 300 1234567"),
                          contactItem(Icons.email, "g.mustafa@gmail.com"),
                          contactItem(Icons.location_on, "Lahore, Pakistan"),
                          const SizedBox(height: 20),

                          // Social
                          const Text(
                            "SOCIAL",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              socialItem(Icons.web, "Portfolio"),
                              socialItem(Icons.code, "GitHub"),
                              socialItem(Icons.person, "LinkedIn"),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Languages
                          const Text(
                            "LANGUAGES",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                          const SizedBox(height: 10),
                          skillBarLeft("English", 0.95),
                          skillBarLeft("Urdu", 1.0),
                          skillBarLeft("Arabic", 0.65),
                          const SizedBox(height: 20),

                          // Hobbies
                          const Text(
                            "HOBBIES",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              hobbyItem(Icons.book, "Reading"),
                              hobbyItem(Icons.sports_basketball, "Basketball"),
                              hobbyItem(Icons.brush, "Drawing"),
                              hobbyItem(Icons.music_note, "Music"),
                              hobbyItem(Icons.travel_explore, "Traveling"),
                              hobbyItem(Icons.videogame_asset, "Gaming"),
                              hobbyItem(Icons.camera_alt, "Photography"),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Fun Facts / Extras
                          const Text(
                            "FUN FACTS",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                          const SizedBox(height: 10),
                          achievementItem("Coffee Lover ☕"),
                          achievementItem("Open Source Contributor"),
                          achievementItem("Marathon Runner 🏃‍♂️"),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== RIGHT PANEL =====
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle("ABOUT ME"),
                        const SizedBox(height: 10),
                        const Text(
                          "I am G Mustafa, a passionate Mobile & Web Developer skilled in Flutter, Dart, "
                          "Web Development, Java, Python, and modern UI/UX design. "
                          "I craft responsive, professional, and visually appealing apps. "
                          "I strive for clean code, creativity, and excellence in every project.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 25),

                        sectionTitle("JOB EXPERIENCE"),
                        const SizedBox(height: 10),
                        jobItem("Junior App Developer - ABC Tech", "2024 - Present"),
                        jobItem("Web Developer Intern - XYZ Solutions", "2023 - 2024"),
                        jobItem("Freelance Projects", "2022 - 2023"),
                        const SizedBox(height: 25),

                        sectionTitle("EDUCATION"),
                        const SizedBox(height: 10),
                        jobItem("Bachelor in Computer Science", "University of Lahore (2021-2025)"),
                        jobItem("High School Diploma", "Lahore Board (2017-2021)"),
                        const SizedBox(height: 25),

                        sectionTitle("SKILLS"),
                        const SizedBox(height: 10),
                        skillBarRight("Web Development", 0.95),
                        skillBarRight("Java", 0.9),
                        skillBarRight("Python", 0.85),
                        skillBarRight("UI/UX Design", 0.9),
                        skillBarRight("Mobile Apps", 0.9),
                        skillBarRight("Project Management", 0.8),
                        const SizedBox(height: 25),

                        sectionTitle("PROJECTS"),
                        const SizedBox(height: 10),
                        projectItem("Portfolio Website"),
                        projectItem("E-commerce App"),
                        projectItem("Task Management App"),
                        projectItem("Blog Platform"),
                        projectItem("Inventory System"),
                        const SizedBox(height: 25),

                        sectionTitle("ACHIEVEMENTS"),
                        const SizedBox(height: 10),
                        achievementItem("Best Student Award 2024"),
                        achievementItem("Top Web Dev Intern 2023"),
                        achievementItem("Hackathon Winner 2024"),
                        achievementItem("Open Source Contributor Award"),
                        const SizedBox(height: 25),

                        sectionTitle("CERTIFICATES"),
                        const SizedBox(height: 10),
                        projectItem("Flutter & Dart Certified"),
                        projectItem("Web Development Bootcamp"),
                        projectItem("Java Programming Certificate"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helper Widgets =====

  // Contact
  Widget contactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // Social Item
  static Widget socialItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Section Title
  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
    );
  }

  // Job / Education Item
  Widget jobItem(String title, String duration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(duration, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Skills Left Panel
  static Widget skillBarLeft(String skill, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  // Skills Right Panel
  static Widget skillBarRight(String skill, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  // Hobby Item
  static Widget hobbyItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Project Item
  static Widget projectItem(String name) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        Text(name),
      ],
    );
  }

  // Achievement Item
  static Widget achievementItem(String name) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        Text(name),
      ],
    );
  }
}