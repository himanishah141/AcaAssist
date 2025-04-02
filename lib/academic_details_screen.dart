import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _editingSubjectId; // Track which subject is being edited

  // Validate Subject Name
  String? _validateSubjectName(String subjectName) {
    String trimmedName = subjectName.replaceAll(RegExp(r"\s+"), ""); // Remove spaces
    if (trimmedName.isEmpty) {
      return 'Subject name cannot be empty.';
    }
    if (trimmedName.length > 15) {
      return 'Subject name should not exceed 15 characters.';
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
      body: SingleChildScrollView(
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
                          // The Card containing the DataTable
                          // Card containing the DataTable
                          Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
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
                                              return Center(child: CircularProgressIndicator());
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
                                                      Center(
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

                          // The Generate Schedule button below the card
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
                                        onPressed: () {
                                          // Implement your generate schedule functionality here
                                         // _generateSchedule();
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
