import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package
import 'login_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'change_password_screen.dart'; // Import ChangePasswordScreen
import 'about_us_screen.dart'; // Import AboutUsScreen
import 'contact_us_screen.dart'; // Import ContactUsScreen

class SettingsScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 5; // Default to settings page
  String name = ""; // Variable to store the user's name
  String initials = ""; // Variable to store the user's initials
  bool isNotificationsEnabled = false; // Toggle to track notification setting
  bool _isLoading = false; // Flag to show/hide loading indicator

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['Name'] ?? "Guest"; // Set the user's name (or "Guest" if not available)
          initials = _getInitials(name); // Set the initials based on the name
        });
      }
    }
  }

  // Function to extract initials from the name
  String _getInitials(String name) {
    return name.trim().isNotEmpty
        ? name.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join()
        : "";
  }

  // Navigate to Change Password screen
  void _goToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordScreen()), // Navigate to ChangePasswordScreen
    );
  }

  // Navigate to About Us screen
  void _goToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutUsScreen()), // Navigate to AboutUsScreen
    );
  }

  // Navigate to Contact Us screen
  void _goToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactUsScreen()), // Navigate to ContactUsScreen
    );
  }

  // Function to toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      isNotificationsEnabled = value;
    });
  }

  // Function to show alert before deleting the account
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: SettingsScreen.backgroundColor, // Set background color
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: SettingsScreen.textColor, // Set title text color
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(
              color: SettingsScreen.textColor, // Set content text color
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: SettingsScreen.textColor, // Set button text color
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                setState(() {
                  _isLoading = true; // Show loading spinner on the page
                });
                await _deleteAccount();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: SettingsScreen.textColor, // Set button text color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the account
  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).delete();
        await user.delete(); // Delete the current user's account
        await FirebaseAuth.instance.signOut(); // Sign out the user after account deletion
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide the loader once deletion is complete
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Account successfully deleted.'),
            backgroundColor: SettingsScreen.primaryColor,
          ));
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
                (route) => false, // Removes all previous routes
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide the loader on error
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error deleting account.'),
            backgroundColor: SettingsScreen.primaryColor));
      }
    }
  }

  // Dynamically adjust icon size based on screen width
  double getIconSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.10; // 10% of the screen width for icons
    return iconSize < 50 ? 50 : iconSize; // Ensure the minimum icon size
  }

  // Dynamically adjust AppBar height based on screen size
  double getAppBarHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.08; // AppBar height will be 8% of the screen height
  }

  // Dynamically adjust font size based on screen width
  double getFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.07; // Font size will be 7% of the screen width
  }

  // Update selected icon when clicked
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen width and height
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Set icon size
    double iconSize = getIconSize(context);
    // Set AppBar height (same as BottomAppBar height)
    double appBarHeight = getAppBarHeight(context);
    // Set font size for title
    double fontSize = getFontSize(context);

    return Scaffold(
      backgroundColor: SettingsScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: SettingsScreen.backgroundColor,
        iconTheme: IconThemeData(color: SettingsScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: TextStyle(
                  color: SettingsScreen.textColor,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Profile Picture in AppBar (using initials)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                backgroundColor: SettingsScreen.primaryColor,
                radius: iconSize / 2, // Set size based on icon size
                child: Text(
                  initials,
                  style: TextStyle(
                    color: SettingsScreen.textColor,
                    fontSize: iconSize * 0.4, // Adjust font size based on icon size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main body content
          SingleChildScrollView(
            child: Column(
              children: [
                // Removed the box from Settings page as requested
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        leading: Icon(Icons.lock, color: SettingsScreen.textColor, size: getIconSize(context) * 0.7),
                        title: Text("Change Password", style: TextStyle(color: SettingsScreen.textColor, fontSize: getFontSize(context) * 0.7)),
                        onTap: _goToChangePassword, // Navigate to Change Password screen
                      ),
                      // New: Enable/Disable Notifications
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        leading: Icon(Icons.notifications, color: SettingsScreen.textColor, size: getIconSize(context) * 0.7),
                        title: Text("Enable/Disable Notifications", style: TextStyle(color: SettingsScreen.textColor, fontSize: getFontSize(context) * 0.7)),
                        trailing: Switch(
                          value: isNotificationsEnabled,
                          onChanged: _toggleNotifications, // Toggle notifications
                          activeColor: SettingsScreen.textColor,
                          inactiveThumbColor: Colors.white, // Set thumb color to white when disabled
                          inactiveTrackColor: Colors.grey, // Set track color to grey when disabled
                        ),
                      ),
                      // New: Delete Account
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        leading: Icon(Icons.delete, color: SettingsScreen.textColor, size: getIconSize(context) * 0.7),
                        title: Text("Delete Account", style: TextStyle(color: SettingsScreen.textColor, fontSize: getFontSize(context) * 0.7)),
                        onTap: _confirmDeleteAccount, // Show delete confirmation dialog
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        leading: Icon(Icons.info, color: SettingsScreen.textColor, size: getIconSize(context) * 0.7),
                        title: Text("About Us", style: TextStyle(color: SettingsScreen.textColor, fontSize: getFontSize(context) * 0.7)),
                        onTap: _goToAboutUs, // Navigate to About Us screen
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        leading: Icon(Icons.contact_mail, color: SettingsScreen.textColor, size: getIconSize(context) * 0.7),
                        title: Text("Contact Us", style: TextStyle(color: SettingsScreen.textColor, fontSize: getFontSize(context) * 0.7)),
                        onTap: _goToContactUs, // Navigate to Contact Us screen
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Opacity layer while loading
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0.5), // Semi-transparent black overlay
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: SettingsScreen.textColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Icon
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 0 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/home_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Tasks Icon
              GestureDetector(
                onTap: () {
                  // Handle task navigation
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 1 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/tasks_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Goals Icon
              GestureDetector(
                onTap: () {
                  // Handle goals navigation
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 2 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/goals_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Analytics Icon
              GestureDetector(
                onTap: () {
                  // Handle analytics navigation
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 3 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/analytics_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Mic Icon
              GestureDetector(
                onTap: () {
                  // Handle mic navigation
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 4 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/mic_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Settings Icon (already in place)
              GestureDetector(
                onTap: () => _onItemTapped(5),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 5 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/settings_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
