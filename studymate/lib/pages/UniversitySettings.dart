import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/Settings.dart';
import 'package:studymate/pages/UserSettings.dart'; 

class Universitysettings extends StatefulWidget {
  @override
  _UniversitysettingsState createState() => _UniversitysettingsState();
}

class _UniversitysettingsState extends State<Universitysettings> {

String? selectedUniversity;
  String? selectedCollege;
  String? selectedMajor;
  String? selectedTermLevel;

  final TextEditingController RegistrationNumberController = TextEditingController();

  final List<String> universities = ['AAST', 'AUC', 'GUC', 'MIU', 'MSA'];
  final List<String> colleges = ['Engineering', 'Business', 'Computing', 'Media', 'Pharmacy'];
  final List<String> majors = ['Computer Science', 'Business Administration', 'Media', 'Pharmacy', 'Engineering'];
  final List<String> termLevels = ['Prep', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Center(child: Text('University Settings')),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'University Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'University',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: selectedUniversity,
                  items: universities.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedUniversity = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'College',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: selectedCollege,
                  items: colleges.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCollege = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Major',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: selectedMajor,
                  items: majors.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedMajor = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Term Level',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: selectedTermLevel,
                  items: termLevels.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedTermLevel = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 375,
                child: TextField(
                  controller: RegistrationNumberController,
                  decoration: InputDecoration(
                    hintText: 'Registration Number',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: Icon(FontAwesome.id_card),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Save changes action
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
