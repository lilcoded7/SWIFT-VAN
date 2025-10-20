import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const SwiftVanApp());
}

class SwiftVanApp extends StatelessWidget {
  const SwiftVanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftVan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E6FFF),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
