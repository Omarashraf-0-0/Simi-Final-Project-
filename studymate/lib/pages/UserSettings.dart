import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/Settings.dart';
import 'package:studymate/pages/UserSettings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Classes/User.dart';
import '../Pop-ups/SuccesPopUp.dart';
import '../util/TextField.dart';
import 'Forget_Pass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Pop-ups/PopUps_Success.dart';
import '../Pop-ups/PopUps_Failed.dart';
import '../Pop-ups/PopUps_Warning.dart';


class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  final TextEditingController EmailController = TextEditingController();
  final TextEditingController UsernameController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final TextEditingController ConfirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  Future<void> UpdateData() async {
    const url = 'https://alyibrahim.pythonanywhere.com/update_user';

    // Validate input fields
    if (UsernameController.text.isEmpty || EmailController.text.isEmpty) {
      showFailedPopup(context, 'Error', 'Username and email cannot be empty.');
      return;
    }

    if (PasswordController.text != ConfirmPasswordController.text) {
      showFailedPopup(context, 'Error', 'Passwords do not match.');
      return;
    }

    // Update Hive with the new data
    final userBox = Hive.box('userBox');
    userBox.put('fullName', UsernameController.text);
    userBox.put('email', EmailController.text);
    if (PasswordController.text.isNotEmpty) {
      userBox.put('password', PasswordController.text);
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'Query': 'update_user', // Specify the query type
      'fullname': UsernameController.text,
      'email': EmailController.text,
      'password': PasswordController.text.isNotEmpty ? PasswordController.text : null,
    };

    // try {
    //   // Send the POST request
    //   final response = await http.post(
    //     Uri.parse(url),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(requestBody), // Convert the map to JSON format
    //   );
    //
    //   if (response.statusCode == 200) {
    //     print(">>>>>>>>>>>> Done <<<<<<<<<<<<<<<<<");
    //     final jsonResponse = jsonDecode(response.body);
    //     if (jsonResponse['success'] == true) {
    //
    //
    //       // Show success popup
    //       showSuccessPopup(context, 'Done successfully', 'Data updated successfully');
    //     } else {
    //       // Server returned an error
    //       showFailedPopup(context, 'Error', jsonResponse['message'] ?? 'Unknown error occurred.');
    //     }
    //   } else {
    //     // HTTP request failed
    //     showFailedPopup(context, 'Error', 'Failed to update data. Please try again later.');
    //   }
    // } catch (e) {
    //   // Handle exceptions (e.g., network failure)
    //   showFailedPopup(context, 'Error', 'An error occurred: $e');
    // }
  }




  @override
  Widget build(BuildContext context) {
    print("The Email : ${Hive.box('userBox').get('id')}");
    EmailController.text=Hive.box('userBox').get('email', defaultValue: 'Default from Hive');
    UsernameController.text=Hive.box('userBox').get('fullName', defaultValue: 'Default from Hive');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Center(child: Text('User Settings')),
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
                        'Profile Picture',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: Color.fromARGB(255, 0, 0, 0)
                        ),
                      ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('lib/assets/img/DProfile.png'),
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
                          /* El Profile Ya Salaaaah*/
                        },
                        child: Center(
                          child: Text(
                            'Upload Image',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: Color.fromARGB(255, 0, 0, 0)
                        ),
                      ),
                ],
              ),
              SizedBox(height: 55),
              SizedBox(
                        width: 375,
                        child: TextField(
                            controller: UsernameController,
                            decoration: InputDecoration(
                              hintText: 'User',
                              suffixIcon: Icon(Icons.person),
                            ),
                            keyboardType: TextInputType.text,
                            )
                  ),
                  SizedBox(height: 55),
              SizedBox(
                        width: 375,
                        child: TextField(
                            controller: EmailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              suffixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            )
                  ),
            SizedBox(height: 55),
            SizedBox(
              width: 375,
              child: TextField(
                controller: PasswordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_isPasswordVisible,
              ),
            ),
            SizedBox(height: 55),
            SizedBox(
              width: 375,
              child: TextField(
                controller: ConfirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_isConfirmPasswordVisible,
              ),
            ),
            SizedBox(height: 25),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      UpdateData();
                      // Save changes action
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Save Changes',
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
          ),
        ),
      );
  }
}


