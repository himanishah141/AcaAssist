import 'package:aca_assist/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  // Define colors as constants
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Register",style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
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
                  "Create your account",
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
                  // First Name Input
                  _buildInputLabel("First Name", screenWidth),
                  SizedBox(height: 5),
                  _inputField("Enter your first name", _firstNameController),

                  SizedBox(height: screenHeight * 0.015),

                  // Last Name Input
                  _buildInputLabel("Last Name", screenWidth),
                  SizedBox(height: 5),
                  _inputField("Enter your last name", _lastNameController),

                  SizedBox(height: screenHeight * 0.015),

                  // Email Input
                  _buildInputLabel("Email", screenWidth),
                  SizedBox(height: 5),
                  _inputField("Enter your email", _emailController),

                  SizedBox(height: screenHeight * 0.015),

                  // Password Input
                  _buildInputLabel("Password", screenWidth),
                  SizedBox(height: 5),
                  _passwordInputField("Enter your password", _passwordController),

                  SizedBox(height: screenHeight * 0.015),

                  // Confirm Password Input
                  _buildInputLabel("Confirm Password", screenWidth),
                  SizedBox(height: 5),
                  _passwordInputField("Confirm your password", _confirmPasswordController),

                  SizedBox(height: screenHeight * 0.02),

                  // Sign Up Button
                  _buildSignUpButton(context, screenHeight, screenWidth),

                  SizedBox(height: screenHeight * 0.03),

                  // Already have an account text
                  _buildLoginOption(context,screenWidth),
                ],
              ),
              SizedBox(height: screenHeight * 0.05), // Add bottom padding
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

  Widget _buildSignUpButton(BuildContext context, double screenHeight, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.065,
      child: ElevatedButton(
        onPressed: () {
          // Validate the form
          if (_firstNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your first name.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (_lastNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your last name.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (_emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your email.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter a valid email.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (_passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your password.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          String password = _passwordController.text;
          // Password constraints
          if (password.length < 8) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password must be at least 8 characters.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (!RegExp(r'[A-Z]').hasMatch(password)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password must contain at least one uppercase letter.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (!RegExp(r'[a-z]').hasMatch(password)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password must contain at least one lowercase letter.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (!RegExp(r'[0-9]').hasMatch(password)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password must contain at least one digit.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password must contain at least one special character.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (_confirmPasswordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please confirm your password.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
          if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Passwords do not match.'),
              backgroundColor: primaryColor,),
            );
            return;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Register",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
  Widget _buildLoginOption(BuildContext context, double screenWidth) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: textColor, fontSize: screenWidth * 0.04),
          children: [
            TextSpan(
              text: "Sign In",
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap=() {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }
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
            color: RegistrationScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isHidden, // Control visibility with the state variable
              style: TextStyle(color: RegistrationScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: RegistrationScreen.textColor),
                suffixIcon: InkWell(
                  onTap: _togglePasswordView, // Toggle visibility on tap
                  child: Icon(
                    _isHidden ? Icons.visibility : Icons.visibility_off, // Change icon based on state
                    color: RegistrationScreen.textColor, // Set the icon color
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