import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package

class HomeScreen extends StatefulWidget {
  // Define the background color (same as LoginScreen)
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // To store the selected index of the BottomNavigationBar

  // Dynamically adjust icon size based on screen width (percentage of screen width)
  double getIconSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.15; // 15% of the screen width for icons
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
    return screenWidth * 0.06; // Font size will be 6% of the screen width
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
      backgroundColor: HomeScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: HomeScreen.backgroundColor,
        elevation: 0, // No elevation, normal AppBar appearance
        toolbarHeight: appBarHeight, // Dynamic AppBar height
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Added horizontal padding for the title
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align text to the start (left)
            children: [
              // Title Text
              Text(
                "Home",
                style: TextStyle(
                  color: HomeScreen.textColor,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Profile Icon with independent size and padding to prevent shrinking
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16), // Horizontal padding only
            child: SvgPicture.asset(
              "assets/profilepic_logo.svg", // Replace with your profile icon asset path
              width: iconSize, // Ensure the icon size stays the same
              height: iconSize, // Ensure the icon size stays the same
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Logo Image
          Container(
            width: double.infinity,
            height: screenHeight * 0.3, // Dynamically scaled image size
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // SizedBox with Scrollable Tasks
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03), // Adds 5% padding to the sides
            child: SizedBox(
              width: screenWidth * 0.9, // Box width is less than full screen (90% width)
              height: screenHeight * 0.4, // Constrain the height of the box
              child: Container(
                decoration: BoxDecoration(
                  color: HomeScreen.primaryColor,
                  borderRadius: BorderRadius.circular(16), // Circular borders
                ),
                child: Column(
                  children: [
                    // Header Row for Today's Tasks
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: HomeScreen.primaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Tasks",
                            style: TextStyle(
                              color: HomeScreen.textColor,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8), // Space between the text and the icon
                          SvgPicture.asset(
                            "assets/todo_logo.svg",  // Path to your todo_logo.svg asset
                            width: screenWidth * 0.1,  // Same width as the text size
                            height: screenWidth * 0.1, // Same height as the text size
                            colorFilter: ColorFilter.mode(
                              HomeScreen.textColor, // Set the color to match the text color
                              BlendMode.srcIn,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    // Divider to separate header and tasks
                    Divider(
                      color: HomeScreen.textColor, // Color of the divider
                      thickness: 1, // Thickness of the divider
                      indent: screenWidth * 0.02, // Responsive indent (5% of screen width)
                      endIndent: screenWidth * 0.02, // Responsive end indent (5% of screen width)
                    ),

                    // Scrollable Tasks List
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Tasks List (you can replace this with dynamic task data)
                            for (int i = 1; i <= 10; i++)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Card(
                                  color: HomeScreen.textColor,
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Task $i',
                                      style: TextStyle(
                                        color: HomeScreen.backgroundColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: HomeScreen.textColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0), // No additional vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly spaces the icons
            children: [
              // Home Icon
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _selectedIndex == 0 ? -10 : 0, 0), // Raise selected icon
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
                onTap: () => _onItemTapped(1),
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
                onTap: () => _onItemTapped(2),
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
                onTap: () => _onItemTapped(3),
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
                onTap: () => _onItemTapped(4),
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