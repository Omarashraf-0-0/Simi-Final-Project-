// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import '../util/TextField.dart';
import 'RegisterPage.dart';

class CollageInformation extends StatefulWidget {
  const CollageInformation({super.key});
  @override
  State<CollageInformation> createState() => _CollageInformationState();
}

class _CollageInformationState extends State<CollageInformation> {
  final UniversityController = TextEditingController();
  final CollageController = TextEditingController();
  final MajorController = TextEditingController();
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();

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