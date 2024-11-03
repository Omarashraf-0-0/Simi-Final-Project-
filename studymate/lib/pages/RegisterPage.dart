// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:studymate/pages/LoginPage.dart';
import '../Classes/User.dart';
import '../util/TextField.dart';
import 'CollageInformatio.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FullNameController = TextEditingController();
  final UsernameController = TextEditingController();
  final PhoneController = TextEditingController();
  final RegistrationNumberController = TextEditingController();
  final User user = User();
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
                    'Personal information',
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
                      controller: FullNameController, 
                      hintText: 'Full name')
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
                          controller: UsernameController, 
                          hintText: 'Username'
                          )
                        ),
                        SizedBox(width: 15),
                  
                      SizedBox(
                        width: 180,
                        child: Textfield(
                          controller: PhoneController, 
                          hintText: 'Phone number'
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
                      controller: RegistrationNumberController, 
                      hintText: 'Registration number')
                      ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      user.fullName = FullNameController.text;
                      user.username = UsernameController.text;
                      user.phoneNumber = PhoneController.text;
                      user.registrationNumber = RegistrationNumberController.text;
                      user.role = 'student';
                      // Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollageInformation(
                              user: user,
                          ),
                        ),
                      );
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
                      'Next',
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
                      // Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
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