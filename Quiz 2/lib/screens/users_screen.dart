import 'dart:io';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../model.dart';
import 'package:image_picker/image_picker.dart';

// ---------------- USER DETAILS SCREEN ----------------
class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            user.image.isNotEmpty
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(File(user.image)),
                  )
                : CircleAvatar(
                    radius: 60,
                    child: Icon(Icons.person, size: 60),
                  ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Name"),
              subtitle: Text(user.name),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: Icon(Icons.cake),
              title: Text("Age"),
              subtitle: Text(user.age),
            ),
            // Optional: Add more fields like Phone, Address if stored in DB
          ],
        ),
      ),
    );
  }
}

// ---------------- MAIN USERS SCREEN ----------------
class UsersScreen extends StatefulWidget {
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];

  final name = TextEditingController();
  final email = TextEditingController();
  final age = TextEditingController();

  String imagePath = "";

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  loadUsers() async {
    users = await DatabaseHelper.instance.getUsers();
    filteredUsers = users;
    setState(() {});
  }

  // ---------------- SEARCH FUNCTION ----------------
  searchUser(String keyword) {
    final result = users
        .where((user) =>
            user.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    setState(() {
      filteredUsers = result;
    });
  }

  // ---------------- IMAGE PICKER ----------------
  pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      imagePath = picked.path;
      setState(() {});
    }
  }

  // ---------------- UPDATE USER ----------------
  updateUser(User user) async {
    final updated = User(
      id: user.id,
      name: name.text,
      email: email.text,
      age: age.text,
      image: imagePath,
    );

    await DatabaseHelper.instance.updateUser(updated);

    Navigator.pop(context);

    loadUsers();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("User Updated Successfully")));
  }

  // ---------------- DELETE USER ----------------
  deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    loadUsers();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("User Deleted")));
  }

  // ---------------- DELETE CONFIRMATION ----------------
  confirmDelete(int id) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this user?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteUser(id);
                  },
                  child: Text("Delete"))
            ],
          );
        });
  }

  // ---------------- EDIT DIALOG ----------------
  editDialog(User user) {
    name.text = user.name;
    email.text = user.email;
    age.text = user.age;
    imagePath = user.image;

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Edit User"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: age,
                    decoration: InputDecoration(labelText: "Age"),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: pickImage, child: Text("Change Image")),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    updateUser(user);
                  },
                  child: Text("Update"))
            ],
          );
        });
  }

  // ---------------- SORT DIALOG ----------------
  sortDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Sort Users"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Name A-Z"),
                  onTap: () {
                    filteredUsers.sort((a, b) => a.name.compareTo(b.name));
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Name Z-A"),
                  onTap: () {
                    filteredUsers.sort((a, b) => b.name.compareTo(a.name));
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Users"),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                sortDialog();
              })
        ],
      ),
      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search User...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: searchUser,
            ),
          ),
          // ---------------- USERS LIST ----------------
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (_, i) {
                final user = filteredUsers[i];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserDetailsScreen(user: user)),
                      );
                    },
                    leading: user.image.isNotEmpty
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: FileImage(File(user.image)),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Icon(Icons.person),
                          ),
                    title: Text(user.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user.email}\nAge: ${user.age}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              editDialog(user);
                            }),
                        IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              confirmDelete(user.id!);
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}