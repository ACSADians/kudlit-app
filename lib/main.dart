import 'package:flutter/material.dart';

void main() {
  runApp(const KudlitApp());
}

class KudlitApp extends StatelessWidget {
  const KudlitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kudlit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Kudlit'),
        ),
      ),
    );
  }
}
