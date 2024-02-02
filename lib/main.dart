import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_food_ordering/firebase_options.dart';
import 'package:flutter_food_ordering/pages/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering',
      theme: ThemeData(
        colorSchemeSeed: Colors.lightGreen,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      // darkTheme: ThemeData(
      //   colorSchemeSeed: Colors.lightGreen,
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      // ),
      home: const AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}