import 'dart:io';
import 'package:flutter/material.dart';
import '../patient_model.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(title: const Text("Patient Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: patient.image != null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(File(patient.image!)),
                    )
                  : const CircleAvatar(
                      radius: 60, child: Icon(Icons.person, size: 50)),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Name"),
                subtitle: Text(patient.name),
                leading: const Icon(Icons.person, color: Colors.teal),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Age"),
                subtitle: Text(patient.age),
                leading: const Icon(Icons.cake, color: Colors.teal),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Disease"),
                subtitle: Text(patient.disease),
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Phone"),
                subtitle: Text(patient.phone),
                leading: const Icon(Icons.phone, color: Colors.teal),
              ),
            ),
            if (patient.document != null)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text("Document",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Image.file(File(patient.document!),
                        height: 200, width: double.infinity, fit: BoxFit.cover),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}