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
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                print("Send to user number: $index");
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
            child: const Column(
              children: [],
            ),
          ),
        ),
      ],
    );
  }
}
