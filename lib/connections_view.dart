// ignore_for_file: use_build_context_synchronously

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:memora_life/firebase_wrapper.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({Key? key}) : super(key: key);

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  List<Map<String, dynamic>> userList = [];
  TextEditingController connectionsController = TextEditingController();
  int _isLoading = -1;
  late List<bool> invites;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const Flexible(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(children: [
                      Icon(
                        Icons.people,
                        size: 100,
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.add))
                    ]),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: TextField(
                      controller: connectionsController,
                      decoration: InputDecoration(
                        suffixIcon: _isLoading == 0
                            ? const CircularProgressIndicator()
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = 0;
                                  });
                                  userList =
                                      await FirebaseWrapper.searchUsernames(
                                          connectionsController.text);
                                  invites = List<bool>.generate(
                                      userList.length, (_) => false);
                                  setState(() {
                                    userList = userList;
                                    _isLoading = -1;
                                  });
                                },
                              ),
                        hintText: 'Search connections',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> user = userList[index];
                      String username = user['username'];
                      String? about = user['about'];
                      String? profilePicUrl = user['profilePic'];
                      String? status = user['status'];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: profilePicUrl != null
                                  ? NetworkImage(profilePicUrl)
                                  : const AssetImage('assets/user.png')
                                      as ImageProvider<Object>?,
                            ),
                            title: Text(
                              username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              about ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            trailing: username == FirebaseWrapper.username
                                ? const Icon(Icons.person, color: Colors.blue)
                                : (status == 'pending' ||
                                        invites[index] == true)
                                    ? const Icon(
                                        Icons.pending,
                                        color: Colors.blue,
                                      )
                                    : IconButton(
                                        icon: _isLoading == index + 1
                                            ? const CircularProgressIndicator()
                                            : const Icon(
                                                Icons.send,
                                                color: Colors.blue,
                                              ),
                                        onPressed: () async {
                                          if (_isLoading == -1) {
                                            setState(() {
                                              _isLoading = index + 1;
                                            });
                                            if (await FirebaseWrapper
                                                .sendConnectionRequest(
                                                    userList[index]
                                                        ["username"])) {
                                              ElegantNotification.success(
                                                  width: 100,
                                                  title: const Text(
                                                    "Success",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  description: const Text(
                                                    "Connection request sent successfully.",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )).show(context);
                                              print(invites);
                                              setState(() {
                                                invites[index] = true;
                                              });
                                              print(invites);
                                            } else {
                                              ElegantNotification.error(
                                                  width: 100,
                                                  title: const Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  description: const Text(
                                                    "Connection request unable to be sent.",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )).show(context);
                                            }
                                            print(
                                                "Send to user number: $index");
                                            setState(() {
                                              _isLoading = -1;
                                            });
                                          }
                                        },
                                      ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.blue,
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.people,
                        size: 100,
                        color: Colors.white,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Connections',
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: const Color.fromARGB(
                                          255, 33, 128, 243),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Requests',
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: const Color.fromARGB(
                                          255, 33, 128, 243),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ],
    );
  }
}
