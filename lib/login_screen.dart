import 'package:aca_assist/home_screen.dart';
import 'package:aca_assist/registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
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
                      _buildInputLabel("Email", screenWidth),
                      SizedBox(height: 5),
                      _inputField("Enter your email", _emailController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInputLabel("Password", screenWidth),
                      SizedBox(height: 5),
                      _passwordInputField("Enter your password", _passwordController),
                      SizedBox(height: screenHeight * 0.005),
                      _buildForgotPasswordText(context, screenWidth),
                      SizedBox(height: screenHeight * 0.04),
                      _buildLoginButton(context, screenHeight, screenWidth),
                      SizedBox(height: screenHeight * 0.015),
                      _buildOrDivider(screenWidth),
                      SizedBox(height: screenHeight * 0.015),
                      _buildGoogleLoginButton(screenHeight, screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildSignupOption(context, screenWidth),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Loader - only shown when _isLoading is true
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Color.fromRGBO(0, 0, 0, 0.5), // Apply opacity
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          if (_emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter your email.'),
                backgroundColor: primaryColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a valid email.'),
                backgroundColor: primaryColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          if (_passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter your password.'),
                backgroundColor: primaryColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
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

          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

            if (!userCredential.user!.emailVerified) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Please verify your email before logging in.'),
                    backgroundColor: primaryColor,
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
              }
              return;
            }
            if(context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invalid email or password. Please try again.'),
                  backgroundColor: primaryColor,
                ),
              );
              setState(() {
                _isLoading = false;
              });
            }
          }
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
        child: ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              try {
                GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signOut();
                GoogleSignInAccount? googleUser = await googleSignIn.signIn();

                if (googleUser == null) {
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                OAuthCredential credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );

                UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                var userRef = FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid);
                var userSnapshot = await userRef.get();

                if (!userSnapshot.exists) {
                  await userRef.set({
                    'Uid': userCredential.user!.uid,
                    'Email': userCredential.user!.email,
                    'Name': userCredential.user!.displayName,
                    'ProfilePic': null,
                  });
                }
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Google sign-in failed. Please try again.'),
                      backgroundColor: primaryColor,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
    icon: Image.asset("assets/google-logo.png", height: screenHeight * 0.03),
    label: Text("Continue with Google",
    style: TextStyle(
    fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
        ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    );
  }

  Widget _buildSignupOption(BuildContext context, double screenWidth) {
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
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordText(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        String email = _emailController.text.trim();
        if (email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter your email first."), backgroundColor: primaryColor),
          );
          return;
        }

        setState(() {
          _isLoading = true;
        });

        // Check if email exists in Firestore
        var userRef = FirebaseFirestore.instance.collection('Users').where('Email', isEqualTo: email);
        var querySnapshot = await userRef.get();

        if (querySnapshot.docs.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Email does not exist in the system."),
                  backgroundColor: primaryColor),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        // Send reset password email
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Password reset email sent!"),
                  backgroundColor: primaryColor),
            );
          }
        } catch (e) {
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                  "Failed to send reset email. Please try again."),
                  backgroundColor: primaryColor),
            );
          }
        }

        setState(() {
          _isLoading = false;
        });
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            "Forgot your password?",
            style: TextStyle(color: textColor, fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: textColor),
          ),
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
            color: LoginScreenState.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isHidden,
              style: TextStyle(color: LoginScreenState.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: LoginScreenState.textColor),
                suffixIcon: InkWell(
                  onTap: _togglePasswordView,
                  child: Icon(
                    _isHidden ? Icons.visibility : Icons.visibility_off,
                    color: LoginScreenState.textColor,
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
