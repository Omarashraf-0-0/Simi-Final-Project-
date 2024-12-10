import 'package:flutter/material.dart';
import 'package:studymate/pages/AboLayla/AboLaylaChat.dart'; // Update the import path accordingly

class AboLaylaCourses extends StatefulWidget {
  const AboLaylaCourses({super.key});

  @override
  AboLaylaCoursesState createState() => AboLaylaCoursesState();
}

class AboLaylaCoursesState extends State<AboLaylaCourses> {
  String? selectedCourse;
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // Blue color for the AppBar
        title: Text(
          'Courses and Languages',
          style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 25,
              color: Colors.white, // Text color
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedCourse,
              decoration: InputDecoration(
                labelText: 'Choose Course',
                prefixIcon: selectedCourse == null ? Icon(Icons.book) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down),
              items: <String>[
                'Field 1',
                'Field 2',
                'Field 3',
                'Field 4',
                'Field 5',
                'Field 6'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      if (selectedCourse != value)
                        Icon(Icons.circle,
                            size: 16, color: Colors.grey), // Small icon
                      if (selectedCourse != value) SizedBox(width: 10),
                      Text(value,
                          style:
                              TextStyle(color: Colors.grey)), // Light gray text
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Choose Language',
                prefixIcon:
                    selectedLanguage == null ? Icon(Icons.language) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down),
              items: <String>['English', 'مصري'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      if (selectedLanguage != value)
                        Icon(Icons.circle,
                            size: 16, color: Colors.grey), // Small icon
                      if (selectedLanguage != value) SizedBox(width: 10),
                      Text(value,
                          style:
                              TextStyle(color: Colors.grey)), // Light gray text
                    ],
                  ),
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
              // Inside the 'Next' button onPressed
              onPressed: () {
                if (selectedCourse != null && selectedLanguage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AboLaylaChat(selectedLanguage: selectedLanguage!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both course and language.'),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF165D96), // Button color
                padding: EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15), // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button radius
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 20, // Button text size
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.white, // Text color
                  fontFamily: 'League Spartan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
