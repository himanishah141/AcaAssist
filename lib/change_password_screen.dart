import 'package:firebase_auth/firebase_auth.dart';
import 'package:aca_assist/login_screen.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const ChangePasswordScreen({super.key});
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordChangeEnabled = false;
  bool _isCurrentPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  // Reauthentication function
  Future<void> _reauthenticateUser() async {
    final currentPassword = _currentPasswordController.text;
    final user = FirebaseAuth.instance.currentUser;

    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter current password.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User is not logged in.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      if (mounted) {
        setState(() {
          _isPasswordChangeEnabled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password is correct, you can change your password now.'),
            backgroundColor: ChangePasswordScreen.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect current password or requires recent authentication.'),
            backgroundColor: ChangePasswordScreen.primaryColor,
          ),
        );
      }
    }
  }

  // Change password function
  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final currentPassword = _currentPasswordController.text;

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a new password.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters long.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one uppercase letter.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one lowercase letter.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one digit.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one special character.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (newPassword == currentPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password cannot be the same as the current password.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your new password.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: ChangePasswordScreen.primaryColor,
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
        // Change the password after reauthentication
        await user.updatePassword(newPassword);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully! Please log in again.'),
              backgroundColor: ChangePasswordScreen.primaryColor,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all routes from the stack
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
            content: Text('Failed to change password: ${e.toString()}'),
            backgroundColor: ChangePasswordScreen.primaryColor,
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
      backgroundColor: ChangePasswordScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: ChangePasswordScreen.backgroundColor,
        iconTheme: IconThemeData(color: ChangePasswordScreen.textColor),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            "Change Password",
            style: TextStyle(
              color: ChangePasswordScreen.textColor,
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
                        _buildLabel("Current Password", fontSize),
                        _buildInputField(
                          _currentPasswordController,
                          _isCurrentPasswordHidden,
                              () => setState(() {
                            _isCurrentPasswordHidden = !_isCurrentPasswordHidden;
                          }),
                          obscureText: _isCurrentPasswordHidden,
                          hintText: "Enter current password",
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: _reauthenticateUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ChangePasswordScreen.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                          ),
                          child: Text("Verify Current Password", style: TextStyle(color: ChangePasswordScreen.textColor, fontSize: fontSize * 1.1)),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        if (_isPasswordChangeEnabled) ...[
                          _buildLabel("New Password", fontSize),
                          _buildInputField(
                            _newPasswordController,
                            _isNewPasswordHidden,
                                () => setState(() {
                              _isNewPasswordHidden = !_isNewPasswordHidden;
                            }),
                            obscureText: _isNewPasswordHidden,
                            hintText: "Enter new password",
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          _buildLabel("Confirm New Password", fontSize),
                          _buildInputField(
                            _confirmPasswordController,
                            _isConfirmPasswordHidden,
                                () => setState(() {
                              _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                            }),
                            obscureText: _isConfirmPasswordHidden,
                            hintText: "Confirm new password",
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ChangePasswordScreen.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                            ),
                            child: Text("Change Password", style: TextStyle(color: ChangePasswordScreen.textColor, fontSize: fontSize * 1.1)),
                          ),
                        ],
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
                  color: ChangePasswordScreen.primaryColor,
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
          color: ChangePasswordScreen.textColor,
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
            color: ChangePasswordScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(color: ChangePasswordScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: ChangePasswordScreen.textColor),
                suffixIcon: GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: ChangePasswordScreen.textColor,
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
