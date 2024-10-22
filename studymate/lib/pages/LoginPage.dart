import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      body:SafeArea(
        child: Center(
          child:Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
          //image 
          Image.asset('lib/assets/img/El Batal Study Mate Light Mode.png',
          height: 200,
          width: 200,
          ),
            ],
          )
        
        ),

      )
      
    );
  }
}