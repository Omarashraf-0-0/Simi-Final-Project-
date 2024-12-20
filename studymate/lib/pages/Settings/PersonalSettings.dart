import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/Settings/Settings.dart';
import 'package:studymate/pages/Settings/UserSettings.dart';
import 'package:hive/hive.dart';
import '../../Classes/User.dart';
import '../../Pop-ups/SuccesPopUp.dart';
import '../../util/TextField.dart';
import '../Login & Register/Forget_Pass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Pop-ups/PopUps_Success.dart';


class PersonalSettings extends StatefulWidget {
  const PersonalSettings({super.key});

  @override
  _PersonalSettingsState createState() => _PersonalSettingsState();
}

class _PersonalSettingsState extends State<PersonalSettings> {
  final TextEditingController FullNameController = TextEditingController();
  final TextEditingController PhoneNumberController = TextEditingController();
  final TextEditingController DateOfBirthController = TextEditingController();
  final TextEditingController AddressController = TextEditingController();

  final bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;



  Future<void> UpdateData() async {
    const url = 'https://alyibrahim.pythonanywhere.com/login';
    final Map<String, dynamic> requestBody = {
      'Query': 'login',
      'username': 'username',
      'password': 'password',
    };

    // Send the POST request with the JSON body
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    Hive.box('userBox').put('phone_number', PhoneNumberController.text);
    Hive.box('userBox').put('address', AddressController.text);
    Hive.box('userBox').put('fullName', FullNameController.text);
    Hive.box('userBox').put('birthDate', DateOfBirthController.text);
    print(response.body);
    showSuccessPopup(context, 'Done successfully', 'Data update successfully');

  }



  @override
  Widget build(BuildContext context) {
    FullNameController.text=Hive.box('userBox').get('fullName');
    PhoneNumberController.text=Hive.box('userBox').get('phone_number');
    DateOfBirthController.text=Hive.box('userBox').get('birthDate');
    AddressController.text=Hive.box('userBox').get('address');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Center(child: Text('Personal Settings')),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: TextField(
                  controller: FullNameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: TextField(
                  controller: PhoneNumberController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                        width: 375,
                        child: TextField(
                            controller: DateOfBirthController,
                            decoration: InputDecoration(
                              hintText: 'Date of Birth',
                              hintStyle: TextStyle(
                                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.datetime,
                            )),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: TextField(
                  controller: AddressController,
                  decoration: InputDecoration(
                    hintText: 'Address',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: Icon(Icons.home),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 40),
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