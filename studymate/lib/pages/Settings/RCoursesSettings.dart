import 'package:flutter/material.dart';
import 'package:studymate/theme/app_constants.dart';

class Rcoursessettings extends StatefulWidget {
  const Rcoursessettings({super.key});

  @override
  _RcoursessettingsState createState() => _RcoursessettingsState();
}

class _RcoursessettingsState extends State<Rcoursessettings> {
  List<String> courses = [
    'Math',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science'
  ];
  List<String> selectedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.buildAppBar(
        title: 'Courses Settings',
        leading: AppConstants.buildBackButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlueDark,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    // Save selected courses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Courses saved: ${selectedCourses.join(', ')}',
                          style: AppConstants.bodyText,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Save Changes',
                    style: AppConstants.subtitle.copyWith(
                      color: AppConstants.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
