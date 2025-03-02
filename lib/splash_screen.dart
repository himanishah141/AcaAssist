import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aca_assist/login_screen.dart';

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
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5C6B7D), // Set background color
      body: Center(
        child: Image.asset("assets/logo.png", fit: BoxFit.contain), // Replace with your logo
      ),
    );
  }
}
