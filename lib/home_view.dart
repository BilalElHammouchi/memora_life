import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:memora_life/firebase_wrapper.dart';
import 'package:memora_life/login_view.dart';
import 'package:memora_life/main.dart';
import 'package:memora_life/profile_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CalendarController _controller = CalendarController();
  late String selectedValue;
  double containerHeight = 0;
  bool _showAgenda = true;
  Time eventStartTime = Time(hour: 09, minute: 00);
  Time eventEndTime = Time(hour: 12, minute: 00);
  late DateTime eventStartDate;
  late DateTime eventEndDate;
  MeetingDataSource _meetingDataSource =
      MeetingDataSource(<Appointment>[]); // Events List
  Color pickerColor = Colors.red;
  Color eventColor = Colors.red;
  TextEditingController eventName = TextEditingController();
  List<DateTime?> datePicker = [];

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

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            MyApp.currentPageIndex = index;
          });
        },
        selectedIndex: MyApp.currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_pin),
            label: 'Locations',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: <Widget>[
        Row(children: [
          Expanded(
            flex: 3,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SfCalendar(
                  showNavigationArrow: true,
                  view: CalendarView.month,
                  controller: _controller,
                  dataSource: _meetingDataSource,
                  monthViewSettings: MonthViewSettings(
                      showAgenda: _showAgenda,
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                ),
              ),
            ),
          ),
          Flexible(
              flex: 1,
              child: Container(
                color: Colors.blue,
                child: LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
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
                                      _controller.view =
                                          CalendarView.timelineMonth;
                                      break;
                                    case 'Week Timeline':
                                      _controller.view =
                                          CalendarView.timelineWeek;
                                      break;
                                    case 'Day Timeline':
                                      _controller.view =
                                          CalendarView.timelineDay;
                                      break;
                                  }
                                });
                              },
                            ),
                            if (_controller.view == CalendarView.month)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("show Agenda"),
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
                            Flexible(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: containerHeight,
                                child: containerHeight > 0
                                    ? FutureBuilder(
                                        future: Future.delayed(
                                            const Duration(milliseconds: 200)),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Flexible(
                                                          child: TextField(
                                                            controller:
                                                                eventName,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Event Name',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                              border:
                                                                  const OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey[200],
                                                            ),
                                                          ),
                                                        ),
                                                        Flexible(
                                                            child:
                                                                FloatingActionButton(
                                                          onPressed: () {
                                                            _dialogBuilder(
                                                                context);
                                                          },
                                                          backgroundColor:
                                                              eventColor,
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: Colors.white,
                                                      ),
                                                      child:
                                                          CalendarDatePicker2(
                                                        config:
                                                            CalendarDatePicker2Config(),
                                                        value: datePicker,
                                                        onValueChanged:
                                                            (dates) {
                                                          datePicker = dates;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Event Start Time Picker
                                                Flexible(
                                                  child: SizedBox(
                                                    width: 250,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          showPicker(
                                                            onChangeDateTime:
                                                                (p0) {
                                                              if (p0.hour >
                                                                      eventEndTime
                                                                          .hour ||
                                                                  (p0.hour ==
                                                                          eventEndTime
                                                                              .hour &&
                                                                      p0.minute >
                                                                          eventEndTime
                                                                              .minute)) {
                                                                ElegantNotification
                                                                    .error(
                                                                        width:
                                                                            100,
                                                                        title:
                                                                            const Text(
                                                                          "Event Inconsistency",
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        description:
                                                                            const Text(
                                                                          "Event start should be before the end of the event",
                                                                          style:
                                                                              TextStyle(color: Colors.black),
                                                                        )).show(
                                                                    context);
                                                              }
                                                            },
                                                            is24HrFormat: true,
                                                            sunAsset: const Image(
                                                                image: AssetImage(
                                                                    "assets/sun.png")),
                                                            moonAsset: const Image(
                                                                image: AssetImage(
                                                                    "assets/moon.png")),
                                                            context: context,
                                                            value:
                                                                eventStartTime,
                                                            onChange:
                                                                (Time newTime) {
                                                              setState(() {
                                                                eventStartTime =
                                                                    newTime;
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              "Event Start Time",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 2.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        right:
                                                                            BorderSide(
                                                                          color:
                                                                              Colors.red,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8.0,
                                                                        vertical:
                                                                            4.0),
                                                                    child: Text(
                                                                      eventStartTime
                                                                          .hour
                                                                          .toString()
                                                                          .padLeft(
                                                                              2,
                                                                              '0'),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8.0,
                                                                        vertical:
                                                                            4.0),
                                                                    child: Text(
                                                                      eventStartTime
                                                                          .minute
                                                                          .toString()
                                                                          .padLeft(
                                                                              2,
                                                                              '0'),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Event End Time Picker
                                                Flexible(
                                                  child: SizedBox(
                                                    width: 250,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          showPicker(
                                                            onChangeDateTime:
                                                                (p0) {
                                                              if (p0.hour <
                                                                      eventStartTime
                                                                          .hour ||
                                                                  (p0.hour ==
                                                                          eventStartTime
                                                                              .hour &&
                                                                      p0.minute <
                                                                          eventStartTime
                                                                              .minute)) {
                                                                ElegantNotification
                                                                    .error(
                                                                        width:
                                                                            100,
                                                                        title:
                                                                            const Text(
                                                                          "Event Inconsistency",
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        description:
                                                                            const Text(
                                                                          "Event end should be after the start of the event",
                                                                          style:
                                                                              TextStyle(color: Colors.black),
                                                                        )).show(
                                                                    context);
                                                              }
                                                            },
                                                            is24HrFormat: true,
                                                            sunAsset: const Image(
                                                                image: AssetImage(
                                                                    "assets/sun.png")),
                                                            moonAsset: const Image(
                                                                image: AssetImage(
                                                                    "assets/moon.png")),
                                                            context: context,
                                                            value: eventEndTime,
                                                            onChange:
                                                                (Time newTime) {
                                                              setState(() {
                                                                eventEndTime =
                                                                    newTime;
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              "Event End Time",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 2.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        right:
                                                                            BorderSide(
                                                                          color:
                                                                              Colors.red,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8.0,
                                                                        vertical:
                                                                            4.0),
                                                                    child: Text(
                                                                      eventEndTime
                                                                          .hour
                                                                          .toString()
                                                                          .padLeft(
                                                                              2,
                                                                              '0'),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8.0,
                                                                        vertical:
                                                                            4.0),
                                                                    child: Text(
                                                                      eventEndTime
                                                                          .minute
                                                                          .toString()
                                                                          .padLeft(
                                                                              2,
                                                                              '0'),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return const SizedBox(); // Display an empty container while waiting
                                          }
                                        },
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                            // Add/Confirm Event
                            FloatingActionButton(
                              onPressed: () {},
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (containerHeight == 0) {
                                        containerHeight = 500;
                                      } else {
                                        if (eventEndTime.hour <
                                                eventStartTime.hour ||
                                            (eventEndTime.hour ==
                                                    eventStartTime.hour &&
                                                eventEndTime.minute <
                                                    eventStartTime.minute)) {
                                          ElegantNotification.error(
                                              width: 100,
                                              title: const Text(
                                                "Event Inconsistency",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              description: const Text(
                                                "Error detected concerning the event timing",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )).show(context);
                                        } else if (eventName.text.isEmpty) {
                                          ElegantNotification.error(
                                              width: 100,
                                              title: const Text(
                                                "Event Inconsistency",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              description: const Text(
                                                "Error detected concerning the event name",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )).show(context);
                                        } else if (datePicker[0]!
                                            .isBefore(DateTime.now())) {
                                          ElegantNotification.error(
                                              width: 100,
                                              title: const Text(
                                                "Event Inconsistency",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              description: const Text(
                                                "Error detected concerning the event date",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )).show(context);
                                        } else {
                                          containerHeight = 0;
                                          eventStartDate = DateTime(
                                              datePicker[0]!.year,
                                              datePicker[0]!.month,
                                              datePicker[0]!.day,
                                              eventStartTime.hour,
                                              eventStartTime.minute);
                                          eventEndDate = DateTime(
                                              datePicker[0]!.year,
                                              datePicker[0]!.month,
                                              datePicker[0]!.day,
                                              eventEndTime.hour,
                                              eventStartTime.hour);
                                          final Appointment app = Appointment(
                                              startTime: eventStartDate,
                                              endTime: eventEndDate,
                                              subject: eventName.text,
                                              color: eventColor);
                                          _meetingDataSource.appointments!
                                              .add(app);
                                          _meetingDataSource.notifyListeners(
                                              CalendarDataSourceAction.add,
                                              <Appointment>[app]);
                                        }
                                      }
                                    });
                                  },
                                  icon: containerHeight == 0
                                      ? const Icon(Icons.add)
                                      : const Icon(Icons.check)),
                            ),
                            // Logout Button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  FirebaseWrapper.signOut();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .red, // Set the button background color
                                  foregroundColor:
                                      Colors.white, // Set the text color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              )),
        ]),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        ProfilePage(),
      ][MyApp.currentPageIndex],
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Got it'),
                onPressed: () {
                  setState(() => eventColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
