// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

void main() {
  runApp(const Failedpopup());
}

class Failedpopup extends StatelessWidget {
  const Failedpopup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularWidget(),
          ),
        ),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  const CircularWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .scaffoldBackgroundColor, // Set the background color here
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          // Circular shape with checkmark
          Container(
            alignment: Alignment.topCenter,
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Color(0xffFD8744), // Background color of the circle
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.error_outline, // Checkmark icon
                size: 250,
                color: Colors.white,
                /*shadows: [
                BoxShadow(color: Colors.black,offset: Offset(15, 12),spreadRadius: 20,blurRadius: 40)
              ],*/
              ),
            ),
          ),
          SizedBox(height: 40), // Space between the circle and text
          // Text below the circle
          Text(
            "Oooops!!",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 25,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20), // Space between the circle and text
          // Text below the circle
          Text(
            "More text",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30), // Space between text and button
          // Elevated Button for "Done"
          ElevatedButton(
            onPressed: () {
              // Close the app or perform another action
              print("Error button pressed"); // Placeholder action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffFD8744), // Button color
              minimumSize: Size(320, 60),
              // padding: EdgeInsets.symmetric(horizontal: 130, vertical: 15),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
