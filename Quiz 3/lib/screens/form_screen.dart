import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';
import '../services/supabase_service.dart';
import 'records_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SupabaseService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Male';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final submission = Submission(
          fullName: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          gender: _gender,
        );
        await _service.createSubmission(submission);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission Successful!'), backgroundColor: Colors.green),
          );
          _clear();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsScreen()));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _clear() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() => _gender = 'Male');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: FadeInUp(
                child: Column(
                  children: [
                    Text(
                      'Quiz 3 Portal',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CSC303 Mobile App Development',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(_nameController, 'Full Name', LucideIcons.user),
                                const SizedBox(height: 16),
                                _buildTextField(_emailController, 'Email', LucideIcons.mail, email: true),
                                const SizedBox(height: 16),
                                _buildTextField(_phoneController, 'Phone Number', LucideIcons.phone),
                                const SizedBox(height: 16),
                                _buildTextField(_addressController, 'Address', LucideIcons.mapPin),
                                const SizedBox(height: 24),
                                const Text('Gender', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Row(
                                  children: ['Male', 'Female', 'Other'].map((g) {
                                    return Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(g, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        value: g,
                                        groupValue: _gender,
                                        activeColor: Colors.white,
                                        onChanged: (v) => setState(() => _gender = v!),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF667EEA),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: _isLoading 
                                      ? const CircularProgressIndicator()
                                      : const Text('SUBMIT NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsScreen())),
                                    child: const Text('View All Records', style: TextStyle(color: Colors.white70)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool email = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (email && !v.contains('@')) return 'Invalid Email';
        return null;
      },
    );
  }
}
