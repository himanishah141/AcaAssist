import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Define the background color (same as LoginScreen)
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color textColor = Color(0xFFD6E4F0);

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,  // Set background color
      body: Center(
        child: Text(
          "Welcome to Homepage", // Display text
          style: TextStyle(
            fontSize: screenWidth * 0.06, // Adjust text size according to screen width
            fontWeight: FontWeight.bold,
            color: textColor, // Set text color
          ),
        ),
      ),
    );
  }
}
