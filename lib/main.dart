import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:sizer/sizer.dart';

import 'auths/login.dart';
import 'auths/signup.dart';
import 'screens/requestRide.dart';
import 'screens/tracking.dart';

void main() {
  runApp(const SwiftVanApp());
}

class SwiftVanApp extends StatelessWidget {
  const SwiftVanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'SwiftVan',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF1E6FFF),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          initialRoute: '/login',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/request': (context) => const DeliveryRequestFormScreen(),
            '/tracking': (context) => const DeliveryTrackingScreen(),
          },
        );
      },
    );
  }
}
