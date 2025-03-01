import 'package:flutter/material.dart';
// import 'show_tasks.dart'; // Import your ShowTask widget
import 'show_tasks2.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home:ShowTask2(), // Use your ShowTask widget here
    );
  }
}

