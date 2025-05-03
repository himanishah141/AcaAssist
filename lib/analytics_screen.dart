import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_screen.dart'; // Import ProfileScreen
import 'home_screen.dart'; // Import HomeScreen
import 'settings_screen.dart'; // Import SettingsScreen
import 'mic_screen.dart'; // Import MicScreen
import 'task_management_screen.dart'; // Import TaskManagementScreen
import 'study_schedule_screen.dart'; // Import StudyScheduleScreen

class AnalyticsScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const AnalyticsScreen({super.key});

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedIndex = 3; // Default to analytics
  String? _selectedMonth; // To store the currently selected month
  final bool _isFieldsEditable = true; // Assuming fields are editable initially. Set to false if not editable.
  String? noDataMessage; // This will hold the message to display when no tasks are found

  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // User data variables
  String name = "";
  String initials = "";

  // Chart data variables
  bool isLoading = true;
  int completed = 0;
  int pending = 0;
  int donelate = 0;
  int missing = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchTaskData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['Name'] ?? "Guest";
          initials = _getInitials(name);
        });
      }
    }
  }

  // Function to extract initials from the name
  String _getInitials(String name) {
    return name.trim().isNotEmpty
        ? name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        : "";
  }

  Future<void> _fetchTaskData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final taskCollection = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('TaskManagement');

        final snapshot = await taskCollection.get();

        int completedCount = 0;
        int pendingCount = 0;
        int donelateCount = 0;
        int missingCount = 0;

        int selectedMonthIndex = months.indexOf(_selectedMonth ?? '') + 1;
        if (selectedMonthIndex == 0) return; // If month not found, exit

        int currentYear = DateTime.now().year;

        // Loop through the tasks and categorize them based on the month
        for (var doc in snapshot.docs) {
          String status = doc['Status'];
          String dateString = doc['Date']; // Get the date as a string
          DateTime taskDate = DateTime.parse(dateString); // Convert to DateTime object

          // Check if the task belongs to the selected month
          if (taskDate.month == selectedMonthIndex && taskDate.year == currentYear) {
            if (status == 'Completed') {
              completedCount++;
            } else if (status == 'Pending') {
              pendingCount++;
            } else if (status == 'Done Late') {
              donelateCount++;
            } else if (status == 'Missing') {
              missingCount++;
            }
          }
        }

        setState(() {
          completed = completedCount;
          pending = pendingCount;
          donelate = donelateCount;
          missing = missingCount;
          isLoading = false;

          if (completed + pending + donelate + missing == 0) {
            noDataMessage = 'No tasks available for $_selectedMonth.';
          } else {
            noDataMessage = null;
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    }
  }

  // Calculate dynamic sizes based on the screen size
  double getIconSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.10;
    return iconSize < 50 ? 50 : iconSize;
  }
  double getAppBarHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return screenHeight * 0.08;
  }

  double getFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.07;
  }

  // Update selected index for bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper: Calculate percentage string for a given count
  String _percent(int count, int total) {
    if (total == 0) return "0.0%";
    double percent = (count / total) * 100;
    return "${percent.toStringAsFixed(1)}%";
  }

  // Build legend row for statistics
  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 6, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: AnalyticsScreen.textColor, fontSize: 16)),
          ],
        ),
        Text(value,
            style: const TextStyle(
                color: AnalyticsScreen.textColor, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  List<PieChartSectionData> getSections() {
    int total = completed + pending + donelate + missing;
    if (total == 0) total = 1; // Prevent division by zero

    return [
      PieChartSectionData(
        value: completed.toDouble(),
        title: '${((completed / total) * 100).toStringAsFixed(1)}%',
        color: const Color(0xFF789793),
        radius: 60,
        titleStyle: const TextStyle(color: AnalyticsScreen.textColor, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: pending.toDouble(),
        title: '${((pending / total) * 100).toStringAsFixed(1)}%',
        color: const Color(0xFF736746),
        radius: 60,
        titleStyle: const TextStyle(color: AnalyticsScreen.textColor, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: donelate.toDouble(),
        title: '${((donelate / total) * 100).toStringAsFixed(1)}%',
        color: const Color(0xFF988498),
        radius: 60,
        titleStyle: const TextStyle(color: AnalyticsScreen.textColor, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: missing.toDouble(),
        title: '${((missing / total) * 100).toStringAsFixed(1)}%',
        color: const Color(0xFF4e4549),
        radius: 60,
        titleStyle: const TextStyle(color: AnalyticsScreen.textColor, fontWeight: FontWeight.bold),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = getIconSize(context);
    double appBarHeight = getAppBarHeight(context);
    double fontSize = getFontSize(context);
    double fontSize2 = screenWidth * 0.04; // For responsive font size
    int total = completed + pending + donelate + missing;

    return Scaffold(
      backgroundColor: AnalyticsScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AnalyticsScreen.backgroundColor,
        iconTheme: const IconThemeData(color: AnalyticsScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Study Analytics",
                style: TextStyle(
                  color: AnalyticsScreen.textColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                backgroundColor: AnalyticsScreen.primaryColor,
                radius: iconSize / 2,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AnalyticsScreen.textColor,
                    fontSize: iconSize * 0.4,
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
            // Top image banner
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/logo.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Centered and Underlined Month Analysis with responsive text size
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // Increased padding for more space from the edges
              child: Text(
                "Monthly Analysis",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.07, // Responsive font size based on screen width
                  fontWeight: FontWeight.bold,
                  color: AnalyticsScreen.textColor, // Change this to your preferred color
                  decoration: TextDecoration.underline,
                  decorationColor: AnalyticsScreen.textColor,
                ),
                textAlign: TextAlign.center, // Center the title
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Add some space between text and dropdown

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // Padding for the label
              child: _buildMonthLabel("Select a month", fontSize2),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // Padding for the dropdown
              child: _buildDropdownMonths(),
            ),
            SizedBox(height: screenHeight * 0.02), // Add space after the dropdown for clarity
            // Display a loading indicator while data is being fetched
            isLoading
                ? const Center(child: CircularProgressIndicator(color: AnalyticsScreen.textColor))
                : (completed + pending + donelate + missing == 0)
                ? Center(
              child: Text(
                'No tasks available for $_selectedMonth.',
                style: TextStyle(
                  color: AnalyticsScreen.textColor,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            )
                : Column(
              children: [
                // Chart container
                AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sections: getSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Statistics legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow("Total Tasks", total.toString(), AnalyticsScreen.textColor),
                      const SizedBox(height: 8),
                      _buildStatRow("Completed", "$completed (${_percent(completed, total)})",
                          const Color(0xFF789793)),
                      _buildStatRow("Pending", "$pending (${_percent(pending, total)})",
                          const Color(0xFF736746)),
                      _buildStatRow("Done Late", "$donelate (${_percent(donelate, total)})",
                          const Color(0xFF988498)),
                      _buildStatRow("Missing", "$missing (${_percent(missing, total)})",
                          const Color(0xFF4e4549)),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ],
        ),
      ),
      // Bottom navigation bar with icons
      bottomNavigationBar: BottomAppBar(
        color: AnalyticsScreen.textColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 0 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/home_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Task Management Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TaskManagementScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 1 ? -10 : 0, 0),
                  child: SvgPicture.asset(
                    "assets/tasks_logo.svg",
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Study Schedule Icon
              GestureDetector(
                onTap: () {
                  _onItemTapped(2);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudyScheduleScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 2 ? -10 : 0, 0),
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
                  _onItemTapped(3);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 3 ? -10 : 0, 0),
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
                  _onItemTapped(4);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MicScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 4 ? -10 : 0, 0),
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
                  _onItemTapped(5);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                  Matrix4.translationValues(0, _selectedIndex == 5 ? -10 : 0, 0),
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
  Widget _buildMonthLabel(String label, double fontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize2 = screenWidth * 0.04;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: TaskManagementScreen.textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize2 * 1.1,
        ),
      ),
    );
  }
  Widget _buildDropdownMonths() {
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Get the current month (index 0 for January, 11 for December)
    String currentMonth = months[DateTime.now().month - 1];

    // Set the default selected month to the current month
    _selectedMonth ??= currentMonth;

    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return GestureDetector(
          onTap: () {},
          child: Container(
            height: inputHeight,
            decoration: BoxDecoration(
              color: TaskManagementScreen.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                dropdownColor: TaskManagementScreen.primaryColor,
                value: _selectedMonth,
                hint: Text(
                  'Select a month',
                  style: TextStyle(
                    color: TaskManagementScreen.textColor,
                    fontSize: constraints.maxWidth * 0.04,
                  ),
                ),
                isExpanded: true,
                style: TextStyle(color: TaskManagementScreen.textColor),
                onChanged: _isFieldsEditable
                    ? (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                  // Call the method to fetch task data when the month changes
                  _fetchTaskData();
                }
                    : null,
                items: months
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.04,
                        color: TaskManagementScreen.textColor,
                      ),
                    ),
                  );
                }).toList(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: TaskManagementScreen.textColor,
                ),
                underline: SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}