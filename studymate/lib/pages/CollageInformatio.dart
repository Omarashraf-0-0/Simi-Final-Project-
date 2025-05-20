import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/Classes/User.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/OTP.dart';
import '../Pop-ups/PopUps_Failed.dart';
import '../Pop-ups/PopUps_Warning.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

class CollageInformation extends StatefulWidget {
  final Student? user;
  const CollageInformation({
    super.key,
    this.user,
  });

  @override
  State<CollageInformation> createState() => _CollageInformationState();
}

class _CollageInformationState extends State<CollageInformation> {
  // State variables for dropdown selections
  String? selectedUniversity;
  String? selectedCollege;
  String? selectedMajor;

  final TextEditingController registrationNumberController = TextEditingController();

  // Dropdown options
  final List<String> universities = ['AAST', 'AUC', 'GUC', 'MIU', 'MSA'];
  final List<String> colleges = ['Engineering', 'Business', 'Computing', 'Media', 'Pharmacy'];
  final List<String> majors = ['Computer Science', 'Business Administration', 'Media', 'Pharmacy', 'Engineering'];

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Branding colors
  final Color blue1 = Color(0xFF1c74bb);
  final Color blue2 = Color(0xFF165d96);
  final Color cyan1 = Color(0xFF18bebc);
  final Color cyan2 = Color(0xFF139896);
  final Color black = Color(0xFF000000);
  final Color white = Color(0xFFFFFFFF);

  @override
  void dispose() {
    registrationNumberController.dispose();
    super.dispose();
  }


  // User createUser() {
  //   User user = User(
  //     username: widget.user?.username,
  //     password: widget.user?.password,
  //     fullName: widget.user?.fullName,
  //     role: widget.user?.role,
  //     email: widget.user?.email,
  //     phoneNumber: widget.user?.phoneNumber,
  //     address: widget.user?.address,
  //     gender: widget.user?.gender,
  //     collage: selectedCollege,
  //     university: selectedUniversity,
  //     major: selectedMajor,
  //     term_level: 1,
  //     pfp: widget.user?.pfp,
  //     xp: 0,
  //     level: 1,
  //     title: 'newbie',
  //     registrationNumber: registrationNumberController.text,
  //     birthDate: widget.user?.birthDate,
  //   );

  //   return user;
  // }

Student createStudent() {
  Student student = Student(); // Singleton instance

  student.initialize(
    username: widget.user?.username,
    password: widget.user?.password,
    fullName: widget.user?.fullName,
    role: widget.user?.role,
    email: widget.user?.email,
    phoneNumber: widget.user?.phoneNumber,
    address: widget.user?.address,
    gender: widget.user?.gender,
    collage: selectedCollege,
    university: selectedUniversity,
    major: selectedMajor,
    term_level: 1,
    pfp: widget.user?.pfp,
    xp: 0,
    level: 1,
    title: 'newbie',
    registrationNumber: registrationNumberController.text,
    birthDate: widget.user?.birthDate,
  );

  return student;
}

  Future<void> registerCollegeInfo() async {
    final String url = 'https://alyibrahim.pythonanywhere.com/register';

    final Map<String, dynamic> data = {
      'username': widget.user?.username,
      'password': widget.user?.password,
      'fullName': widget.user?.fullName,
      'role': widget.user?.role,
      'email': widget.user?.email,
      'phoneNumber': widget.user?.phoneNumber,
      'address': widget.user?.address,
      'gender': widget.user?.gender,
      'college': selectedCollege,
      'university': selectedUniversity,
      'major': selectedMajor,
      'term_level': 1,
      'pfp': widget.user?.pfp,
      'xp': 0,
      'level': 1,
      'title': 'newbie',
      'registrationNumber': registrationNumberController.text,
      'birthDate': widget.user?.birthDate,
    };
    final body = jsonEncode(data);
    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        // Navigate back to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        final responseData = json.decode(response.body);
        showFailedPopup(
          context,
          'Failed',
          responseData['message'],
          'Continue',
        );
      }
    } catch (error) {
      print(error);
      showFailedPopup(
        context,
        'Failed',
        'Failed to register college info: $error',
        'Continue',
      );
    }
  }

  void validateAndRegister() {
    if (_formKey.currentState!.validate()) {
      if (selectedUniversity == null || selectedCollege == null || selectedMajor == null) {
        showWarningPopup(
          context,
          'Warning',
          'Please select all dropdown fields.',
          'OK',
        );
      } else {
        Student user = createStudent();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OTP(user:user)),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive design
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: size.height * 0.02),
              // Title
              Center(
                child: Column(
                  children: [
                    Text(
                      'Last Step!',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'College Information',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // University Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'University',
                        prefixIcon: Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                      validator: (value) => value == null ? 'Please select your university.' : null,
                    ),
                    SizedBox(height: size.height * 0.025),
                    // College Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'College',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                      validator: (value) => value == null ? 'Please select your college.' : null,
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Major Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Major',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                      validator: (value) => value == null ? 'Please select your major.' : null,
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Registration Number Field
                    TextFormField(
                      controller: registrationNumberController,
                      decoration: InputDecoration(
                        labelText: 'Registration Number',
                        prefixIcon: Icon(Icons.confirmation_num_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your registration number.';
                        } else if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                          return 'Registration number must be exactly 9 digits.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: validateAndRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue2,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // Already have an account
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 16,
                              color: black,
                            ),
                          ),
                          SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              // Navigate to Login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: blue2, width: 2),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 16,
                                color: blue2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}