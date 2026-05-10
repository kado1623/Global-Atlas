import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CountryExplorerApp());
}

class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // This tells the app to start on your Home Screen
      home: const HomeScreen(), 
    );
  }
}
