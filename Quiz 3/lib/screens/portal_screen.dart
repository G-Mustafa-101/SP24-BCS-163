import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';
import '../services/supabase_service.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  
  // Create Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Male';
  
  bool _isLoading = false;
  List<Submission> _submissions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchSubmissions();
      setState(() => _submissions = data);
    } catch (e) {
      _showError('Failed to load records: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _submitForm() async {
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
        _showSuccess('Submission added successfully!');
        _clearForm();
        _tabController.animateTo(1);
        _fetchRecords();
      } catch (e) {
        _showError('Submission failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() => _gender = 'Male');
  }

  void _deleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteSubmission(id);
        _showSuccess('Record deleted');
        _fetchRecords();
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header match React
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      'CSC303 Quiz 3',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Mobile Application Development Portal',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Tabs matching React TabsList
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.plus, size: 16), SizedBox(width: 8), Text('Form')])),
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.list, size: 16), SizedBox(width: 8), Text('Records')])),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFormTab(),
                    _buildRecordsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInLeft(
        child: _glassContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _formHeader('Personal Information', LucideIcons.user),
                const SizedBox(height: 20),
                _inputLabel('Full Name', LucideIcons.user),
                _textField(_nameController, 'Murtaza Gadeel'),
                const SizedBox(height: 16),
                _inputLabel('Email Address', LucideIcons.mail),
                _textField(_emailController, 'murtaza@csc303.com', isEmail: true),
                const SizedBox(height: 16),
                _inputLabel('Phone Number', LucideIcons.phone),
                _textField(_phoneController, '+92 3XX XXXXXXX'),
                const SizedBox(height: 16),
                _inputLabel('Gender', LucideIcons.user),
                _genderRadio(),
                const SizedBox(height: 16),
                _inputLabel('Permanent Address', LucideIcons.mapPin),
                _textField(_addressController, 'Hostel/Home Details'),
                const SizedBox(height: 32),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    if (_submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, color: Colors.white.withOpacity(0.5), size: 64),
            const SizedBox(height: 16),
            const Text('No records found', style: TextStyle(color: Colors.white70, fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _submissions.length,
      itemBuilder: (context, index) {
        final item = _submissions[index];
        return FadeInRight(
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _glassContainer(
              padding: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Text(item.gender, style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: () => _startEdit(item), icon: const Icon(LucideIcons.edit2, size: 18, color: Colors.blue)),
                          IconButton(onPressed: () => _deleteRecord(item.id!), icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  _recordInfo(LucideIcons.mail, item.email),
                  _recordInfo(LucideIcons.phone, item.phoneNumber),
                  _recordInfo(LucideIcons.mapPin, item.address),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'ID: ${item.id?.substring(0, 8)}...',
                      style: const TextStyle(fontSize: 10, color: Colors.black26),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _glassContainer({required Widget child, double padding = 24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _formHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 24),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _inputLabel(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6366F1)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Field is required';
        if (isEmail && !v.contains('@')) return 'Invalid email address';
        return null;
      },
    );
  }

  Widget _genderRadio() {
    return Row(
      children: ['Male', 'Female', 'Other'].map((g) {
        return Expanded(
          child: RadioListTile<String>(
            title: Text(g, style: const TextStyle(fontSize: 12)),
            value: g,
            groupValue: _gender,
            activeColor: const Color(0xFF6366F1),
            onChanged: (v) => setState(() => _gender = v!),
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Submit Quiz Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(LucideIcons.plus),
              ],
            ),
      ),
    );
  }

  Widget _recordInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 13))),
        ],
      ),
    );
  }

  void _startEdit(Submission item) {
    final nameEdit = TextEditingController(text: item.fullName);
    final emailEdit = TextEditingController(text: item.email);
    final phoneEdit = TextEditingController(text: item.phoneNumber);
    final addrEdit = TextEditingController(text: item.address);
    String genderEdit = item.gender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(nameEdit, 'Name'),
                const SizedBox(height: 10),
                _textField(emailEdit, 'Email', isEmail: true),
                const SizedBox(height: 10),
                _textField(phoneEdit, 'Phone'),
                const SizedBox(height: 10),
                _textField(addrEdit, 'Address'),
                const SizedBox(height: 10),
                Row(
                  children: ['Male', 'Female', 'Other'].map((g) {
                    return Expanded(
                      child: RadioListTile<String>(
                        title: Text(g, style: const TextStyle(fontSize: 10)),
                        value: g,
                        groupValue: genderEdit,
                        onChanged: (v) => setDialogState(() => genderEdit = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updated = Submission(
                  fullName: nameEdit.text,
                  email: emailEdit.text,
                  phoneNumber: phoneEdit.text,
                  address: addrEdit.text,
                  gender: genderEdit,
                );
                await _service.updateSubmission(item.id!, updated);
                Navigator.pop(context);
                _showSuccess('Updated');
                _fetchRecords();
              }, 
              child: const Text('Save')
            ),
          ],
        ),
      ),
    );
  }
}
