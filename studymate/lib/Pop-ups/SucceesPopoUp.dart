// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

void main() {
  runApp(const DonePopUp());
}

class DonePopUp extends StatelessWidget {
  const DonePopUp({super.key});

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
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 60),
        // Circular shape with checkmark
        Container(
          alignment: Alignment.topCenter,
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Color(0xff3BBD5E), // Background color of the circle
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded, // Checkmark icon
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
          "Operation Successful",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20), // Space between the circle and text
        // Text below the circle
        Text(
          "More text",
          style: TextStyle(
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30), // Space between text and button
        // Elevated Button for "Done"
        ElevatedButton(
          onPressed: () {
            // Close the app or perform another action
            print("Done button pressed"); // Placeholder action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff3BBD5E), // Button color
            minimumSize: Size(320, 60),
            // padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
          ),
          child: Text(
            "Done",
            style: TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}