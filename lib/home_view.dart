import 'package:flutter/material.dart';
import 'package:memora_life/firebase_wrapper.dart';
import 'package:memora_life/login_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SfCalendar(
                  view: CalendarView.month,
                ),
              ),
            ),
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
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
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
