import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aca_assist/home_screen.dart';  // Import HomeScreen
import 'package:aca_assist/login_screen.dart'; // Import LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 6 seconds and check if the user is signed in
    Timer(Duration(seconds: 6), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // If the user is signed in, navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // If the user is not signed in, navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
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
