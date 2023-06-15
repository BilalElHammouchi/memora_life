import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memora_life/firebaseWrapper.dart';
import 'package:memora_life/homeView.dart';
import 'package:memora_life/loginView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _futureInitializer;

  @override
  void initState() {
    if (kIsWeb) {
      _futureInitializer = FirebaseWrapper.initialize();
    } else {
      _futureInitializer = Future(
        () => null,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoraLife',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: _futureInitializer,
          builder: (context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const MaterialApp(home: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (kIsWeb) {
                    FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
                  }
                  if (!kIsWeb) return const HomePage();
                  if (FirebaseWrapper.auth.currentUser != null) {
                    return const HomePage();
                  } else {
                    return const Scaffold(
                      body: LoginScreen(),
                      backgroundColor: Colors.pink,
                    );
                  }
                }
            }
          }),
    );
  }
}
