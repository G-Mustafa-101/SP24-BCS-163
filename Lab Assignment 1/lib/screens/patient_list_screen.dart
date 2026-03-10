import 'dart:io';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../patient_model.dart';
import 'add_patient_screen.dart';
import 'edit_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> patients = [];
  List<Patient> filteredPatients = [];
  String searchQuery = '';
  bool sortAsc = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  void loadPatients() async {
    final data = await DatabaseHelper.instance.getPatients();
    setState(() {
      patients = data;
      applyFilterAndSort();
    });
  }

  void applyFilterAndSort() {
    // Filter by search query
    filteredPatients = patients
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // Sort by name
    filteredPatients.sort((a, b) =>
        sortAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }

  void deletePatient(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this patient?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deletePatient(id);
      loadPatients();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient Deleted Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        actions: [
          IconButton(
            icon: Icon(sortAsc ? Icons.sort_by_alpha : Icons.sort),
            tooltip: 'Sort ${sortAsc ? "A-Z" : "Z-A"}',
            onPressed: () {
              setState(() {
                sortAsc = !sortAsc;
                applyFilterAndSort();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Patient by Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  applyFilterAndSort();
                });
              },
            ),
          ),
        ),
      ),
      body: filteredPatients.isEmpty
          ? const Center(child: Text("No Patients Found"))
          : ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: patient.image != null
                        ? CircleAvatar(
                            radius: 28,
                            backgroundImage: FileImage(File(patient.image!)),
                          )
                        : const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.person, size: 30),
                          ),
                    title: Text(
                      patient.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Disease: ${patient.disease}"),
                        Text("Phone: ${patient.phone}"),
                        Text("Age: ${patient.age}"),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailScreen(patient: patient),
                        ),
                      );
                      loadPatients();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditPatientScreen(patient: patient),
                                ),
                              );
                              loadPatients();
                            }),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletePatient(patient.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
          loadPatients();
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}