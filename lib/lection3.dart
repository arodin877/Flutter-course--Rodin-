import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        
        child: Container(
          height: 500,
          width: 200,
          color: Colors.black,
          child: Container(
            margin: EdgeInsets.all(10),
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.lock),
            ),
          ),
        ),
      ),
    ),
  );
}
}
