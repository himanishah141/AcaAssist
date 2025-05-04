import 'package:aca_assist/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  // Define colors as constants
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Set initial loading state to false so it doesn't start loading immediately
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: RegistrationScreen.backgroundColor,
      appBar: AppBar(
        title: Text("Register", style: TextStyle(color: RegistrationScreen.textColor,fontSize: fontSize * 1.5)),
        backgroundColor: RegistrationScreen.backgroundColor,
        iconTheme: IconThemeData(color: RegistrationScreen.textColor),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                      style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: RegistrationScreen.textColor),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("First Name", screenWidth),
                      SizedBox(height: 5),
                      _inputField("Enter your first name", _firstNameController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInputLabel("Last Name", screenWidth),
                      SizedBox(height: 5),
                      _inputField("Enter your last name", _lastNameController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInputLabel("Email", screenWidth),
                      SizedBox(height: 5),
                      _inputField("Enter your email", _emailController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInputLabel("Password", screenWidth),
                      SizedBox(height: 5),
                      _passwordInputField("Enter your password", _passwordController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInputLabel("Confirm Password", screenWidth),
                      SizedBox(height: 5),
                      _passwordInputField("Confirm your password", _confirmPasswordController),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSignUpButton(context, screenHeight, screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildLoginOption(context, screenWidth),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: RegistrationScreen.textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(color: RegistrationScreen.textColor, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: RegistrationScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: RegistrationScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: RegistrationScreen.textColor),
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
        onPressed: () async {
          // Trigger registration logic when button is clicked
          if (_isLoading) return; // If loading is active, do nothing

          setState(() {
            _isLoading = true; // Start loading state
          });

          // 🔹 **Validation**
          final nameRegExp = RegExp(r'^[a-zA-Z ]+$');

          // First name validation
          if (_firstNameController.text.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Please enter your first name.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          } else if (!nameRegExp.hasMatch(_firstNameController.text)) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('First name can contain only letters.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          }

          if (_firstNameController.text.contains(' ')) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('First name cannot contain spaces.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          }

          // Last name validation
          if (_lastNameController.text.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Please enter your last name.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          } else if (!nameRegExp.hasMatch(_lastNameController.text)) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Last name can contain only letters.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          }

          if (_lastNameController.text.contains(' ')) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Last name cannot contain spaces.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          }

          if (_emailController.text.isEmpty) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter your email.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (_passwordController.text.isEmpty) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter your password.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }

          if (_passwordController.text.contains(' ')) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Password cannot contain spaces.'),
              backgroundColor: RegistrationScreen.primaryColor,
            ));
            return;
          }

          String password = _passwordController.text;
          if (password.length < 8) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must be at least 8 characters.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (!RegExp(r'[A-Z]').hasMatch(password)) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must contain at least one uppercase letter.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (!RegExp(r'[a-z]').hasMatch(password)) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must contain at least one lowercase letter.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (!RegExp(r'[0-9]').hasMatch(password)) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must contain at least one digit.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must contain at least one special character.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (_confirmPasswordController.text.isEmpty) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please confirm your password.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }
          if (_passwordController.text != _confirmPasswordController.text) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match.'), backgroundColor: RegistrationScreen.primaryColor));
            return;
          }

          // 🔹 **Firestore & Authentication Integration**
          try {
            var existingUser = await FirebaseFirestore.instance
                .collection('Users')
                .where('Email', isEqualTo: _emailController.text)
                .get();

            if (existingUser.docs.isNotEmpty) {
              setState(() {
                _isLoading = false; // Stop loading
              });
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Email is already registered.'),
                    backgroundColor: RegistrationScreen.primaryColor));
              }
              return;
            }

            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

            String uid = userCredential.user!.uid;
            String fullName = "${_firstNameController.text} ${_lastNameController.text}";

            await FirebaseFirestore.instance.collection('Users').doc(uid).set({
              'Uid': uid,
              'Name': fullName,
              'Email': _emailController.text,
            });

            // Send verification email
            await userCredential.user!.sendEmailVerification();

            setState(() {
              _isLoading = false; // Stop loading after registration
            });
            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Registration successful! Please verify your email.'),
                  backgroundColor: RegistrationScreen.primaryColor));
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            }

          } catch (e) {
            setState(() {
              _isLoading = false; // Stop loading on error
            });
            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Email is already registered.'),
                  backgroundColor: RegistrationScreen.primaryColor));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: RegistrationScreen.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("Register", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: RegistrationScreen.textColor)),
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context, double screenWidth) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: RegistrationScreen.textColor, fontSize: screenWidth * 0.04),
          children: [
            TextSpan(
              text: "Sign In",
              style: TextStyle(
                color: RegistrationScreen.textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
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
  bool _isHidden = true;

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;
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
              obscureText: _isHidden,
              style: TextStyle(color: RegistrationScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: RegistrationScreen.textColor),
                suffixIcon: InkWell(
                  onTap: _togglePasswordView,
                  child: Icon(
                    _isHidden ? Icons.visibility : Icons.visibility_off,
                    color: RegistrationScreen.textColor,
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
