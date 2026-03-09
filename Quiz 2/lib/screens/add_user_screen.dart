import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import '../model.dart';

class AddUserScreen extends StatefulWidget {

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {

  final name = TextEditingController();
  final email = TextEditingController();
  final age = TextEditingController();

  String imagePath="";

  final picker = ImagePicker();

  pickImage() async {

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if(picked!=null){

      imagePath=picked.path;

      setState(() {});
    }
  }

  addUser() async{

    final user = User(
      name: name.text,
      email: email.text,
      age: age.text,
      image: imagePath,
    );

    await DatabaseHelper.instance.insertUser(user);

    ScaffoldMessenger.of(context)
        .showSnackBar(
        SnackBar(content: Text("User Added"))
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Add User"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

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

            SizedBox(height:20),

            ElevatedButton(
                onPressed: pickImage,
                child: Text("Pick Image")
            ),

            SizedBox(height:20),

            ElevatedButton(
                onPressed: addUser,
                child: Text("Add User")
            )
          ],
        ),
      ),
    );
  }
}