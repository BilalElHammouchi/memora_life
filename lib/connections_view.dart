import 'package:flutter/material.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({Key? key}) : super(key: key);

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  List<String> connections = [];
  List<String> buildings = [];
  List<String> rooms = [];

  void addConnection(String user) {
    setState(() {
      connections.add(user);
    });
  }

  void addBuilding(String building) {
    setState(() {
      buildings.add(building);
    });
  }

  void addRoom(String room) {
    setState(() {
      rooms.add(room);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Icon(
                  Icons.people,
                  size: 100,
                ),
                const Text('Connections'),
                ElevatedButton(
                  onPressed: () {
                    addConnection('New Connection');
                  },
                  child: const Text('Add Connection'),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(connections[index]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            child: Column(
              children: [
                Icon(
                  Icons.house,
                  size: 100,
                ),
                const Text('Buildings and Rooms'),
                ElevatedButton(
                  onPressed: () {
                    addBuilding('New Building');
                  },
                  child: const Text('Add Building'),
                ),
                ElevatedButton(
                  onPressed: () {
                    addRoom('New Room');
                  },
                  child: const Text('Add Room'),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: buildings.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(buildings[index]),
                    );
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(rooms[index]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
