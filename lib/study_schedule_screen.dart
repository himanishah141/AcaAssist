import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart'; // Import ProfileScreen
import 'home_screen.dart'; // Import HomeScreen
import 'settings_screen.dart'; // Import SettingsScreen
import 'mic_screen.dart'; // Import MicScreen
import 'analytics_screen.dart'; // Import AnalyticsScreen
import 'task_management_screen.dart'; // Import TaskManagementScreen
import 'academic_details_screen.dart'; // Import AcademicDetailsScreen

class StudyScheduleScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const StudyScheduleScreen({super.key});

  @override
  StudyScheduleScreenState createState() => StudyScheduleScreenState();
}

class StudyScheduleScreenState extends State<StudyScheduleScreen> {
  int _selectedIndex = 2; // Default to study schedule
  String name = ""; // Variable to store the user's name
  String initials = ""; // Variable to store the user's initials

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

  // Update selected index when tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update _selectedIndex based on the tapped item
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen width and height
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = getIconSize(context); // Set icon size
    double appBarHeight = getAppBarHeight(context); // Set AppBar height
    double fontSize = getFontSize(context); // Set font size for title

    return Scaffold(
      backgroundColor: StudyScheduleScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: StudyScheduleScreen.backgroundColor,
        iconTheme: IconThemeData(color: StudyScheduleScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Study Schedule", // Custom Title for Study Schedule
                style: TextStyle(
                  color: StudyScheduleScreen.textColor,
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
                backgroundColor: StudyScheduleScreen.primaryColor,
                radius: iconSize / 2, // Set size based on icon size
                child: Text(
                  initials,
                  style: TextStyle(
                    color: StudyScheduleScreen.textColor,
                    fontSize: iconSize * 0.4, // Adjust font size based on icon size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            // Add the "Edit Subject Details" button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to AcademicDetailsScreen when pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AcademicDetailsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AcademicDetailsScreen.primaryColor, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1), // Responsive padding
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // This will prevent stretching and make the button size dynamic
                  children: [
                    Text(
                      "Edit Subject Details",
                      style: TextStyle(
                        color: AcademicDetailsScreen.textColor, // Button text color
                        fontSize: fontSize * 0.6, // Responsive font size
                      ),
                    ),
                    SizedBox(width: 8), // Space between text and icon
                    Icon(
                      Icons.arrow_forward, // Right arrow icon
                      color: AcademicDetailsScreen.textColor, // Icon color
                      size: fontSize * 0.6, // Icon size, same as text size
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: StudyScheduleScreen.textColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(0); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to Home screen
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
                  _onItemTapped(1); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskManagementScreen()), // Navigate to TaskManagementScreen
                  );
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
                  _onItemTapped(2); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StudyScheduleScreen()), // Navigate to StudyScheduleScreen
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 2 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/schedule_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Analytics Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(3); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalyticsScreen()), // Navigate to AnalyticsScreen
                  );
                }, // Use _onItemTapped here
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
                  _onItemTapped(4); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MicScreen()), // Navigate to MicScreen
                  );
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
              // Settings Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(5); // Manually set index
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()), // Navigate to SettingsScreen
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 5 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/settings_logo.svg", // Your settings icon
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
