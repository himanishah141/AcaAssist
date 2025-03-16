import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aca_assist/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  bool isLoading = false; // Track the loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc['Name'] ?? "";
          email = user.email ?? "";
        });
      }
    }
  }

  // Logout function with loading state
  Future<void> _logout() async {
    setState(() {
      isLoading = true; // Show the loading indicator when logout is initiated
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logged out successfully!'),
          backgroundColor: ProfileScreen.primaryColor,
        ));
      }
      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen())); // Navigate to LoginScreen directly
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error logging out.'),
          backgroundColor: ProfileScreen.primaryColor,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Hide the loading indicator once the process is complete
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Extract the initials from the user's name
    String initials = name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join() : "";

    return Scaffold(
      backgroundColor: ProfileScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: ProfileScreen.backgroundColor,
        iconTheme: IconThemeData(color: ProfileScreen.textColor),
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: ProfileScreen.textColor,
            fontSize: screenWidth * 0.06, // Responsive text size
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of screen width
              vertical: screenHeight * 0.02, // 2% of screen height
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Center(
                  child: Text(
                    "Welcome, ${name.split(" ")[0]}!",
                    style: TextStyle(
                      color: ProfileScreen.textColor,
                      fontSize: screenWidth * 0.07, // Responsive text size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing

                // Profile Picture Section (Show Initials instead of Image)
                Center(
                  child: isLoading
                      ? CircularProgressIndicator() // Show loader while updating
                      : Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ProfileScreen.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: screenWidth * 0.12, // Responsive font size for initials
                          color: ProfileScreen.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Responsive spacing

                // Name Field (Read-Only)
                _buildLabel("Name", screenWidth),
                _buildTextField(name, screenWidth, screenHeight),

                SizedBox(height: screenHeight * 0.03), // Responsive spacing

                // Email Field (Read-Only)
                _buildLabel("Email", screenWidth),
                _buildTextField(email, screenWidth, screenHeight),

                SizedBox(height: screenHeight * 0.05), // Responsive spacing

                // Logout Button
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _logout, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileScreen.primaryColor, // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1, // 10% of screen width
                        vertical: screenHeight * 0.02, // 2% of screen height
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: ProfileScreen.textColor,
                        fontSize: screenWidth * 0.05, // Responsive text size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Black Overlay and Loading Indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0.5), // Semi-transparent black overlay
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Label Widget
  Widget _buildLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(
        color: ProfileScreen.textColor,
        fontSize: screenWidth * 0.05, // Responsive text size
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField(String value, double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.07, // 7% of screen height
      decoration: BoxDecoration(
        color: ProfileScreen.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // Responsive padding
      child: Text(
        value,
        style: TextStyle(
          color: ProfileScreen.textColor,
          fontSize: screenWidth * 0.045, // Responsive text size
        ),
      ),
    );
  }
}
