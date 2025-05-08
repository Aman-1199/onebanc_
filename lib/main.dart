import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isHindi = false;

  void toggleLanguage() {
    setState(() {
      isHindi = !isHindi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneBanc Restaurant',
      home: HomeScreen(
        isHindi: isHindi,
        onLanguageToggle: toggleLanguage,
      ),
    );
  }
}
