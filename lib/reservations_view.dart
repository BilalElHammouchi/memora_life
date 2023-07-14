// ignore_for_file: use_build_context_synchronously

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_picker_free/map_picker_free.dart';
import 'package:memora_life/firebase_wrapper.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  Image? reservationImage;
  TextEditingController reservationController = TextEditingController();
  late XFile? reservationImageXFile;
  late String address;
  late double longitude;
  late double latitude;
  late Future<List<Map<String, dynamic>>> _getReservations;

  @override
  void initState() {
    _getReservations = FirebaseWrapper.getReservations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.blue,
            child: LayoutBuilder(builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.house,
                                size: 100,
                                color: Colors.white,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 50.0, right: 50, top: 20),
                            child: TextField(
                              controller:
                                  reservationController, // Use your own TextEditingController
                              decoration: InputDecoration(
                                hintText: 'Reservation Name',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 600,
                              height: 450,
                              child: MapPicker(
                                  showZoomButtons: true,
                                  center: LatLong(
                                      35.06549045176039, -2.9126700400333707),
                                  onPicked: (pickedData) {
                                    setState(() {
                                      longitude = pickedData.latLong.longitude;
                                      latitude = pickedData.latLong.latitude;
                                      address = pickedData.address;
                                    });
                                  }),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: 600,
                            height: 450,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: reservationImage ??
                                      const Icon(
                                        Icons.image,
                                        size: 450,
                                        color: Colors.white,
                                      ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 65.0),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.black),
                                      ),
                                      onPressed: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        reservationImageXFile =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);
                                        if (reservationImageXFile != null) {
                                          try {
                                            setState(() {
                                              reservationImage = Image.network(
                                                  reservationImageXFile!.path);
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                        }
                                      },
                                      child: const Text('Add Image'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<CircleBorder>(
                                const CircleBorder(),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                            ),
                            onPressed: () async {
                              if (await FirebaseWrapper.isReservationNameUnique(
                                  reservationController.text)) {
                                if (await FirebaseWrapper.addReservation(
                                    reservationController.text,
                                    reservationImageXFile,
                                    latitude,
                                    longitude,
                                    address)) {
                                  ElegantNotification.success(
                                      width: 100,
                                      title: const Text(
                                        "Success",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      description: const Text(
                                        "Reservation added successfully.",
                                        style: TextStyle(color: Colors.black),
                                      )).show(context);
                                  reservationController.clear();
                                  reservationImage = null;
                                  reservationImageXFile = null;
                                } else {
                                  ElegantNotification.error(
                                      width: 100,
                                      title: const Text(
                                        "Error",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      description: const Text(
                                        "Error occurred adding reservation",
                                        style: TextStyle(color: Colors.black),
                                      )).show(context);
                                }
                              } else {
                                ElegantNotification.error(
                                    width: 100,
                                    title: const Text(
                                      "Reservation Name Duplicate",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    description: const Text(
                                      "a reservation by that name already exists",
                                      style: TextStyle(color: Colors.black),
                                    )).show(context);
                              }
                            },
                            child: const Icon(
                              Icons.check,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(children: [
                  Icon(
                    Icons.house,
                    size: 100,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                  )
                ]),
              ),
              Flexible(
                child: FutureBuilder(
                  future: _getReservations,
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const MaterialApp(
                            home: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> reservation =
                                        snapshot.data![index];
                                    String reservationName =
                                        reservation['reservationName'];
                                    String address = reservation['address'];
                                    double longitude = reservation['longitude'];
                                    double latitude = reservation['latitude'];
                                    String? imagePath =
                                        reservation['imagePath'];

                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          leading: imagePath != null
                                              ? SizedBox(
                                                  width: 100,
                                                  height: 100,
                                                  child: Image.network(
                                                    imagePath,
                                                    fit: BoxFit.contain,
                                                  ),
                                                )
                                              : null,
                                          title: Text(reservationName),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(address),
                                            ],
                                          ),
                                          trailing: Column(
                                            children: [
                                              Text(
                                                'Latitude: $latitude',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              Text('Longitude: $longitude',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          );
                        }
                    }
                  },
                ),
              )
            ]),
          ),
        )
      ],
    );
  }
}
