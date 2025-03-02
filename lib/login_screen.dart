import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF5C6B7D), // Background color
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% of screen width
        child: Column(
          children: [
            // Logo - Covers the upper part responsively
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/logo.png"),fit: BoxFit.cover, ),
                ),
              ),
            ),

            // Title directly below the logo (No extra padding)
            Center(
              child: Text(
                "Login to your account",
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Scales with screen width
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD6E4F0),
                ),
              ),
            ),

            // Login Form
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height

                  // Email Input
                  Text("Email",
                      style: TextStyle(color: Color(0xFFD6E4F0),fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
                  SizedBox(height: 5),
                  inputField("Enter your email"),

                  SizedBox(height: screenHeight * 0.015),

                  // Password Input
                  Text("Password",
                      style: TextStyle(color: Color(0xFFD6E4F0),fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045)),
                  SizedBox(height: 5),
                  inputField("Enter your password", obscureText: true),

                  SizedBox(height: screenHeight * 0.02),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065, // 6.5% of screen height
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8196B0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05, // Adjusts with screen size
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD6E4F0),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFD6E4F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "OR",
                          style: TextStyle(color: Color(0xFFD6E4F0), fontSize: screenWidth * 0.045),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFD6E4F0))),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset("assets/google-logo.png", height: screenHeight * 0.03),
                      label: Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD6E4F0),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFF8196B0),
                        side: BorderSide(color: Color(0xFFD6E4F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Signup Option
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Color(0xFFD6E4F0), fontSize: screenWidth * 0.04),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: Color(0xFFD6E4F0),
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Input Field Widget (Responsive)
  Widget inputField(String hintText, {bool obscureText = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12; // Dynamic height

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: Color(0xFF8196B0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              obscureText: obscureText,
              style: TextStyle(color: Color(0xFFD6E4F0)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Color(0xFFD6E4F0)),
              ),
            ),
          ),
        );
      },
    );
  }
}