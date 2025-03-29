import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  static const Color backgroundColor = Color(0xFF5C6B7D);
  static const Color primaryColor = Color(0xFF8196B0);
  static const Color textColor = Color(0xFFD6E4F0);

  const ContactUsScreen({super.key});

  // Function to open email app
  void _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch email app.';
    }
  }

  // Function to open phone dialer
  void _launchPhone(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not dial the phone number.';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ContactUsScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: ContactUsScreen.backgroundColor,
        iconTheme: IconThemeData(color: ContactUsScreen.textColor),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Contact Us",
            style: TextStyle(
              color: ContactUsScreen.textColor,
              fontSize: screenWidth * 0.06,  // Reduced font size for the title
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.03),
          child: Column(
            children: [
              // Add logo image at the top
              Container(
                width: double.infinity,
                height: screenHeight * 0.25,  // Reduced height for the logo image
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/logo.png"), // Your logo
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),  // Adjusted padding for better responsiveness
                child: Column(
                  children: [
                    // Card for Email and Phone (Contact 1)
                    Card(
                      color: ContactUsScreen.textColor,
                      elevation: 3,  // Reduced elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),  // Reduced border radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),  // Reduced padding inside cards
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchEmail('devraval2004@gmail.com'),
                                  child: Text(
                                    "devraval2004@gmail.com", // Your contact email
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),  // Reduced space between email and phone
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchPhone('+919904325939'),
                                  child: Text(
                                    "+91 99043 25939", // Your Indian phone number
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),  // Reduced space between cards

                    // Card for Email and Phone (Contact 2)
                    Card(
                      color: ContactUsScreen.textColor,
                      elevation: 3,  // Reduced elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),  // Reduced border radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),  // Reduced padding inside cards
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchEmail('shahhimani703@gmail.com'),
                                  child: Text(
                                    "shahhimani703@gmail.com", // Your contact email
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),  // Reduced space between email and phone
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchPhone('+917984373949'),
                                  child: Text(
                                    "+91 79843 73949", // Your Indian phone number
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),  // Reduced space between cards

                    // Card for Email and Phone (Contact 3)
                    Card(
                      color: ContactUsScreen.textColor,
                      elevation: 3,  // Reduced elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),  // Reduced border radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),  // Reduced padding inside cards
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchEmail('mokshahshah84@gmail.com'),
                                  child: Text(
                                    "mokshahshah84@gmail.com", // Your contact email
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),  // Reduced space between email and phone
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: ContactUsScreen.backgroundColor,
                                  size: screenWidth * 0.065,  // Reduced icon size
                                ),
                                SizedBox(width: screenWidth * 0.04),  // Reduced space between icon and text
                                GestureDetector(
                                  onTap: () => _launchPhone('+919409517590'),
                                  child: Text(
                                    "+91 94095 17590", // Your Indian phone number
                                    style: TextStyle(
                                      color: ContactUsScreen.backgroundColor,
                                      fontSize: screenWidth * 0.045,  // Reduced text size
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),  // Reduced space between cards

                    // Optional - Add a Message or Info Card
                    Card(
                      color: ContactUsScreen.textColor,
                      elevation: 3,  // Reduced elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),  // Reduced border radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),  // Reduced padding inside cards
                        child: Column(
                          children: [
                            Text(
                              "For any inquiries, feel free to reach out to us!",
                              style: TextStyle(
                                color: ContactUsScreen.backgroundColor,
                                fontSize: screenWidth * 0.05,  // Reduced text size
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Divider(
                              color: ContactUsScreen.backgroundColor,
                              thickness: 1.2,
                              indent: screenWidth * 0.02,
                              endIndent: screenWidth * 0.02,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "We are always happy to assist you with any questions or feedback.",
                              style: TextStyle(
                                color: ContactUsScreen.backgroundColor,
                                fontSize: screenWidth * 0.04,  // Reduced text size
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03), // Spacing after last card
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
