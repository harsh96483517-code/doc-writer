import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DocWriterApp());
}

class DocWriterApp extends StatelessWidget {
  const DocWriterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocWriter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3F51B5),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
