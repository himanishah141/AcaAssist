import 'package:aca_assist/secrets.dart';
import 'package:aca_assist/study_schedule_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AcademicDetailsScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const AcademicDetailsScreen({super.key});

  @override
  AcademicDetailsScreenState createState() => AcademicDetailsScreenState();
}

class AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _weeklyStudyTimeController = TextEditingController();

  // Add this variable to control the loading state
  bool _isLoading = false;  // Track loading state

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _editingSubjectId; // Track which subject is being edited

  // Validate Subject Name
  String? _validateSubjectName(String subjectName) {
    String trimmedName = subjectName.replaceAll(RegExp(r"\s+"), ""); // Remove spaces

    // Check if the name is empty
    if (trimmedName.isEmpty) {
      return 'Subject name cannot be empty.';
    }

    // Check if the name exceeds 25 characters
    if (trimmedName.length > 25) {
      return 'Subject name should not exceed 25 characters.';
    }

    // Check if the name starts with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmedName)) {
      return 'Subject name must start with a letter.';
    }

    // Check if the name only contains valid characters (letters, numbers, spaces, +, -, and #)
    if (!RegExp(r'^[a-zA-Z0-9\s+\-#]+$').hasMatch(trimmedName)) {
      return 'Subject name can only contain letters, numbers, spaces, +, -, and #.';
    }

    return null;
  }


  // Validate Weekly Study Time
  String? _validateWeeklyStudyTime(String weeklyStudyTime) {
    if (weeklyStudyTime.isEmpty) {
      return 'Weekly study time cannot be empty.';
    }
    try {
      int hours = int.parse(weeklyStudyTime);
      if (hours < 1 || hours > 15) {
        return 'Weekly study time should be between 1 and 15 hours.';
      }
    } catch (e) {
      return 'Weekly study time should be a valid number.';
    }
    return null;
  }

  // Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AcademicDetailsScreen.primaryColor,
      ),
    );
  }

  // Handle Add action
  void _addSubject() async {
    final subjectName = _subjectNameController.text;
    final weeklyStudyTime = _weeklyStudyTimeController.text;

    // Validate subject name and weekly study time
    String? subjectNameError = _validateSubjectName(subjectName);
    String? weeklyStudyTimeError = _validateWeeklyStudyTime(weeklyStudyTime);

    if (subjectNameError != null) {
      _showSnackBar(subjectNameError);
      return;
    }
    if (weeklyStudyTimeError != null) {
      _showSnackBar(weeklyStudyTimeError);
      return;
    }

    // Check if the number of subjects exceeds 7 before adding
    try {
      // Get the current user's ID
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Check if the subject name already exists in the database
        QuerySnapshot existingSubjectsSnapshot = await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('StudySchedule')
            .where('SubjectName', isEqualTo: subjectName)
            .get();

        if (existingSubjectsSnapshot.docs.isNotEmpty) {
          // If the subject already exists, show an error SnackBar
          _showSnackBar("Subject name already exists.");
          return; // Don't proceed if the subject already exists
        }

        // Check if the user already has 7 subjects
        QuerySnapshot subjectSnapshot = await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('StudySchedule')
            .get();

        if (subjectSnapshot.docs.length >= 7) {
          _showSnackBar("You can only add up to 7 subjects.");
          return; // Prevent adding more than 7 subjects
        }

        // Create a unique ID for the subject
        String subjectId = _firestore.collection('Users').doc(currentUser.uid).collection('StudySchedule').doc().id;

        // Add the subject to Firestore under the current user's StudySchedule sub-collection
        await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('StudySchedule')
            .doc(subjectId)
            .set({
          'SubjectName': subjectName,
          'WeeklyStudyTime': int.parse(weeklyStudyTime),
          'SubjectId': subjectId,
        });

        // Show success SnackBar after adding the subject
        _showSnackBar("Subject added successfully!");

        // Clear input fields after adding, even for the 7th subject
        _subjectNameController.clear();
        _weeklyStudyTimeController.clear();
      } else {
        _showSnackBar("User is not logged in.");
      }
    } catch (e) {
      _showSnackBar("Error adding subject: $e");
    }
  }

  // Edit Subject Function
  void _editSubject(String subjectId, String subjectName, int weeklyStudyTime) {
    // Show confirmation dialog before editing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AcademicDetailsScreen.backgroundColor,
          title: Text(
            'Edit Subject',
            style: TextStyle(color: AcademicDetailsScreen.textColor),
          ),
          content: Text(
            'Are you sure you want to edit this subject?',
            style: TextStyle(color: AcademicDetailsScreen.textColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AcademicDetailsScreen.textColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: AcademicDetailsScreen.textColor),
              ),
              onPressed: () {
                setState(() {
                  _editingSubjectId = subjectId;
                  _subjectNameController.text = subjectName;
                  _weeklyStudyTimeController.text = weeklyStudyTime.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Update Subject Function
  Future<void> _updateSubject() async {
    final subjectName = _subjectNameController.text;
    final weeklyStudyTime = _weeklyStudyTimeController.text;

    // Validate subject name and weekly study time
    String? subjectNameError = _validateSubjectName(subjectName);
    String? weeklyStudyTimeError = _validateWeeklyStudyTime(weeklyStudyTime);

    if (subjectNameError != null) {
      _showSnackBar(subjectNameError);
      return;
    }
    if (weeklyStudyTimeError != null) {
      _showSnackBar(weeklyStudyTimeError);
      return;
    }

    try {
      // Get the current user's ID
      User? currentUser = _auth.currentUser;

      if (currentUser != null && _editingSubjectId != null) {
        // Update the subject in Firestore
        await _firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('StudySchedule')
            .doc(_editingSubjectId)
            .update({
          'SubjectName': subjectName,
          'WeeklyStudyTime': int.parse(weeklyStudyTime),
        });

        // Show success SnackBar after updating the subject
        _showSnackBar("Subject updated successfully!");

        // Clear input fields after updating
        _subjectNameController.clear();
        _weeklyStudyTimeController.clear();

        // Reset editing state
        setState(() {
          _editingSubjectId = null;
        });
      } else {
        _showSnackBar("User is not logged in or subject is not selected.");
      }
    } catch (e) {
      _showSnackBar("Error updating subject: $e");
    }
  }

  // Delete Subject Function
  Future<void> _deleteSubject(String subjectId) async {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AcademicDetailsScreen.backgroundColor,
          title: Text(
            'Delete Subject',
            style: TextStyle(color: AcademicDetailsScreen.textColor),
          ),
          content: Text(
            'Are you sure you want to delete this subject?',
            style: TextStyle(color: AcademicDetailsScreen.textColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AcademicDetailsScreen.textColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: AcademicDetailsScreen.textColor),
              ),
              onPressed: () async {
                // Dismiss the dialog immediately
                Navigator.of(context).pop();
                try {
                  // Get the current user's ID
                  User? currentUser = _auth.currentUser;

                  if (currentUser != null) {
                    // Delete the subject from Firestore
                    await _firestore
                        .collection('Users')
                        .doc(currentUser.uid)
                        .collection('StudySchedule')
                        .doc(subjectId)
                        .delete();

                    // Show success SnackBar after deleting the subject
                    _showSnackBar("Subject deleted successfully!");
                  } else {
                    _showSnackBar("User is not logged in.");
                  }
                } catch (e) {
                  _showSnackBar("Error deleting subject: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Fetch subjects from Firestore
  Future<List<Map<String, dynamic>>> _fetchSubjectsFromFirestore(String userUid) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('StudySchedule')
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    var subjects = snapshot.docs.map((doc) {
      return {
        'SubjectId': doc.id,
        'SubjectName': doc['SubjectName'],
        'WeeklyStudyTime': doc['WeeklyStudyTime'],
      };
    }).toList();

    return subjects;
  }

// Generate timetable using Gemini 2.0 API (via google_generative_ai package)
  Future<Map<String, List<Map<String, dynamic>>>> _generateTimetableWithGemini(List<Map<String, dynamic>> subjects) async {
    // Prepare the prompt for the Gemini API
    String prompt = "Generate a weekly study timetable based on the following subjects and their weekly study times. Please provide only the timetable, in the following format:\n";
    prompt += "Day: [SubjectName1: X hours, SubjectName2: Y hours, ...]\n";
    prompt += "For example:\n";
    prompt += "Monday: [Math: 2 hours, Science: 1 hour]\n";

    for (var subject in subjects) {
      String subjectName = subject['SubjectName'];
      int weeklyStudyTime = subject['WeeklyStudyTime'];
      prompt += "$subjectName: $weeklyStudyTime hours per week.\n";
    }

    // Initialize the GenerativeModel with your API key and configuration
    final model = GenerativeModel(
      model: 'gemini-2.0-flash', // Use the appropriate model
      apiKey: Secrets.aiApiKey, // Your API key from secrets.dart
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 500, // Adjust token limit based on response size
        responseMimeType: 'text/plain', // Expecting a text-based response
      ),
    );

    // Start the chat session
    final chat = model.startChat();

    // Send the prompt as a message
    final content = Content.text(prompt);
    final response = await chat.sendMessage(content);

    // Safely handle null response.text and trim it
    String timetableText = (response.text ?? '').trim();

    // Parse the timetable text into a day-by-day structure
    return _parseTimetable(timetableText);
  }

// Helper function to parse the timetable text into a day-by-day structure
  Map<String, List<Map<String, dynamic>>> _parseTimetable(String timetableText) {
    Map<String, List<Map<String, dynamic>>> timetableMap = {};

    // Split the timetable into lines, representing each day
    List<String> lines = timetableText.split('\n').map((line) => line.trim()).toList();

    // Loop through each line to extract the day and subjects
    for (var line in lines) {
      if (line.isNotEmpty && line.contains(':')) {
        // Extract the day and the subjects
        int colonIndex = line.indexOf(':');
        String dayName = line.substring(0, colonIndex).trim();
        String subjectsText = line.substring(colonIndex + 1).trim();

        // Split the subjects into individual subjects
        List<String> subjectsList = subjectsText
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((subject) => subject.trim())
            .toList();

        // Convert subjects into a list of maps for that day
        List<Map<String, dynamic>> subjects = [];
        for (var subject in subjectsList) {
          var parts = subject.split(':');
          if (parts.length == 2) {
            String subjectName = parts[0].trim();
            int hours = int.tryParse(parts[1].trim().split(' ')[0]) ?? 0;

            if(hours > 0){
            subjects.add({
              'SubjectName': subjectName,
              'Hours': hours,
            });
            }
          }
        }

        // Add the subjects list to the timetableMap under the day
        timetableMap[dayName] = subjects;
      }
    }

    return timetableMap;
  }

// Store the generated timetable in Firestore, one document per day
  Future<void> _storeTimetableInFirestore(String userUid, Map<String, List<Map<String, dynamic>>> timetable) async {
    try {
      for (var day in timetable.keys) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userUid)
            .collection('GeneratedTimetable')
            .doc(day)  // Use the day name as the document ID
            .set({
          'Day': day,
          'Subjects': timetable[day], // Store the subjects array for that day
        });
      }
    } catch (e) {
      throw Exception('Failed to store timetable in Firestore: $e');
    }
  }

// Main function to fetch subjects, generate timetable using Gemini 2.0, and store the timetable
  Future<void> generateAndStoreTimetable(BuildContext context) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Fetch subjects from Firestore
      var subjects = await _fetchSubjectsFromFirestore(userUid);

      if (subjects.isEmpty) {
        // Show snack bar if no subjects are found
        _showSnackBar("No subjects found to generate a timetable.");
        return;
      }

      // Generate timetable using Gemini 2.0
      Map<String, List<Map<String, dynamic>>> timetable = await _generateTimetableWithGemini(subjects);

      // Store the structured timetable in Firestore (one document per day)
      await _storeTimetableInFirestore(userUid, timetable);

      // Show success message
      _showSnackBar("Timetable generated successfully!");
    } catch (e) {
      // Handle errors and show snack bar
      _showSnackBar("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04; // Responsive font size

    return Scaffold(
      backgroundColor: AcademicDetailsScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: AcademicDetailsScreen.backgroundColor,
        iconTheme: IconThemeData(color: AcademicDetailsScreen.textColor),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            "Academic Details",
            style: TextStyle(
              color: AcademicDetailsScreen.textColor,
              fontSize: fontSize * 1.5, // Title font size adjusted
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
                  // Logo at the top
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
                  // Form fields
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      children: [
                        _buildLabel("Subject Name", fontSize),
                        _buildInputField(
                          _subjectNameController,
                          hintText: "Enter subject name",
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        _buildLabel("Weekly Study Time (hours)", fontSize),
                        _buildInputField(
                          _weeklyStudyTimeController,
                          hintText: "Enter weekly study time",
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Add or Update button
                        ElevatedButton(
                          onPressed: _editingSubjectId == null ? _addSubject : _updateSubject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AcademicDetailsScreen.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                          ),
                          child: Text(
                            _editingSubjectId == null ? "Add" : "Update",
                            style: TextStyle(color: AcademicDetailsScreen.textColor, fontSize: fontSize * 1.1),
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
                                color: AcademicDetailsScreen.primaryColor, // Card background color
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
                                                  .collection('StudySchedule')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Center(child: CircularProgressIndicator(color: AcademicDetailsScreen.textColor));
                                                }

                                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                  return Center(child: Text("No subjects added yet.", style: TextStyle(color: AcademicDetailsScreen.textColor, fontSize: fontSize)));
                                                }

                                                var subjects = snapshot.data!.docs.map((doc) {
                                                  return {
                                                    'SubjectName': doc['SubjectName'],
                                                    'WeeklyStudyTime': doc['WeeklyStudyTime'],
                                                    'SubjectId': doc.id,
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
                                                              'Subject Name',
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: fontSize * 1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Center(
                                                            child: Text(
                                                              'Weekly Study Time',
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: fontSize * 1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Center(
                                                            child: Text(
                                                              'Edit',
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: fontSize * 1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Center(
                                                            child: Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: fontSize * 1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      rows: subjects
                                                          .map((subject) => DataRow(cells: [
                                                        DataCell(
                                                          Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              subject['SubjectName'],
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontSize: fontSize * 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              subject['WeeklyStudyTime'].toString(),
                                                              style: TextStyle(
                                                                color: AcademicDetailsScreen.textColor,
                                                                fontSize: fontSize * 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: IconButton(
                                                              icon: Icon(Icons.edit, color: AcademicDetailsScreen.textColor),
                                                              onPressed: () {
                                                                _editSubject(subject['SubjectId'], subject['SubjectName'], subject['WeeklyStudyTime']);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: IconButton(
                                                              icon: Icon(Icons.delete, color: AcademicDetailsScreen.textColor),
                                                              onPressed: () {
                                                                _deleteSubject(subject['SubjectId']);
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

                              Builder(
                                builder: (context) {
                                  return StreamBuilder<QuerySnapshot>(
                                    stream: _firestore
                                        .collection('Users')
                                        .doc(_auth.currentUser?.uid)
                                        .collection('StudySchedule')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return Container(); // Don't show the button if no subjects exist
                                      }

                                      // Fetch subjects data from Firestore
                                      var subjects = snapshot.data!.docs.map((doc) {
                                        return {
                                          'SubjectName': doc['SubjectName'],
                                          'WeeklyStudyTime': doc['WeeklyStudyTime'],
                                          'SubjectId': doc.id,
                                        };
                                      }).toList();

                                      bool showGenerateButton = subjects.length >= 2;

                                      return Visibility(
                                        visible: showGenerateButton, // Button visible only if there are 2 or more subjects
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.02, // Responsive vertical padding
                                            horizontal: screenWidth * 0.05, // Responsive horizontal padding
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState(() {
                                                _isLoading = true; // Start loading when the button is pressed
                                              });

                                              // Proceed to generate and store timetable
                                              try {
                                                await generateAndStoreTimetable(context);

                                                // After successful generation, navigate to StudyScheduleScreen
                                                if (context.mounted) {  // Ensure widget is still mounted
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => StudyScheduleScreen()),
                                                  );
                                                }
                                              } catch (e) {
                                                _showSnackBar("Error generating timetable: $e");
                                              } finally {
                                                setState(() {
                                                  _isLoading = false; // Stop loading after the process
                                                });
                                              }
                                              },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AcademicDetailsScreen.primaryColor, // Set the button background color
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8), // Rounded corners
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.02, // Vertical padding based on screen size
                                                horizontal: screenWidth * 0.1, // Horizontal padding based on screen size
                                              ),
                                            ),
                                            child: Text(
                                              "Generate Schedule", // Static button text
                                              style: TextStyle(
                                                color: AcademicDetailsScreen.textColor, // Text color to match the app's text color
                                                fontSize: fontSize * 1.1, // Adjusted font size
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                      },
                                  );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Add the loader as an overlay when loading
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.5), // Semi-transparent black overlay
                  child: Center(
                    child: CircularProgressIndicator(color: AcademicDetailsScreen.textColor), // Centered loader
                  ),
                ),
              ),
        ])
    );
  }

  Widget _buildLabel(String label, double fontSize) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: AcademicDetailsScreen.textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize * 1.1,  // Adjust font size for responsiveness
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, {
        required String hintText,
      }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double inputHeight = constraints.maxWidth * 0.12;

        return Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: AcademicDetailsScreen.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: AcademicDetailsScreen.textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: AcademicDetailsScreen.textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
