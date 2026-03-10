import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import '../patient_model.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final diseaseController = TextEditingController();
  final phoneController = TextEditingController();

  String? imagePath;
  String? documentPath;

  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future pickDocument() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        documentPath = pickedFile.path;
      });
    }
  }

  void savePatient() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        diseaseController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    final patient = Patient(
      name: nameController.text,
      age: ageController.text,
      disease: diseaseController.text,
      phone: phoneController.text,
      image: imagePath,
      document: documentPath,
    );

    await DatabaseHelper.instance.insertPatient(patient);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Patient Added")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
          TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
          TextField(controller: diseaseController, decoration: const InputDecoration(labelText: "Disease")),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone"), keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(onPressed: pickImage, child: const Text("Upload Photo")),
              const SizedBox(width: 10),
              imagePath != null ? const Icon(Icons.check, color: Colors.green) : Container(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(onPressed: pickDocument, child: const Text("Upload Document")),
              const SizedBox(width: 10),
              documentPath != null ? const Icon(Icons.check, color: Colors.green) : Container(),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: savePatient, child: const Text("Save Patient")),
        ]),
      ),
    );
  }
}