import 'package:flutter/material.dart';
import 'package:studymate/pages/AboLayla/AboLaylaCourses.dart'; // Update the import path accordingly


class AboLayla extends StatelessWidget {
  const AboLayla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // Blue color for the AppBar
        title: Text(
          'Abo Layla',
          style: TextStyle(fontFamily: 'League Spartan', fontSize: 25, fontWeight: FontWeight.bold,
          color: Colors.white
          ),
        ),
        centerTitle: true, // Center the title in the AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('lib/assets/img/AboLayla.jpg'),
              SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                    color: Colors.black, // Default text color
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Hello, I am \n '),
                    TextSpan(
                      text: 'Abo Layla',
                      style: TextStyle(color: const Color(0xFF165D96)), // Blue color for "Abo Layla"
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Start chatting with me now. You can ask me anything related to your course.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'League Spartan'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboLaylaCourses()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF165D96), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 90, vertical: 20), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button radius
                  ),
                ),
                child: Text(
                  'Start Chat',
                  style: TextStyle(
                    fontSize: 30, // Button text size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                    fontFamily: 'League Spartan',
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