import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [
              Colors.deepPurple,
              Colors.purpleAccent
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(
                Icons.storage,
                color: Colors.white,
                size: 100,
              ),

              SizedBox(height:20),

              Text(
                "User Manager",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height:40),

              ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal:40,
                      vertical:15
                  ),
                ),

                icon: Icon(Icons.person_add),

                label: Text("Add User"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_)=>AddUserScreen()
                    ),
                  );
                },
              ),

              SizedBox(height:20),

              ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal:40,
                      vertical:15
                  ),
                ),

                icon: Icon(Icons.list),

                label: Text("View Users"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_)=>UsersScreen()
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}