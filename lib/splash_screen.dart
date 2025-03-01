import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart'; // Import main.dart to navigate to HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and navigate to HomeScreen
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5C6B7D), // Set background color
      body: Center(
        child: Image.asset("assets/logo.png", width: 200), // Replace with your logo
      ),
    );
  }
}
