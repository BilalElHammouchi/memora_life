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
  final CalendarController _controller = CalendarController();
  late String selectedValue;
  bool _showAgenda = true;

  @override
  void initState() {
    selectedValue = "Month";
    _controller.view = CalendarView.month;
    super.initState();
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Month", child: Text("Month")),
      const DropdownMenuItem(value: "Week", child: Text("Week")),
      const DropdownMenuItem(value: "Work Week", child: Text("Work Week")),
      const DropdownMenuItem(value: "Day", child: Text("Day")),
      const DropdownMenuItem(value: "Schedule", child: Text("Schedule")),
      const DropdownMenuItem(
          value: "Month Timeline", child: Text("Month Timeline")),
      const DropdownMenuItem(
          value: "Week Timeline", child: Text("Week Timeline")),
      const DropdownMenuItem(
          value: "Day Timeline", child: Text("Day Timeline")),
    ];
    return menuItems;
  }

  Color? _headerColor, _viewHeaderColor, _calendarColor;

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
                  controller: _controller,
                  monthViewSettings: MonthViewSettings(showAgenda: _showAgenda),
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
                    DropdownButton(
                      value: selectedValue,
                      items: dropdownItems,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                          switch (value) {
                            case 'Month':
                              _controller.view = CalendarView.month;
                              break;
                            case 'Week':
                              _controller.view = CalendarView.week;
                              break;
                            case 'Work Week':
                              _controller.view = CalendarView.workWeek;
                              break;
                            case 'Day':
                              _controller.view = CalendarView.day;
                              break;
                            case 'Schedule':
                              _controller.view = CalendarView.schedule;
                              break;
                            case 'Month Timeline':
                              _controller.view = CalendarView.timelineMonth;
                              break;
                            case 'Week Timeline':
                              _controller.view = CalendarView.timelineWeek;
                              break;
                            case 'Day Timeline':
                              _controller.view = CalendarView.timelineDay;
                              break;
                          }
                        });
                      },
                    ),
                    if (_controller.view == CalendarView.month)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("show Agenda"),
                          Checkbox(
                            value: _showAgenda,
                            onChanged: (value) {
                              setState(() {
                                _showAgenda = value!;
                              });
                            },
                          ),
                        ],
                      ),
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
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
