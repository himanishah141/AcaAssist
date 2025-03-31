import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const SetPasswordScreen({super.key});
  @override
  SetPasswordScreenState createState() => SetPasswordScreenState();
}

class SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  // Set password function
  Future<void> _setPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a password.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters long.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one uppercase letter.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one lowercase letter.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one digit.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one special character.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your password.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: SetPasswordScreen.primaryColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Set the password
        await user.updatePassword(password);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password set successfully! Please log in again.'),
              backgroundColor: SetPasswordScreen.primaryColor,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set password: ${e.toString()}'),
            backgroundColor: SetPasswordScreen.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04; // Responsive font size

    return Scaffold(
      backgroundColor: SetPasswordScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: SetPasswordScreen.backgroundColor,
        iconTheme: IconThemeData(color: SetPasswordScreen.textColor),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            "Set Password",
            style: TextStyle(
              color: SetPasswordScreen.textColor,
              fontSize: fontSize * 1.5, // Title font size adjusted
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.03),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      children: [
                        _buildLabel("Password", fontSize),
                        _buildInputField(
                          _passwordController,
                          _isPasswordHidden,
                              () => setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          }),
                          obscureText: _isPasswordHidden,
                          hintText: "Enter password",
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildLabel("Confirm Password", fontSize),
                        _buildInputField(
                          _confirmPasswordController,
                          _isConfirmPasswordHidden,
                              () => setState(() {
                            _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                          }),
                          obscureText: _isConfirmPasswordHidden,
                          hintText: "Confirm password",
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: _setPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SetPasswordScreen.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                          ),
                          child: Text(
                            "Set Password",
                            style: TextStyle(color: SetPasswordScreen.textColor, fontSize: fontSize * 1.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Color.fromRGBO(0, 0, 0, 0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: SetPasswordScreen.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, double fontSize) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: SetPasswordScreen.textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize * 1.1,  // Adjust font size for responsiveness
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      bool isHidden,
      VoidCallback toggleVisibility,
      {bool obscureText = false,
        String? hintText}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: SetPasswordScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(color: SetPasswordScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: SetPasswordScreen.textColor),
                suffixIcon: GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: SetPasswordScreen.textColor,
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
