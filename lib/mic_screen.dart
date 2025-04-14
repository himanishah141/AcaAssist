    import 'package:aca_assist/about_us_screen.dart';
    import 'package:aca_assist/contact_us_screen.dart';
    import 'package:flutter/material.dart';
    import 'academic_details_screen.dart';
    import 'recommend_resources_screen.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:flutter_svg/flutter_svg.dart';
    import 'profile_screen.dart'; // Import ProfileScreen
    import 'home_screen.dart'; // Import HomeScreen
    import 'settings_screen.dart'; // Import SettingsScreen
    import 'task_management_screen.dart'; // Import TaskManagementScreen
    import 'analytics_screen.dart'; // Import AnalyticsScreen
    import 'study_schedule_screen.dart'; // Import StudyScheduleScreen
    import 'package:speech_to_text/speech_to_text.dart' as stt;

    class MicScreen extends StatefulWidget {
      static const Color backgroundColor = Color(0xFF5C6B7D);
      static const Color primaryColor = Color(0xFF8196B0);
      static const Color textColor = Color(0xFFD6E4F0);

      const MicScreen({super.key});

      @override
      MicScreenState createState() => MicScreenState();
    }

    class MicScreenState extends State<MicScreen> {
      int _selectedIndex = 4; // Default to mic screen
      String name = "";
      String initials = "";
      String micStatusText = "Tap and hold the mic, then speak into your device";
      late stt.SpeechToText _speech;
      bool _isListening = false;
      String _recognizedText = '';

      @override
      void initState() {
        super.initState();
        _speech = stt.SpeechToText();
        _fetchUserData();
      }

      void _startListening() async {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == "done" || status == "notListening") {
              setState(() => _isListening = false);
            }
          },
        );

        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              setState(() {
                _recognizedText = val.recognizedWords;
                micStatusText = val.recognizedWords;
              });

              if (val.finalResult) {
                _handleCommands();  // Process commands when speech ends
              }
            },
          );
        } else {
          setState(() => _isListening = false);
          micStatusText = "Speech recognition unavailable. Please check microphone permissions.";
        }
      }

      void _stopListening() async {
        if (_isListening) {
          await _speech.stop();
          setState(() {
            _isListening = false;
            micStatusText = "Tap and hold the mic, then speak into your device";
          });
        }
      }

      void _handleCommands() {
        if (_recognizedText.isNotEmpty) {
          if (_recognizedText.contains("home") || _recognizedText.contains("today") || _recognizedText.contains("today's")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (_recognizedText.contains("task") || _recognizedText.contains("tasks") || _recognizedText.contains("task management")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
            );
          } else if (_recognizedText.contains("schedule") || _recognizedText.contains("timetable")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudyScheduleScreen()),
            );
          } else if (_recognizedText.contains("academic") || _recognizedText.contains("add subject") || _recognizedText.contains("add subjects") || _recognizedText.contains("delete subject") || _recognizedText.contains("delete subjects") || _recognizedText.contains("edit subject") || _recognizedText.contains("edit subjects")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AcademicDetailsScreen()),
            );
          } else if (_recognizedText.contains("resources") || _recognizedText.contains("resource") || _recognizedText.contains("recommend")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RecommendResourcesScreen()),
            );
          } else if (_recognizedText.contains("analytics") || _recognizedText.contains("analysis")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
          } else if (_recognizedText.contains("profile") || _recognizedText.contains("logout")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (_recognizedText.contains("settings") || _recognizedText.contains("password") || _recognizedText.contains("delete")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          } else if (_recognizedText.contains("about")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
          } else if (_recognizedText.contains("contact")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          } else {
            setState(() {
              micStatusText = "Sorry, I didn't understand the command.";
            });
          }
        }
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

      String _getInitials(String name) {
        return name.trim().isNotEmpty
            ? name.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join()
            : "";
      }

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

      void _onItemTapped(int index) {
        setState(() {
          _selectedIndex = index;
        });
      }

      @override
      Widget build(BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double iconSize = getIconSize(context);
        double appBarHeight = getAppBarHeight(context);
        double fontSize = getFontSize(context);

        return Scaffold(
          backgroundColor: MicScreen.backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: MicScreen.backgroundColor,
            iconTheme: IconThemeData(color: MicScreen.textColor),
            elevation: 0,
            toolbarHeight: appBarHeight,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Voice Assistant",
                    style: TextStyle(
                      color: MicScreen.textColor,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
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
                    backgroundColor: MicScreen.primaryColor,
                    radius: iconSize / 2,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: MicScreen.textColor,
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


            SizedBox(height: 13),
                  //alignment: Alignment.center, // Center the SVG
                    GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        micStatusText = "Listening...";
                      });
                      _startListening();  // Start listening when the mic is tapped
                    },
                    onTapUp: (_) {
                      setState(() {
                        micStatusText = "Tap and hold the mic, then speak into your device";
                      });
                      _stopListening();  // Stop listening when the tap is canceled
                    },
                    onTapCancel: () {
                      setState(() {
                        micStatusText = "Tap and hold the mic, then speak into your device";
                      });
                      _stopListening();  // Stop listening when the tap ends
                    },
                    child: SvgPicture.asset(
                      "assets/mic.svg",
                      height: screenHeight * 0.18,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        MicScreen.textColor.withAlpha((0.7 * 255).toInt()),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                SizedBox(height: 16), // Space between image and text
                Text(
                  micStatusText,
                  style: TextStyle(
                    color: MicScreen.textColor,
                    fontSize: fontSize * 0.7,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: MicScreen.textColor,
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
