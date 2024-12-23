import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/main.dart';
import 'package:studymate/pages/Resuorces/Courses.dart';
class Resources extends StatefulWidget {
  const Resources({super.key});

  @override
  State<Resources> createState() => _ResourcesState();
}
class _ResourcesState extends State<Resources> {
  List<String> courses = [];
  List<String> coursesIndex = [];
  Future<void> takecources() async {
  
    const url = 'https://alyibrahim.pythonanywhere.com/TakeCourses';  // Replace with your actual Flask server URL
    final username = Hive.box('userBox').get('username');
    print("USERNAME: $username");
      final Map<String, dynamic> requestBody = {
      'username': username,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
                print("print the jason  ? $jsonResponse");
                
                setState(() {
                                  courses = jsonResponse['courses'].cast<String>();
                                  coursesIndex = (jsonResponse['CourseID'] as List).map((item) => item['COId'].toString()).toList();

                });
      }
      else {
        print('Request failed with status: ${response.body}.');

      }
  }

      @override
  void initState() {
    // TODO: implement initState
    super.initState();
    takecources();
  }
      
    String _getCourseBackground(int index) {
    final List<String> colors = [
      'lib/assets/img/bg1.jpg',
      'lib/assets/img/bg2.jpg',
      'lib/assets/img/bg3.jpg',
      'lib/assets/img/bg4.jpg',
      'lib/assets/img/bg5.jpg',
      'lib/assets/img/bg6.jpg',
      'lib/assets/img/bg7.jpg',
      'lib/assets/img/bg8.jpg',
    ];
    return colors[index % colors.length]; // Cycle through these colors
  }
  // final List<String> Courses = [
  //   'Intro to Artificial Intelligence',
  //   'Data Structures and Algorithms',
  //   'Machine Learning',
  //   'Web Development',
  //   'Mobile App Development',
  //   'Cybersecurity',
  //   'Cloud Computing',
  //   'Software Engineering',
  // ];
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        title: Text('Courses'),
      ),
      body: 
      Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, // Enable vertical scrolling
                            child: Column(
                              children: List.generate(
                                courses.length, // Limit to 2 courses (you can change this number)
                                (index) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 14.0, // Spacing between cards
                                  ),
                                  child: Container(
                                    width: 350, // Width of each card
                                    height: 140, // Height of each card
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(15), // Rounded corners
                                      image: DecorationImage(
                                        image: AssetImage(_getCourseBackground(index)),
                                        fit: BoxFit
                                            .cover, // Make the image cover the entire card
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.black.withOpacity(
                                            0.5), // Add a semi-transparent overlay for readability
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            16.0), // Padding inside the card
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Align to the left
                                          children: [
                                          
                                            Text(
                                              courses[index],
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20), // Add some spacing
                                            ElevatedButton(
                                              onPressed: () {
                                                String title = "Welcome to ${courses[index]}";
                                                String body = "Get started with the course content";
                                                  showNotification(title, body);
                                                final String co = "COId";
                                                 Hive.box('userBox').put('COId', coursesIndex[index]);
                                                print("Course: ${courses[index]}, ${coursesIndex[index]}");
                                                 Navigator.pushNamed(context, '/CourseContent',arguments: {'courseId': courses[index], 'courseIndex': coursesIndex[index]},);
                                              
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.white, // Button color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      15), // Rounded corners
                                                ),
                                              ),
                                              child: Text(
                                                
                                                'Start',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
          
              // Add your course cards here (as shown in the previous example)
          
              // Button to view all courses
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0), // Padding for the button
                child: SizedBox(
                  width: double.infinity, // Make the button take the full width
                  child: ElevatedButton(
                    onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Courses()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF165D96), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'View all courses',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16, // Font size
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