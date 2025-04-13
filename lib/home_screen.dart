import 'package:aca_assist/settings_screen.dart';
import 'package:aca_assist/study_schedule_screen.dart';
import 'package:aca_assist/mic_screen.dart';
import 'package:aca_assist/analytics_screen.dart';
import 'package:aca_assist/task_management_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package
import 'package:aca_assist/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default to home page
  String name = ""; // Variable to store the user's name
  String initials = ""; // Variable to store the user's initials
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;  // Ensure the Home icon is selected by default
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
    double fontSize2 = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: HomeScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HomeScreen.backgroundColor,
        iconTheme: IconThemeData(color: HomeScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
          // Replace profilepic_logo.svg with initials
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
                backgroundColor: HomeScreen.primaryColor,
                radius: iconSize / 2, // Set size based on icon size
                child: Text(
                  initials,
                  style: TextStyle(
                    color: HomeScreen.textColor,
                    fontSize: iconSize * 0.4, // Adjust font size based on icon size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(  // Wrapping the entire body in SingleChildScrollView
        child: Column(
          children: [
            // Logo Image
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
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: HomeScreen.primaryColor, // Card background color
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: screenHeight * 0.4, // Adjust the height as needed
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Today's Tasks Header Row
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
                                  SizedBox(width: 8),
                                  SvgPicture.asset(
                                    "assets/todo_logo.svg",
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1,
                                    colorFilter: ColorFilter.mode(
                                      HomeScreen.textColor,
                                      BlendMode.srcIn,
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),

                            // Divider to separate header and tasks
                            Divider(
                              color: HomeScreen.textColor,
                              thickness: 1,
                              indent: screenWidth * 0.01,
                              endIndent: screenWidth * 0.01,
                            ),

                            // Horizontal scroll view for content if needed
                            Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Horizontal scroll
                                child: FutureBuilder<List<String>>(
                                  future: Future.wait([
                                    fetchTodayStudyPlanMessage(),
                                    fetchTodayTasksMessage(),
                                  ]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator(color: HomeScreen.textColor));
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text("Something went wrong", style: TextStyle(color: HomeScreen.textColor)));
                                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                      // Fetching study plan and tasks
                                      String studyPlan = snapshot.data![0].trim();
                                      String tasks = snapshot.data![1].trim();

                                      // Splitting tasks by newlines to create a list of tasks
                                      List<String> taskList = tasks.isNotEmpty ? tasks.split('\n') : [];

                                      // Splitting study plan by newlines to create a list of study plan items
                                      List<String> studyPlanList = studyPlan.isNotEmpty ? studyPlan.split('\n') : [];

                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,  // Align everything to start (left-aligned)
                                          children: [
                                            // Display "Today's Study Plan" if it's not empty
                                            if (studyPlanList.isNotEmpty) ...[
                                              Text(
                                                "📅 Today's Study Plan:",  // Static header for "Today's Study Plan"
                                                style: TextStyle(
                                                  color: HomeScreen.textColor,
                                                  fontSize: fontSize2 * 1.3, // Dynamically set font size here
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.start,  // Align text to the start
                                              ),
                                              SizedBox(height: 8),
                                              // Display each study plan line with bullet points
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,  // Ensure study plan is left-aligned
                                                  children: studyPlanList.map((studyPlanItem) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 8.0),
                                                      child: Text(
                                                        "• $studyPlanItem",  // Add the bullet point before each study plan item
                                                        style: TextStyle(
                                                          color: HomeScreen.textColor,
                                                          fontSize: fontSize2 * 1.2,  // Default font size for study plan content
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        textAlign: TextAlign.start,  // Align text to the start
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],

                                            // Now we add the "📝 Today's Tasks" heading with dynamic font size
                                            if (taskList.isNotEmpty) ...[
                                              Text(
                                                "📝 Today's Tasks:",  // Static header for "Today's Tasks"
                                                style: TextStyle(
                                                  color: HomeScreen.textColor,
                                                  fontSize: fontSize2 * 1.3, // Dynamically set font size here for tasks header
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.start,  // Align text to the start
                                              ),
                                              SizedBox(height: 8),
                                              // Display each task line with bullet points
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,  // Ensure tasks are left-aligned
                                                  children: taskList.map((task) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 8.0),
                                                      child: Text(
                                                        "• $task",  // Add the bullet point before each task
                                                        style: TextStyle(
                                                          color: HomeScreen.textColor,
                                                          fontSize: fontSize2 * 1.2,  // Default font size for task content
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        textAlign: TextAlign.start,  // Align text to the start
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Text(
                                          "Nothing to show", // If there's no data or it's empty, show this message
                                          style: TextStyle(
                                            color: HomeScreen.textColor,
                                            fontSize: fontSize2,  // Default font size for content
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.start,  // Align text to the start
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: HomeScreen.textColor,
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

  Future<String> fetchTodayStudyPlanMessage() async {
    List<String> messages = [];
    User? user = _auth.currentUser;

    if (user != null) {
      String currentDay = _getCurrentDay();

      // Fetch timetable
      DocumentSnapshot timetableDoc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('GeneratedTimetable')
          .doc(currentDay)
          .get();

      if (timetableDoc.exists && timetableDoc['Subjects'] != null && timetableDoc['Subjects'].isNotEmpty) {
        List subjects = timetableDoc['Subjects'];
        for (var subject in subjects) {
          int hours = subject['Hours'];
          String hourLabel = hours == 1 ? 'hour' : 'hours';
          String subjectName = (subject['SubjectName'] ?? '').trim();
          messages.add("$subjectName for $hours $hourLabel.");
        }
      }
    }

    return messages.join('\n'); // Join messages with newline
  }

  Future<String> fetchTodayTasksMessage() async {
    List<String> messages = [];
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot taskSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('TaskManagement')
          .where('Date', isEqualTo: DateTime.now().toIso8601String().substring(0, 10))
          .get();

      if (taskSnapshot.docs.isNotEmpty) {
        for (var doc in taskSnapshot.docs) {
          var task = doc.data() as Map<String, dynamic>;
          String status = task['Status'];
          String taskType = task['TaskType'];
          String subject = (task['SubjectName'] ?? '').trim();

          String taskMessage = '';
          if (taskType == "Assignment") {
            switch (status) {
              case "Pending":
                taskMessage = "You have an Assignment in $subject due today. Get it done!";
                break;
              case "Missing":
                taskMessage = "Your Assignment in $subject is still pending and now marked as Missing.";
                break;
              case "Completed":
                taskMessage = "Great job! Your Assignment in $subject is completed.";
                break;
              case "Done Late":
                taskMessage = "Your Assignment in $subject was submitted late.";
                break;
            }
          } else if (taskType == "Exam") {
            switch (status) {
              case "Pending":
                taskMessage = "You have an Exam in $subject today. All the best!";
                break;
              case "Completed":
                taskMessage = "Your Exam in $subject is completed.";
                break;
            }
          }

          if (taskMessage.isNotEmpty) {
            messages.add(taskMessage);
          }
        }
      }
    }

    return messages.join('\n'); // Join messages with newline
  }

  // Function to get the current day of the week
  String _getCurrentDay() {
    DateTime now = DateTime.now();
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[now.weekday % 7]; // Get current day as string
  }
}
