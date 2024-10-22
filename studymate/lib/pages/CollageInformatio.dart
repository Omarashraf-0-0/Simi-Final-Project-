// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import '../util/TextField.dart';
import 'RegisterPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

class CollageInformation extends StatefulWidget {
  final String fullName;
  final String username;
  final String phoneNumber;
  final String registrationNumber;
  const CollageInformation({
    super.key,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.registrationNumber,
    });
  @override
  State<CollageInformation> createState() => _CollageInformationState();
}

class _CollageInformationState extends State<CollageInformation> {
  final UniversityController = TextEditingController();
  final CollageController = TextEditingController();
  final MajorController = TextEditingController();
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();
  
 Future<void> registerCollegeInfo() async {
    // Prepare the URL of your Flask API
    final String url = 'http://127.0.0.1:5000/api'; // Change if necessary

    // Create a JSON object for the request
    final Map<String, dynamic> data = {
      'Query': 'college_registration',
      'university': UniversityController.text,
      'college': CollageController.text,
      'major': MajorController.text,
      'email': EmailController.text,
      'password': PasswordController.text,
      'fullName': widget.fullName,
      'username': widget.username,
    };

    // Send a POST request to the Flask API
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Successful registration
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        // Optionally, navigate to another page or clear the fields
      } else {
        // Handle error response
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (error) {
      // Handle any errors that occur during the request
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // add a back button arrow to the left with a circular outlayer
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                    'Collage information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,  
                    )
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    
                    width: 385,
                    child: Textfield(
                      controller: UniversityController, 
                      hintText: 'University')
                      ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [
                      SizedBox(
                        width: 180,
                        child: Textfield(
                          controller: CollageController, 
                          hintText: 'Collage'
                          )
                        ),
                        SizedBox(width: 15),
                  
                      SizedBox(
                        width: 180,
                        child: Textfield(
                          controller: MajorController, 
                          hintText: 'Major'
                          )
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: 385,
                    child: Textfield(
                      controller: EmailController, 
                      hintText: 'Email')
                      ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: 385,
                    child: Textfield(
                      controller: PasswordController, 
                      hintText: 'Password',
                      obscureText: true,
                      )
                      ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => RegisterPage()),
                      // );
                      registerCollegeInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                      // add color #165D96 to the background
                      backgroundColor: Color(0xff165D96),
                      // rounded corners remove
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
              Column(
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,  
                    )
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 5),
                      // add color #165D96 to the background
                      backgroundColor: Color(0xff165D96),
                      // rounded corners remove
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
} 