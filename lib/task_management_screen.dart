import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
/*import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';*/
import 'profile_screen.dart'; // Import ProfileScreen
import 'home_screen.dart'; // Import HomeScreen
import 'settings_screen.dart'; // Import SettingsScreen
import 'mic_screen.dart'; // Import MicScreen
import 'analytics_screen.dart'; // Import AnalyticsScreen
import 'study_schedule_screen.dart'; // Import StudyScheduleScreen

class TaskManagementScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const TaskManagementScreen({super.key});

  @override
  TaskManagementScreenState createState() => TaskManagementScreenState();
}

class TaskManagementScreenState extends State<TaskManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSubject;
  String? _selectedStatus; // Declare the selected status variable
  String? _selectedTask; // Declare the selected task variable
  int _selectedIndex = 1; // Default to task management
  String name = ""; // Variable to store the user's name
  String initials = ""; // Variable to store the user's initials
  String? selectedSubject;
  String? selectedTask;
  String? selectedStatus;
  DateTime? selectedDate;
  DateTime? selectedDueDate;

  String? _editingTaskId;
  bool _isEditing = false;  // Tracks if editing mode is active

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

  // Function to manually format the date in yyyy-MM-dd format
  String formatDate(DateTime? date) {
    if (date != null) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return ''; // Return empty string if no date is selected
  }

  // Function to open date picker
  Future<void> _selectDate(BuildContext context, bool isExam) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExam ? DateTime.now() : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isExam) {
          selectedDate = picked; // Update selected exam date
        } else {
          selectedDueDate = picked; // Update selected assignment due date
        }
      });
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

  // Update selected index when tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update _selectedIndex based on the tapped item
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TaskManagementScreen.primaryColor,
      ),
    );
  }

 /* GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/calendar', // Google Calendar API scope
    ],
  );

// Google Calendar API client
  calendar.CalendarApi? _calendarApi;

// Google Sign-In status check
  Future<void> _checkGoogleSignInStatus() async {
    bool isSignedIn = await googleSignIn.isSignedIn();

    if (isSignedIn) {
      GoogleSignInAccount? user = googleSignIn.currentUser;
      _showSnackBar("User is already signed in: ${user?.displayName}");

      // Now, proceed to sync tasks with Google Calendar
      _syncTasksWithGoogleCalendar();
    } else {
      // If the user is not signed in, show the sign-in prompt
      _handleSignInWithGoogle();
    }
  }

// Sign-in method
  Future<void> _handleSignInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      await googleSignIn.signIn();
      _showSnackBar("User signed in with Google");

      // Now sync tasks with Google Calendar
      _syncTasksWithGoogleCalendar();
    } catch (error) {
      _showSnackBar("Google sign-in error: $error");
    }
  }

  // Sync tasks with Google Calendar
  Future<void> _syncTasksWithGoogleCalendar() async {
    try {
      GoogleSignInAccount? googleAccount = googleSignIn.currentUser;
      GoogleSignInAuthentication googleAuth = await googleAccount!.authentication;

      // Access Token from Google Sign-In
      String accessToken = googleAuth.accessToken!;

      // Use the access token to create credentials
      final credentials = AccessCredentials(
        AccessToken('Bearer', accessToken, DateTime.now().add(Duration(hours: 1))),
        null,  // No refresh token is required here
        <String>['https://www.googleapis.com/auth/calendar'], // Scopes for Google Calendar API
      );

      // Create an authenticated client using the credentials
      final client = authenticatedClient(http.Client(), credentials);
      _calendarApi = calendar.CalendarApi(client);

      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        var taskDocs = await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('TaskManagement')
            .get();

        for (var doc in taskDocs.docs) {
          var taskData = doc.data();
          DateTime taskDate = DateTime.parse(taskData['Date']);
          calendar.Event event = calendar.Event(
            summary: taskData['SubjectName'],  // Task name (subject name)
            start: calendar.EventDateTime(dateTime: taskDate, timeZone: "UTC"),
            end: calendar.EventDateTime(dateTime: taskDate, timeZone: "UTC"),
          );
          await _calendarApi!.events.insert(event, 'primary');
        }
        _showSnackBar("Tasks synced to Google Calendar.");
      }
    } catch (e) {
      _showSnackBar("Error syncing tasks with Google Calendar: $e");
    }
  }*/

  // Add Tasks
  void _addTask() async {
    final taskType = _selectedTask;  // TaskType from dropdown
    final subjectName = _selectedSubject;  // SubjectName from dropdown
    final date = _selectedTask == 'Exam' ? selectedDate : selectedDueDate;

    // Validate the inputs
    if (taskType == null) {
      _showSnackBar("Please select a task type.");
      return;
    }
    if (subjectName == null) {
      _showSnackBar("Please select a subject.");
      return;
    }
    if (date == null) {
      _showSnackBar("Please select a date.");
      return;
    }

    // Format the date to only store the date part (yyyy-MM-dd)
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // Proceed to add task
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        if (taskType == 'Exam') {
          // Check if there is already an exam for the same subject on the same date
          QuerySnapshot existingTasksSnapshot = await _firestore
              .collection('Users')
              .doc(currentUser.uid)
              .collection('TaskManagement')
              .where('SubjectName', isEqualTo: subjectName)
              .where('TaskType', isEqualTo: 'Exam')
              .where('Date', isEqualTo: formattedDate)
              .get();

          if (existingTasksSnapshot.docs.isNotEmpty) {
            // If an exam is already scheduled for the same subject, show the error
            _showSnackBar("An exam already exists for this subject on this date.");
            return; // Don't proceed if there is already an exam for that subject on the same date
          }
        }

        // If no duplicates for exams, proceed to add the task
        String taskId = _firestore.collection('Users').doc(currentUser.uid).collection('TaskManagement').doc().id;

        // Add the task to Firestore
        await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('TaskManagement')
            .doc(taskId)
            .set({
          'TaskType': taskType,
          'SubjectName': subjectName,
          'Date': formattedDate,  // Store the date in the format yyyy-MM-dd
          'Status': "Pending",
          'TaskId': taskId,
        });

        // Now check if user is signed in and sync with Google Calendar
      //  await _checkGoogleSignInStatus();

        // Show success SnackBar
        _showSnackBar("Task added successfully!");

        // Clear selections after adding task
        setState(() {
          _selectedTask = null;
          _selectedSubject = null;
          _selectedStatus = null;
          selectedDate = null;
        });
      } else {
        _showSnackBar("User is not logged in.");
      }
    } catch (e) {
      _showSnackBar("Error adding task: $e");
    }
  }

  void _editTask(String taskId, String taskType, String subjectName, String status, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TaskManagementScreen.backgroundColor,
          title: Text(
            'Edit Task',
            style: TextStyle(color: TaskManagementScreen.textColor),
          ),
          content: Text(
            'Are you sure you want to edit this task?',
            style: TextStyle(color: TaskManagementScreen.textColor),
          ),
          actions: [
            TextButton(
                child: Text('Cancel', style: TextStyle(color: TaskManagementScreen.textColor)),
                onPressed: () {
                  setState(() {
                    _isEditing = false; // Set to false if cancel is pressed
                  });
                  Navigator.of(context).pop();
                }
            ),
            TextButton(
              child: Text('Confirm', style: TextStyle(color: TaskManagementScreen.textColor)),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _editingTaskId = taskId;
                  _selectedTask = taskType;
                  _selectedSubject = subjectName;
                  _selectedStatus = ['Pending', 'Completed'].contains(status) ? status : null;
                  if (taskType == 'Exam') {
                    selectedDate = DateTime.tryParse(date);  // Use DateTime.parse to handle the date properly
                    selectedDueDate = null;  // Reset Assignment date
                  } else if (taskType == 'Assignment') {
                    selectedDueDate = DateTime.tryParse(date); // Handle Assignment date
                    selectedDate = null; // Reset Exam date
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTask() async {
    final taskType = _selectedTask;  // TaskType from dropdown
    final subjectName = _selectedSubject;  // SubjectName from dropdown
    final date = _selectedTask == 'Exam' ? selectedDate : selectedDueDate;
    final status = _selectedStatus;  // Status from dropdown

    // Validate the inputs
    if (taskType == null) {
      _showSnackBar("Please select a task type.");
      return;
    }
    if (subjectName == null) {
      _showSnackBar("Please select a subject.");
      return;
    }
    if (date == null) {
      _showSnackBar("Please select a date.");
      return;
    }
    if (status == null){
      _showSnackBar("Please select a status.");
      return;
    }

    // Format the date to only store the date part (yyyy-MM-dd)
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null && _editingTaskId != null) {
        // Update the task in Firestore
        await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('TaskManagement')
            .doc(_editingTaskId)
            .update({
          'TaskType': taskType,
          'SubjectName': subjectName,
          'Date': formattedDate,  // Store the formatted date in Firestore
          'Status': status,
        });

        // Now check if user is signed in and sync with Google Calendar
      //  await _checkGoogleSignInStatus();

        // Show success SnackBar after updating the task
        _showSnackBar("Task updated successfully!");

        // Clear selections after updating task
        setState(() {
          _selectedTask = null;
          _selectedSubject = null;
          _selectedStatus = null;
          selectedDate = null;
          _isEditing = false;
        });

        // Reset editing state
        setState(() {
          _editingTaskId = null;
        });
      } else {
        _showSnackBar("User is not logged in or task is not selected.");
      }
    } catch (e) {
      _showSnackBar("Error updating task: $e");
    }
  }


  // Delete Task Function
  Future<void> _deleteTask(String taskId) async {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TaskManagementScreen.backgroundColor,
          title: Text(
            'Delete Task',
            style: TextStyle(color: TaskManagementScreen.textColor),
          ),
          content: Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(color: TaskManagementScreen.textColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: TaskManagementScreen.textColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: TaskManagementScreen.textColor),
              ),
              onPressed: () async {
                // Dismiss the dialog immediately
                Navigator.of(context).pop();
                try {
                  // Get the current user's ID
                  User? currentUser = _auth.currentUser;

                  if (currentUser != null) {
                    // Delete the task from Firestore
                    await _firestore
                        .collection('Users')
                        .doc(currentUser.uid)
                        .collection('TaskManagement') // Replace with your collection name
                        .doc(taskId)
                        .delete();

                    // Now check if user is signed in and sync with Google Calendar
                  //  await _checkGoogleSignInStatus();

                    // Show success SnackBar after deleting the task
                    _showSnackBar("Task deleted successfully!");
                  } else {
                    _showSnackBar("User is not logged in.");
                  }
                } catch (e) {
                  _showSnackBar("Error deleting task: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen width and height
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = getIconSize(context); // Set icon size
    double appBarHeight = getAppBarHeight(context); // Set AppBar height
    double fontSize = getFontSize(context); // Set font size for title
    double fontSize2 = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: TaskManagementScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: TaskManagementScreen.backgroundColor,
        iconTheme: IconThemeData(color: TaskManagementScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Task Management", // Custom Title for Task Management
                style: TextStyle(
                  color: TaskManagementScreen.textColor,
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
                backgroundColor: TaskManagementScreen.primaryColor,
                radius: iconSize / 2, // Set size based on icon size
                child: Text(
                  initials,
                  style: TextStyle(
                    color: TaskManagementScreen.textColor,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                  _buildLabel("Select Task Type", fontSize),
                  _buildDropdownTasks(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildLabel("Select Subject", fontSize),
                  _buildDropdownSubjects(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTaskDateSelector(context),
                  SizedBox(height: screenHeight * 0.03),
                  if (_isEditing) ...[
                    _buildLabel("Select Status", fontSize),
                    _buildDropdownStatus(),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                  // Add or Update button
                  ElevatedButton(
                    onPressed: _editingTaskId == null ? _addTask : _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskManagementScreen.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                    ),
                    child: Text(
                      _editingTaskId == null ? "Add" : "Update",
                      style: TextStyle(color: TaskManagementScreen.textColor, fontSize: fontSize2 * 1.1),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Card containing the table or message
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // Card containing the DataTable
                        Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.01),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: TaskManagementScreen.primaryColor, // Card background color
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: screenHeight * 0.3, // Fixed height for the card (adjust as needed)
                              child: Scrollbar( // Vertical scrollbar for the DataTable content
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('Users')
                                            .doc(_auth.currentUser?.uid)
                                            .collection('TaskManagement')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Center(child: CircularProgressIndicator(color: TaskManagementScreen.textColor));
                                          }

                                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                            return Center(child: Text("No tasks added yet.", style: TextStyle(color: TaskManagementScreen.textColor, fontSize: fontSize2)));
                                          }

                                          var tasks = snapshot.data!.docs.map((doc) {
                                            return {
                                              'TaskType': doc['TaskType'],
                                              'SubjectName': doc['SubjectName'],
                                              'Date': doc['Date'],
                                              'Status': doc['Status'],
                                              'TaskId': doc.id,
                                            };
                                          }).toList();

                                          return Scrollbar( // Horizontal scrollbar
                                            controller: ScrollController(), // Make the horizontal scrollbar always visible
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal, // Horizontal scroll for DataTable
                                              child: DataTable(
                                                columnSpacing: screenWidth * 0.05,
                                                headingRowHeight: screenHeight * 0.07,
                                                dataRowMinHeight: screenHeight * 0.05,
                                                dataRowMaxHeight: screenHeight * 0.08,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Color.fromRGBO(255, 255, 255, 0.3),
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                columns: [
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Task Type',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Subject Name',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Date',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Status',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Center(
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: fontSize2 * 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                rows: tasks
                                                    .map((task) => DataRow(cells: [
                                                  DataCell(
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        task['TaskType'],
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontSize: fontSize2 * 1.1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        task['SubjectName'],
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontSize: fontSize2 * 1.1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        task['Date'].toString(),
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontSize: fontSize2 * 1.1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        task['Status'],
                                                        style: TextStyle(
                                                          color: TaskManagementScreen.textColor,
                                                          fontSize: fontSize2 * 1.1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: IconButton(
                                                        icon: Icon(Icons.edit, color: TaskManagementScreen.textColor),
                                                        onPressed: () {
                                                          _editTask(task['TaskId'], task['TaskType'], task['SubjectName'], task['Status'], task['Date']);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: IconButton(
                                                        icon: Icon(Icons.delete, color: TaskManagementScreen.textColor),
                                                        onPressed: () {
                                                          _deleteTask(task['TaskId']);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ]))
                                                    .toList(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: TaskManagementScreen.textColor,
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
              // Study Schedule Icon
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
  Widget _buildLabel(String label, double fontSize) {
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
  Widget _buildDropdownSubjects() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Users')
          .doc(_auth.currentUser?.uid)
          .collection('StudySchedule')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: TaskManagementScreen.textColor));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No subjects added yet.",
              style: TextStyle(color: TaskManagementScreen.textColor),
            ),
          );
        }

        List<String> subjects = snapshot.data!.docs
            .map((doc) => doc['SubjectName'] as String)
            .toList();

        // Ensure that selectedSubject is in the list of subjects
        if (_selectedSubject != null && !subjects.contains(_selectedSubject)) {
          _selectedSubject = null; // Reset it if the value doesn't exist
        }

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
                    value: _selectedSubject,
                    hint: Text(
                      'Select a subject',
                      style: TextStyle(
                        color: TaskManagementScreen.textColor,
                        fontSize: constraints.maxWidth * 0.04,
                      ),
                    ),
                    isExpanded: true,
                    style: TextStyle(color: TaskManagementScreen.textColor),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                    items: subjects
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
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
      },
    );
  }
  Widget _buildDropdownTasks() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;
        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: TaskManagementScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: _selectedTask,
              hint: Text(
                'Select task type',
                style: TextStyle(
                  color: TaskManagementScreen.textColor,
                  fontSize: constraints.maxWidth * 0.04,
                ),
              ),
              isExpanded: true,
              style: TextStyle(color: TaskManagementScreen.textColor),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTask = newValue; // Update state when selection changes
                });
              },
              items: <String>['Exam', 'Assignment']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                );
              }).toList(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: TaskManagementScreen.textColor,
              ),
              underline: SizedBox.shrink(),
              dropdownColor: TaskManagementScreen.primaryColor,
            ),
          ),
        );
      },
    );
  }
  Widget _buildDropdownStatus() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: TaskManagementScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: ['Pending', 'Completed'].contains(_selectedStatus) ? _selectedStatus : null,
              hint: Text(
                'Select status',
                style: TextStyle(
                  color: TaskManagementScreen.textColor,
                  fontSize: constraints.maxWidth * 0.04,
                ),
              ),
              isExpanded: true,
              style: TextStyle(color: TaskManagementScreen.textColor),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue; // Update state when selection changes
                });
              },
              items: <String>['Pending', 'Completed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                );
              }).toList(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: TaskManagementScreen.textColor,
              ),
              underline: SizedBox.shrink(),
              dropdownColor: TaskManagementScreen.primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskDateSelector(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.04; // Adjust font size dynamically

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show appropriate label based on task type (Exam or Assignment)
            if (_selectedTask == 'Exam')
              _buildLabel("Select Exam Date", fontSize),
            if (_selectedTask == 'Assignment')
              _buildLabel("Select Assignment Due Date", fontSize),

            // Date Picker
            GestureDetector(
              onTap: () {
                if (_selectedTask == 'Exam') {
                  _selectDate(context, true); // Open date picker for Exam
                } else if (_selectedTask == 'Assignment') {
                  _selectDate(context, false); // Open date picker for Assignment
                }
              },
              child: Container(
                height: fontSize * 3.2, // Adjust height based on font size
                decoration: BoxDecoration(
                  color: TaskManagementScreen.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTask == 'Exam'
                            ? (selectedDate != null
                            ? '${selectedDate!.toLocal()}'.split(' ')[0]
                            : 'Select Exam Date')
                            : (_selectedTask == 'Assignment'
                            ? (selectedDueDate != null
                            ? '${selectedDueDate!.toLocal()}'.split(' ')[0]
                            : 'Select Due Date')
                            : 'Select task type first'),
                        style: TextStyle(
                          color: TaskManagementScreen.textColor,
                          fontSize: fontSize, // Dynamically adjust font size here
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: TaskManagementScreen.textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
