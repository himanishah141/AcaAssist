import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const AboutUsScreen({super.key});

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    // Getting screen width and height
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Set AppBar height (same as BottomAppBar height)
    double appBarHeight = screenHeight * 0.08;

    // Set font size for title
    double fontSize = screenWidth * 0.07;

    return Scaffold(
      backgroundColor: AboutUsScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: AboutUsScreen.backgroundColor,
        iconTheme: IconThemeData(color: AboutUsScreen.textColor),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "About Us",
                style: TextStyle(
                  color: AboutUsScreen.textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.03), // Added bottom padding to the body
          child: Column(
            children: [
              // Add logo image without gradient
              Container(
                width: double.infinity,
                height: screenHeight * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/logo.png"), // Replace with your logo
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    // Add a card for the introduction
                    Card(
                      color: AboutUsScreen.textColor, // Card color set to textColor
                      elevation: 4, // Set elevation to 4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        child: Column(
                          children: [
                            Text(
                              "Welcome to AcaAssist!",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Divider added below the heading
                            Divider(
                              color: AboutUsScreen.backgroundColor,
                              thickness: 1.2,
                              indent: screenWidth * 0.02,
                              endIndent: screenWidth * 0.02,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "At AcaAssist, we believe that students deserve an efficient and smart way to manage their academic and personal tasks. Our app is designed to help students stay organized with AI-powered task management, study scheduling, habit tracking, and resource recommendations.",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.start, // Text is aligned to the start (left)
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Add a card for more details
                    Card(
                      color: AboutUsScreen.textColor, // Card color set to textColor
                      elevation: 4, // Set elevation to 4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        child: Column(
                          children: [
                            Text(
                              "Our Platform Features",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Divider added below the heading
                            Divider(
                              color: AboutUsScreen.backgroundColor,
                              thickness: 1.2,
                              indent: screenWidth * 0.02,
                              endIndent: screenWidth * 0.02,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "Our platform combines advanced technologies like AI, Firebase, and voice assistance to provide personalized support. With features like a smart scheduler, voice assistant, and seamless calendar integration, AcaAssist makes studying more productive and stress-free.",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.start, // Text is aligned to the start (left)
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Add a card for commitment to the user
                    Card(
                      color: AboutUsScreen.textColor, // Card color set to textColor
                      elevation: 4, // Set elevation to 4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        child: Column(
                          children: [
                            Text(
                              "Our Commitment",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Divider added below the heading
                            Divider(
                              color: AboutUsScreen.backgroundColor,
                              thickness: 1.2,
                              indent: screenWidth * 0.02,
                              endIndent: screenWidth * 0.02,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "We are committed to improving student life by offering a digital assistant that adapts to individual needs. Our goal is to make learning smarter, not harder. With continuous updates and enhancements, AcaAssist is here to support students at every step of their academic journey.",
                              style: TextStyle(
                                color: AboutUsScreen.backgroundColor, // Text color set to backgroundColor
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.start, // Text is aligned to the start (left)
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Added extra padding after the last card
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
