// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../util/TextField.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final EmailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      body:Padding(
        padding: const EdgeInsets.symmetric(vertical : 30.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0,bottom: 50.0),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  //image 
                  SizedBox(height: 10),
                           
                   // title
                   SizedBox(height: 0),
                   Text('Forget Your Password?',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                   ),
                  
                   // bt7sal
                    SizedBox(height: 5),
                   Text('3ady bt7sal, 3andy el solution',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                   ),
                   // solution
                   // bt7sal
                    SizedBox(height: 20,),
                   Padding(
                     padding: const EdgeInsets.all(20),
                     child: Text('Enter your email address below  to reset your password ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                     ),
            
                   ),
                  //Username
                  SizedBox(height: 20
                  ),
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        width: 375,
                        child: Textfield(
                          controller: EmailController,
                          hintText: 'Email',
                          suffixIcon: Icon(Icons.email),
                        ),
                      ),
                      
                    ),
                  // Send Button
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      decoration: BoxDecoration(
                      color: const Color.fromRGBO(22, 93, 150, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          onPressed: (){},
                          child: Text('Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ),  
                        
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 25),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //     color: Colors.grey[200],
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 20),
                  //       child: TextField(
                  //       decoration: InputDecoration(
                  //         border: InputBorder.none,
                  //         hintText: 'Username',
                  //         icon: Icon(Icons.person),
                  
                  //       ),
                  //       ),
                  //     ),
                  //   ),
                  // ), 
                         //Sign up
                          SizedBox(height: 150),
                   Text("Cant solve the problem ? ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                   ),
                          // Contact with us button
                          SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      decoration: BoxDecoration(
                      color: const Color.fromRGBO(22, 93, 150, 1),
                      borderRadius: BorderRadius.circular(80),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          onPressed: (){},
                          child: Text('Contact with us',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          ),
                        ),
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
      )
      
    );
  }
}