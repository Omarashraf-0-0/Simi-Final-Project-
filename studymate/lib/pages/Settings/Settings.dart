import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/Settings/UserSettings.dart'; // Ensure this import is correct and the file exists
import 'package:studymate/pages/Settings/PersonalSettings.dart';
import 'package:studymate/pages/Settings/Universitysettings.dart'; // Ensure this import is correct and the file exists
import 'package:studymate/pages/Settings/RCoursesSettings.dart'; // Ensure this import is correct and the file exists

// Define the CoursesSettings class if it doesn't exist


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Center(child: Text('Settings')),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          // backgroundColor: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text(
                        'Select ',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          //color: Color.fromARGB(255, 0, 0, 0)
                        ),
                      ),
                      Text(
                        'Option!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: Color(0xFF1BC0C4)
                        ),
                      ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('lib/assets/img/SLogin.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 50, // Set a fixed height for the button
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(22, 93, 150, 1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => UserSettings()));
                        },
                        child: Center(
                          child: Text(
                            'User Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 65, // Make the radius the same as the first CircleAvatar
                    backgroundImage: AssetImage('lib/assets/img/SPersonal.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 50, // Set a fixed height for the button
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(22, 93, 150, 1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => PersonalSettings()));
                        },
                        child: Center(
                          child: Text(
                            'Personal Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 65, // Make the radius the same as the first CircleAvatar
                    backgroundImage: AssetImage('lib/assets/img/SUniversity.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 50, // Set a fixed height for the button
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(22, 93, 150, 1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Universitysettings()));
                        },
                        child: Center(
                          child: Text(
                            'University Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Row(
              //   children: [
              //     CircleAvatar(
              //       radius: 65, // Make the radius the same as the first CircleAvatar
              //       backgroundImage: AssetImage('lib/assets/img/SCourse.png'),
              //       backgroundColor: Colors.transparent,
              //     ),
              //     SizedBox(width: 25),
              //     Expanded(
              //       child: Container(
              //         height: 50, // Set a fixed height for the button
              //         decoration: BoxDecoration(
              //           color: const Color.fromRGBO(22, 93, 150, 1),
              //           borderRadius: BorderRadius.circular(60),
              //         ),
              //         child: TextButton(
              //           onPressed: () {
              //             Navigator.push(context,
              //                 MaterialPageRoute(builder: (context) => Rcoursessettings()));
              //           },
              //           child: Center(
              //             child: Text(
              //               'Courses Settings',
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 20,
              //                 fontWeight: FontWeight.bold,
              //                 fontFamily: GoogleFonts.leagueSpartan().fontFamily,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}