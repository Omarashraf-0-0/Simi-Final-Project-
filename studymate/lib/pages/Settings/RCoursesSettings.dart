import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Rcoursessettings extends StatefulWidget {
  const Rcoursessettings({super.key});

  @override
  _RcoursessettingsState createState() => _RcoursessettingsState();
}

class _RcoursessettingsState extends State<Rcoursessettings> {
  List<String> courses = ['Math', 'Physics', 'Chemistry', 'Biology', 'Computer Science'];
  List<String> selectedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(child: Text('Courses Settings')),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Save selected courses
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Courses saved: ${selectedCourses.join(', ')}',
                            style: TextStyle(
                              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
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
