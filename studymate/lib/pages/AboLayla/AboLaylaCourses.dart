import 'package:flutter/material.dart';
import 'package:studymate/pages/AboLayla/AboLaylaChat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class AboLaylaCourses extends StatefulWidget {
  const AboLaylaCourses({super.key});

  @override
  AboLaylaCoursesState createState() => AboLaylaCoursesState();
}

class AboLaylaCoursesState extends State<AboLaylaCourses> {
  List<String> courses = [];
  List<String> courseIds = [];
  String? selectedCourse;
  String? selectedCourseId;
  String? selectedLanguage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    takecourses();
  }

  Future<void> takecourses() async {
    const url = 'https://alyibrahim.pythonanywhere.com/TakeCourses';
    final username = Hive.box('userBox').get('username');
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

      setState(() {
        courses = jsonResponse['courses'].cast<String>();
        courseIds = (jsonResponse['CourseID'] as List)
            .map((item) => item['COId'].toString())
            .toList();
        isLoading = false;
      });
    } else {
      print('Request failed with status: ${response.body}.');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses and Languages',
          style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF165D96),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedCourse,
                      decoration: InputDecoration(
                        labelText: 'Choose Course',
                        prefixIcon:
                            selectedCourse == null ? Icon(Icons.book) : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: courses.map((String course) {
                        return DropdownMenuItem<String>(
                          value: course,
                          child: Text(
                            course,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCourse = newValue;
                          selectedCourseId =
                              courseIds[courses.indexOf(newValue!)];
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedLanguage,
                      decoration: InputDecoration(
                        labelText: 'Choose Language',
                        prefixIcon: selectedLanguage == null
                            ? Icon(Icons.language)
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>['English', 'مصري'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedLanguage = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedCourse != null && selectedLanguage != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboLaylaChat(
                                selectedLanguage: selectedLanguage!,
                                selectedCourse: selectedCourse!,
                                selectedCourseId: selectedCourseId!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please select both course and language.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF165D96),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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