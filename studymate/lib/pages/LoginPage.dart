// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import '../util/TextField.dart';
import 'Forget_Pass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'HomePage.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsernameController = TextEditingController();
  final PasswordController = TextEditingController();
  
  // Add a boolean to manage the "Remember Me" toggle state
  bool isRememberMeChecked = false;

  Future<void> login() async {
    final username = UsernameController.text;
    final password = PasswordController.text;
    
    const url = 'https://select-roughy-useful.ngrok-free.app/api';  // Replace with your actual Flask server URL

    try {
      // Ensure the username and password are not empty
      if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and password cannot be empty')),
      );
      return;
      }
      // Sending login request with username and password as query parameters
      final response = await http.get(
      Uri.parse('$url?Query=login&username=$username&password=$password'),
      );

      
      // Parse the JSON response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Successful login, show welcome message and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
          // navigate to the homepage
          // Inside your login success function
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage(
              name : jsonResponse['name'],
            )),
          );

          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
        } else {
          // Failed login, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            'Error: ${response.statusCode}'
            'An error occurred while processing the request'
            '${response.headers}'
            ,
            )),
        );
      }
    } catch (error) {
      // Handle network or server unreachable errors
      showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Network Error'),
        content: SelectableText('Network error: $error'),
        actions: [
        TextButton(
          onPressed: () {
          Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
        ],
      );
      },
    );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              SizedBox(height: 10),
              Image.asset(
                'lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                height: 200,
                width: 500,
              ),
              // Title
              SizedBox(height: 0),
              Text(
                'Nawart ya Mate',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              // Username
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Textfield(
                  controller: UsernameController,
                  hintText: 'Username',
                ),
              ),
              // Password
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Textfield(
                  controller: PasswordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
              ),
              // Remember Me and Forgot Password
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // "Remember Me" checkbox
                        Checkbox(
                          value: isRememberMeChecked,
                          onChanged: (value) {
                            setState(() {
                              isRememberMeChecked = value!;
                            });
                          },
                        ),
                        Text(
                          'Remember Me',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 60),
                  InkWell(
                    onTap: () {
                      // Navigate to Forgot Password page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPass(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 190, 61, 61),
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              // Login Button
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: TextButton(
                      onPressed: () {
                        // Login button action
                        login();
                        
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Sign up
              SizedBox(height: 40),
              Text(
                "Don't have any accounts?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              // Sign up button
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/RegisterPage');
                      },
                      child: Text(
                        'Etfadal Ma3anaa',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 15,
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
