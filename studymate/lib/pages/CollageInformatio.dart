// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, prefer_const_declarations, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:studymate/Classes/User.dart';
import 'package:studymate/pages/LoginPage.dart';
import '../util/TextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
String? selectedUniversity;
String? selectedCollage;
String? selectedMajor;

class CollageInformation extends StatefulWidget {
  User? user;
  CollageInformation({
    super.key,
    this.user,
  });
  @override
  State<CollageInformation> createState() => _CollageInformationState();
}

class _CollageInformationState extends State<CollageInformation> {
  // State variables for dropdown selections
  String? selectedUniversity;
  String? selectedCollage;
  String? selectedMajor;

  final RegistrationNumberController = TextEditingController();

  // Dropdown options
  final items = ['AAST', 'AUC', 'GUC', 'MIU', 'MSA'];
  final collage = ['Engineering', 'Business', 'Computing', 'Media', 'Pharmacy'];
  final major = ['Computer Science', 'Business Administration', 'Media', 'Pharmacy', 'Engineering'];

  @override
  void initState() {
    super.initState();
    // Initialize dropdowns with user values if available
    selectedUniversity = widget.user?.university;
    selectedCollage = widget.user?.collage;
    selectedMajor = widget.user?.major;
  }

  Future<void> registerCollegeInfo() async {
    final String url = 'https://alyibrahim.pythonanywhere.com/register';

    final Map<String, dynamic> data = {
      'Query': 'college_registration',
      'username': widget.user?.username,
      'password': widget.user?.password,
      'fullName': widget.user?.fullName,
      'role': widget.user?.role,
      'email': widget.user?.email,
      'phoneNumber': widget.user?.phoneNumber,
      'address': widget.user?.address,
      'gender': widget.user?.gender,
      'college': selectedCollage,
      'university': selectedUniversity,
      'major': selectedMajor,
      'term_level': 1,
      'pfp': widget.user?.pfp,
      'xp': 0,
      'level': 1,
      'title': 'newbie',
      'registrationNumber': RegistrationNumberController.text,
      'birthDate': widget.user?.birthDate,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register college info: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Etfadal Ma3anaa',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'College Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),
                    // University Dropdown
                    SizedBox(
                      width: 375,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('University'),
                        value: selectedUniversity,
                        items: items.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedUniversity = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 25),
                    // Collage and Major Dropdowns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('Collage'),
                            value: selectedCollage,
                            items: collage.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedCollage = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        SizedBox(
                          width: 180,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('Major'),
                            value: selectedMajor,
                            items: major.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedMajor = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    // Registration Number
                    SizedBox(
                      width: 350,
                      child: Textfield(
                        controller: RegistrationNumberController,
                        hintText: 'Registration number',
                        suffixIcon: Icon(FontAwesome.id_card),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        if (selectedUniversity == null ||
                            selectedCollage == null ||
                            selectedMajor == null ||
                            RegistrationNumberController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fill all fields')),
                          );
                        }
                       else if (!RegExp(r'^\d{9}$').hasMatch(RegistrationNumberController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration number must be exactly 9 digits')),
                          );
                        } 
                        else
                        {
                            registerCollegeInfo();  
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                        backgroundColor: Color(0xff165D96),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
