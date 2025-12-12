import 'package:flutter/material.dart';
import 'package:studymate/Classes/User.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/OTP.dart';
import '../Pop-ups/StylishPopup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final TextEditingController registrationNumberController =
      TextEditingController();

  // Dropdown options
  final List<String> universities = ['AAST', 'AUC', 'GUC', 'MIU', 'MSA'];
  final List<String> colleges = [
    'Engineering',
    'Business',
    'Computing',
    'Media',
    'Pharmacy'
  ];
  final List<String> majors = [
    'Computer Science',
    'Business Administration',
    'Media',
    'Pharmacy',
    'Engineering'
  ];

  final _formKey = GlobalKey<FormState>(); // Form key for validation

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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        final responseData = json.decode(response.body);
        await StylishPopup.error(
          context: context,
          title: 'Failed',
          message: responseData['message'],
        );
      }
    } catch (error) {
      print(error);
      await StylishPopup.error(
        context: context,
        title: 'Failed',
        message: 'Failed to register college info: $error',
      );
    }
  }

  void validateAndRegister() async {
    if (_formKey.currentState!.validate()) {
      if (selectedUniversity == null ||
          selectedCollege == null ||
          selectedMajor == null) {
        await StylishPopup.warning(
          context: context,
          title: 'Warning',
          message: 'Please select all dropdown fields.',
        );
      } else {
        Student user = createStudent();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => OTP(user: user)),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1c74bb),
              Color(0xFF165d96),
              Color(0xFF18bebc),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Title
                      Text(
                        'Last Step!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'College Information',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // White container for form
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // University Dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'University',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Color(0xFF1c74bb),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.school_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF1c74bb),
                                      width: 2,
                                    ),
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
                                validator: (value) => value == null
                                    ? 'Please select your university.'
                                    : null,
                              ),

                              SizedBox(height: 20),

                              // College Dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'College',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Color(0xFF1c74bb),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF1c74bb),
                                      width: 2,
                                    ),
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
                                validator: (value) => value == null
                                    ? 'Please select your college.'
                                    : null,
                              ),

                              SizedBox(height: 20),

                              // Major Dropdown
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Major',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Color(0xFF1c74bb),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF1c74bb),
                                      width: 2,
                                    ),
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
                                validator: (value) => value == null
                                    ? 'Please select your major.'
                                    : null,
                              ),

                              SizedBox(height: 20),

                              // Registration Number Field
                              TextFormField(
                                controller: registrationNumberController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Registration Number',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Color(0xFF1c74bb),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.confirmation_num_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF1c74bb),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your registration number.';
                                  } else if (!RegExp(r'^\d{9}$')
                                      .hasMatch(value)) {
                                    return 'Must be exactly 9 digits';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 30),

                              // Register Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1c74bb),
                                      Color(0xFF165d96),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF1c74bb).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: validateAndRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Login button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: Color(0xFF1c74bb),
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),
                    ],
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
