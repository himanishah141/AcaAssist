import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Define colors as constants
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo
              Container(
                width: double.infinity,
                height: screenHeight * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/logo.png"), fit: BoxFit.cover),
                ),
              ),
              Center(
                child: Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Input
                  _buildInputLabel("Email", screenWidth),
                  SizedBox(height: 5),
                  _inputField("Enter your email", _emailController),

                  SizedBox(height: screenHeight * 0.015),

                  // Password Input
                  _buildInputLabel("Password", screenWidth),
                  SizedBox(height: 5),
                  _passwordInputField("Enter your password", _passwordController),

                  SizedBox(height: screenHeight * 0.02),

                  // Login Button
                  _buildLoginButton(context, screenHeight, screenWidth),

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
      ),
    );
  }

  Widget _buildInputLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
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

  Widget _passwordInputField(String hintText, TextEditingController controller) {
    return _PasswordField(hintText: hintText, controller: controller);
  }

  Widget _buildLoginButton(BuildContext context, double screenHeight, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.065,
      child: ElevatedButton(
        onPressed: () {
          // Validate email
          if (_emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter your email.'),
                backgroundColor: primaryColor, // Use primaryColor for the SnackBar
              ),
            );
            return;
          }

          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a valid email.'),
                backgroundColor: primaryColor, // Use primaryColor for the SnackBar
              ),
            );
            return;
          }

          // Validate password (only check if it's not empty)
          if (_passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter your password.'),
                backgroundColor: primaryColor, // Use primaryColor for the SnackBar
              ),
            );
            return;
          }

          // Handle login logic here
          // For example, you can call your authentication service
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
            fontSize: screenWidth * 0.05,
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

class _PasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const _PasswordField({required this.hintText, required this.controller});

  @override
  __PasswordFieldState createState() => __PasswordFieldState();
}

class __PasswordFieldState extends State<_PasswordField> {
  bool _isHidden = true; // State variable to track password visibility

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden; // Toggle the visibility state
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12; // Dynamic height

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: LoginScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isHidden, // Control visibility with the state variable
              style: TextStyle(color: LoginScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: LoginScreen.textColor),
                suffixIcon: InkWell(
                  onTap: _togglePasswordView, // Toggle visibility on tap
                  child: Icon(
                    _isHidden ? Icons.visibility : Icons.visibility_off, // Change icon based on state
                    color: LoginScreen.textColor, // Set the icon color
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}