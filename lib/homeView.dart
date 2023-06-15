import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:memora_life/firebaseWrapper.dart';
import 'package:memora_life/loginView.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(),
          ),
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        FirebaseWrapper.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Set the button background color
                        foregroundColor: Colors.white, // Set the text color
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
