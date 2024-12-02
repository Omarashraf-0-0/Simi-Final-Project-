import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AboLaylaCourses extends StatefulWidget {
  @override
  _AboLaylaCoursesState createState() => _AboLaylaCoursesState();
}

class _AboLaylaCoursesState extends State<AboLaylaCourses> {
  String? selectedCourse;
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses and Languages',
          style: TextStyle(fontFamily: 'League Spartan', fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Row(
                  children: [
                    Icon(Icons.book, size: 16, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Choose Course',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                items: <String>['Field 1', 'Field 2', 'Field 3', 'Field 4', 'Field 5', 'Field 6']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 16, color: Colors.grey), // Small icon
                        SizedBox(width: 10),
                        Text(value, style: TextStyle(color: Colors.grey)), // Light gray text
                      ],
                    ),
                  );
                }).toList(),
                value: selectedCourse,
                onChanged: (newValue) {
                  setState(() {
                    selectedCourse = newValue;
                  });
                },
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                iconEnabledColor: Colors.grey,
                buttonHeight: 50,
                buttonWidth: 200,
                buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                buttonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedCourse == null ? Colors.grey : Color(0xFF165D96),
                  ),
                  color: selectedCourse == null ? Colors.grey[200] : Color(0xFF165D96),
                ),
                buttonElevation: 2,
                itemHeight: 40,
                itemPadding: const EdgeInsets.only(left: 14, right: 14),
                dropdownMaxHeight: 200,
                dropdownWidth: 150, // Smaller dropdown width
                dropdownPadding: null,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey), // Light gray border
                  color: Colors.white,
                ),
                dropdownElevation: 8,
                scrollbarRadius: const Radius.circular(40),
                scrollbarThickness: 6,
                scrollbarAlwaysShow: true,
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Row(
                  children: [
                    Icon(Icons.language, size: 16, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Choose Language',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                items: <String>['Field 1', 'Field 2'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 16, color: Colors.grey), // Small icon
                        SizedBox(width: 10),
                        Text(value, style: TextStyle(color: Colors.grey)), // Light gray text
                      ],
                    ),
                  );
                }).toList(),
                value: selectedLanguage,
                onChanged: (newValue) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                },
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                iconEnabledColor: Colors.grey,
                buttonHeight: 50,
                buttonWidth: 200,
                buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                buttonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedLanguage == null ? Colors.grey : Color(0xFF165D96),
                  ),
                  color: selectedLanguage == null ? Colors.grey[200] : Color(0xFF165D96),
                ),
                buttonElevation: 2,
                itemHeight: 40,
                itemPadding: const EdgeInsets.only(left: 14, right: 14),
                dropdownMaxHeight: 200,
                dropdownWidth: 150, // Smaller dropdown width
                dropdownPadding: null,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey), // Light gray border
                  color: Colors.white,
                ),
                dropdownElevation: 8,
                scrollbarRadius: const Radius.circular(40),
                scrollbarThickness: 6,
                scrollbarAlwaysShow: true,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF165D96), // Button color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Button size
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