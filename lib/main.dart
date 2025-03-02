import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the Splash Screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: SplashScreen(), // Start with Splash Screen
    );
  }
}
