import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khoa Hoc Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFCC33)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
