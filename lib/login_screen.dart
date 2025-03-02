import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Define colors as constants
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor, // Background color
      resizeToAvoidBottomInset: true, // Adjusts the body when the keyboard appears
      body: SingleChildScrollView( // Wrap the body in a SingleChildScrollView
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% of screen width
        child: Column(
          children: [
            // Logo - Covers the upper part responsively
            Container(
              width: double.infinity,
              height: screenHeight * 0.3, // Adjust height as needed
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/logo.png"), fit: BoxFit.cover),
              ),
            ),

            // Title directly below the logo (No extra padding)
            Center(
              child: Text(
                "Login to your account",
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Scales with screen width
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // Login Form
            SizedBox(height: screenHeight * 0.02), // Space before the form
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Input
                _buildInputLabel("Email", screenWidth),
                SizedBox(height: 5),
                _inputField("Enter your email"),

                SizedBox(height: screenHeight * 0.015),

                // Password Input
                _buildInputLabel("Password", screenWidth),
                SizedBox(height: 5),
                _inputField("Enter your password", obscureText: true),

                SizedBox(height: screenHeight * 0.02),

                // Login Button
                _buildLoginButton(screenHeight, screenWidth),

                SizedBox(height: screenHeight * 0.015),

                // OR Divider
                _buildOrDivider(screenWidth),

                SizedBox(height: screenHeight * 0.015),

                // Google Login Button
                _buildGoogleLoginButton(screenHeight, screenWidth),

                SizedBox(height: screenHeight * 0.03),

                // Signup Option
                _buildSignupOption(screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
    );
  }

  Widget _inputField(String hintText, {bool obscureText = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12; // Dynamic height

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              obscureText: obscureText,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: textColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(double screenHeight, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.065, // 6.5% of screen height
      child: ElevatedButton(
        onPressed: () {
          // Handle login logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Login",
          style: TextStyle(
            fontSize: screenWidth * 0.05, // Adjusts with screen size
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(double screenWidth) {
    return Row(
      children: [
        Expanded(child: Divider(color: textColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "OR",
            style: TextStyle(color: textColor, fontSize: screenWidth * 0.045),
          ),
        ),
        Expanded(child: Divider(color: textColor)),
      ],
    );
  }

  Widget _buildGoogleLoginButton(double screenHeight, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.065,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle Google login logic
        },
        icon: Image.asset("assets/google-logo.png", height: screenHeight * 0.03),
        label: Text(
          "Continue with Google",
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: primaryColor,
          side: BorderSide(color: textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupOption(double screenWidth) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: textColor, fontSize: screenWidth * 0.04),
          children: [
            TextSpan(
              text: "Sign up",
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}