import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/pages/Resuorces/SRS.dart';

class CourseContent extends StatefulWidget {
  const CourseContent({super.key});

  @override
  _CourseContentState createState() => _CourseContentState();
}
 String? courseName ;
 String? courseIndex;
class _CourseContentState extends State<CourseContent> {

  // List to store selected CourseContent
    
    
  List<String> selectedCourseContent = [];
  Map<String, List<String>> categorizedList = {};
  List<String> listFromL = []; 
  List<String> lnames = [];
  List<String> listFromQ = []; 
  List<String> Qnames = [];
  List<String> listFromSE = []; 
  List<String> SEnames = [];
  List<String> listFromSU = []; 
  List<String> SUnames = [];
 final Map<String, String> subjectLinks = {};
 

   Future<void> getcources() async {
   
    const url = 'https://alyibrahim.pythonanywhere.com/CourseContent';  // Replace with your actual Flask server URL
    print('srsdkajsdfk$courseIndex');
      final Map<String, dynamic> requestBody = {
      'courseIdx': courseIndex,
      
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
                print("print the jason  ? $jsonResponse");
                print("print the jason  ? $courseIndex");
               setState(() {
                jsonResponse['subInfo'].forEach((resource) {
                  String category = resource['RCat'];
                  if (!categorizedList.containsKey(category)) {
                    categorizedList[category] = [];
                  }
                  categorizedList[category]?.add('${resource['RName']}: ${resource['RFileURL']}');
                });

                  print(categorizedList);
                listFromL = categorizedList['L']!;
                listFromSU = categorizedList['Su']!;
                listFromQ = categorizedList['Q']!;
                listFromSE = categorizedList['Se']!;
                lnames = listFromL.map((e) => e.split(':')[0]).toList();
                SEnames = listFromSE.map((e) => e.split(':')[0]).toList();
                SUnames = listFromSU.map((e) => e.split(':')[0]).toList();
                Qnames = listFromQ.map((e) => e.split(':')[0]).toList();

                  
                    categorizedList.forEach((category, subjects) {
                        for (var subject in subjects) {
                          var index = subject.indexOf(': ');
                          if (index != -1) {
                            var subjectName = subject.substring(0, index);
                            var link = subject.substring(index + 2); // +2 to skip the ': ' characters
                            subjectLinks[subjectName] = link;
                            // fint(subjectLinks[subjectName]);
                          }
                        }
                      });
                    // print("Subject Links: $subjectLinks");
                  
                                  // courses = jsonResponse['courses'].cast<String>();
                                  // coursesIndex = (jsonResponse['CourseID'] as List).map((item) => item['COId'].toString()).toList();

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
    getcources();
  }
  @override
  Widget build(BuildContext context) {
  
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        courseName = args?['courseId']; // Get the course ID
        courseIndex = args?['courseIndex']; // Get the course index
   // print("Course Name: $courseName, Course Index: $courseIndex");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Content',
          style: TextStyle(color: Colors.black), // Text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Terms and CourseContent
            _buildTermDropdown('Lectures', lnames),
            // Term 2
            _buildTermDropdown('Sections',SEnames),
            // Term 3
            _buildTermDropdown('Summaries', SUnames),
            // Term 4
            _buildTermDropdown('Quizzes', Qnames),
            // Dont forget to add resources " LINKS To study "
            // Submit Button
            if (selectedCourseContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // _registerCourseContent(); // Register CourseContent
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermDropdown(String term, List<String> subjects) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border color
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.my_library_books, color: Color.fromARGB(255, 104, 110, 114)), // Icon
              const SizedBox(width: 15),
              Text(
                term,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          children: subjects
              .map(
                (subject) => ListTile(
                  leading: Icon(Icons.book
                  ),
                  title: Text(subject),
                  onTap: () {
                    // _toggleCourseContentelection(subject); // Toggle selection
                    final link = subjectLinks[subject];
                    print('Link: $link');
                  if (link != null) {
                  Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => MaterialCourses(pdfUrl: link ,), // the widget of the page i want to go to (( second )) 
                )
                );
                    // _launchURL(link);
                  } else {
                    print('No link found for $subject');
                  }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

}
