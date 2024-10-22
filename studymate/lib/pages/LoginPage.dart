// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'Forget_Pass.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          //image 
          SizedBox(height: 10),
          Image.asset('lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
          height: 200,
          width: 500,
          ),
           // title
           SizedBox(height: 0),
           Text('Nawart ya Mate',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
           ),

          //Username
          SizedBox(height: 40
          ),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  // icon: Icon(Icons.person),
                  
                ),
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
          // Password
            SizedBox(height: 20
          ),
             Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                // backgroundColor: Colors.grey[200],
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  // icon: Icon(Icons.person),
                  
                ),
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
          //         obscureText: true,
          //       decoration: InputDecoration(
          //         border: InputBorder.none,
          //         hintText: 'Password',
          //         icon: Icon(Icons.lock),

          //       ),
          //       ),
          //     ),
          //   ),
          // )
          // ,
            // remember me and forgot password
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Checkbox(value: false, onChanged: (value){}),
                      Text('Remember Me',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 90),
                InkWell(
                onTap: () {
                  // Navigate to Forgot Password page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgetPass(), // Replace with your Forgot Password page widget
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 190, 61, 61),
                    decoration: TextDecoration.underline, // Optional: underline for visual indication
                  ),
                ),
              )
            ],
          ),
          //Login Button
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
                  onPressed: (){},
                  child: Text('Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  ),
                ),
              ),
            ),
          ),
      //Sign up
        SizedBox(height: 40),
           Text("Don't have any accounts ?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                  onPressed: (){
                    Navigator.pushNamed(context, '/RegisterPage');
                  },
                  child: Text('Etfadal Ma3anaa',
                  style: TextStyle(
                    color: Colors.white,
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

      )
      
    );
  }
}