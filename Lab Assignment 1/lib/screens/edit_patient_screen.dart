import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import '../patient_model.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;
  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController diseaseController;
  late TextEditingController phoneController;

  String? imagePath;
  String? documentPath;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.patient.name);
    ageController = TextEditingController(text: widget.patient.age);
    diseaseController = TextEditingController(text: widget.patient.disease);
    phoneController = TextEditingController(text: widget.patient.phone);
    imagePath = widget.patient.image;
    documentPath = widget.patient.document;
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => imagePath = pickedFile.path);
  }

  Future pickDocument() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => documentPath = pickedFile.path);
  }

  void updatePatient() async {
    final updated = Patient(
      id: widget.patient.id,
      name: nameController.text,
      age: ageController.text,
      disease: diseaseController.text,
      phone: phoneController.text,
      image: imagePath,
      document: documentPath,
    );

    await DatabaseHelper.instance.updatePatient(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Patient Updated")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Patient")),
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
          ElevatedButton(onPressed: updatePatient, child: const Text("Update Patient")),
        ]),
      ),
    );
  }
}