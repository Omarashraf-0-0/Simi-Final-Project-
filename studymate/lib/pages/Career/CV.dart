import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'PDFViewerPage.dart';

class CV extends StatefulWidget {
  const CV({super.key});

  @override
  State<CV> createState() => _CVState();
}

class _CVState extends State<CV> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information
  String name = '';
  DateTime? birthdate;
  String phoneNumber = '';
  String email = '';

  // LinkedIn & GitHub
  String linkedInUsername = 'No linkedin yet';
  bool addLinkedIn = false;
  String linkedInLink = '';

  String gitHubUsername = 'No github yet';
  bool addGitHub = false;
  String gitHubLink = '';

  // Objective
  String objective = '';

  // Education
  int educationCount = 1;
  List<Education> educations = [Education()];

  // Skills
  int skillsCount = 1;
  List<Skill> skills = [Skill()];

  // Projects
  int projectsCount = 1;
  List<Project> projects = [Project()];

  // Experience
  int experienceCount = 1;
  List<Experience> experiences = [Experience()];

  Future<void> generateCV() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return; // If the form is invalid, stop execution
    }
    _formKey.currentState!.save(); // Save the form fields

    // Build the CV data as before
    Map<String, dynamic> cvData = {
      // Flattened personal information
      'name': name,
      'birth': birthdate != null
          ? DateFormat('MMMM d, yyyy').format(birthdate!)
          : '',
      'address': Hive.box('userBox').get('address'),
      'phone': phoneNumber,
      'email': email,

      // LinkedIn section (if applicable)
      'linkedin': addLinkedIn
          ? {
              'name': linkedInUsername.isEmpty
                  ? "No linkedin yet"
                  : linkedInUsername,
              'linkedinURL': linkedInLink.isEmpty ? "" : linkedInLink,
            }
          : {
              'name': "No linkedin yet",
              'linkedinURL': "",
            },

      // GitHub section (if applicable)
      'github': addGitHub
          ? {
              'name': gitHubUsername.isEmpty ? "No github yet" : gitHubUsername,
              'githubURL': gitHubLink.isEmpty ? "" : gitHubLink,
            }
          : {
              'name': "No github yet",
              'githubURL': "",
            },

      // Objective
      'objective': objective,

      // Updated education section
      'education': educations.map((edu) {
        return {
          'degree': edu.degree,
          'years': "${edu.from} - ${edu.to}",
          'institution': edu.universityName,
          'descriptions': edu.description.isNotEmpty
              ? edu.description.split('\n').map((desc) => desc.trim()).toList()
              : [],
        };
      }).toList(),

      // Adjusted skills structure
      'skills': Map.fromEntries(
        skills.map((sk) => MapEntry(
              sk.head,
              sk.skills.split(',').map((s) => s.trim()).toList(),
            )),
      ),

      // Modified projects structure
      'projects': projects.map((proj) {
        return {
          proj.head: proj.description,
        };
      }).toList(),

      // Experience
      'experience': experiences.map((exp) {
        return exp.description;
      }).toList(),
    };

    const url = 'https://alyibrahim.pythonanywhere.com/create_cv';

    // Show a loading indicator while generating the CV
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      print("Generating CV ...");
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cvData),
      );

      // Dismiss the loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        print("CV generated successfully");

        // Get the PDF file bytes
        final bytes = response.bodyBytes;

        // Save the PDF file locally
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/cv.pdf');
        await file.writeAsBytes(bytes);

        // Navigate to PDF viewer page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(filePath: file.path),
          ),
        );
      } else {
        print("Failed to generate CV: ${response.body}");

        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate CV')),
        );
      }
    } catch (e) {
      // Dismiss the loading indicator in case of an exception
      Navigator.of(context).pop();

      print('Error during making CV: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating CV')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPersonalInfo();
  }

  void _loadPersonalInfo() async {
    var box = await Hive.openBox('userBox');
    setState(() {
      name = box.get('name', defaultValue: '');
      birthdate = box.get('birthdate') != null
          ? DateTime.parse(box.get('birthdate'))
          : null;
      phoneNumber = box.get('phoneNumber', defaultValue: '');
      email = box.get('email', defaultValue: '');
    });
  }

  void _addEducationField(int count) {
    setState(() {
      educations = List.generate(count, (index) => Education());
    });
  }

  void _addSkillField(int count) {
    setState(() {
      skills = List.generate(count, (index) => Skill());
    });
  }

  void _addProjectField(int count) {
    setState(() {
      projects = List.generate(count, (index) => Project());
    });
  }

  void _addExperienceField(int count) {
    setState(() {
      experiences = List.generate(count, (index) => Experience());
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1c74bb);
    const Color secondaryColor = Color(0xFF165d96);
    const Color accentColor = Color(0xFF18bebc);
    const Color backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor, accentColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CV Maker',
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Build your professional CV',
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Personal Information
                    SectionHeader(title: 'Personal Information'),
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.person_outline,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(fontSize: 15),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                      onSaved: (value) => name = value!,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Birthdate',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon:
                            Icon(Icons.cake_outlined, color: Color(0xFF1c74bb)),
                        suffixIcon: Icon(Icons.calendar_today,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(fontSize: 15),
                      controller: TextEditingController(
                        text: birthdate != null
                            ? DateFormat('MMMM d, yyyy').format(birthdate!)
                            : '',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: birthdate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF1c74bb),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            birthdate = picked;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: phoneNumber,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(fontSize: 15),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                      onSaved: (value) => phoneNumber = value!,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(fontSize: 15),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!regex.hasMatch(value))
                          return 'Enter a valid email';
                        return null;
                      },
                      onSaved: (value) => email = value!,
                    ),
                    SizedBox(height: 20),

                    // LinkedIn & GitHub
                    SectionHeader(title: 'LinkedIn & GitHub'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: addLinkedIn
                              ? Color(0xFF1c74bb)
                              : Colors.grey[300]!,
                          width: addLinkedIn ? 2 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Add LinkedIn',
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF165d96),
                          ),
                        ),
                        secondary: Icon(
                          Icons.work,
                          color: Color(0xFF1c74bb),
                        ),
                        activeColor: Color(0xFF1c74bb),
                        value: addLinkedIn,
                        onChanged: (value) {
                          setState(() {
                            addLinkedIn = value!;
                            if (!addLinkedIn) linkedInLink = '';
                          });
                        },
                      ),
                    ),
                    if (addLinkedIn)
                      Column(
                        children: [
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'LinkedIn Username',
                              labelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              floatingLabelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon:
                                  Icon(Icons.person, color: Color(0xFF1c74bb)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color(0xFF1c74bb), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.leagueSpartan(fontSize: 15),
                            validator: (value) =>
                                addLinkedIn && (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                            onSaved: (value) => linkedInUsername = value!,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'LinkedIn Profile URL',
                              labelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              floatingLabelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon:
                                  Icon(Icons.link, color: Color(0xFF1c74bb)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color(0xFF1c74bb), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.leagueSpartan(fontSize: 15),
                            initialValue: linkedInLink,
                            validator: (value) =>
                                addLinkedIn && (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                            onSaved: (value) => linkedInLink = value!,
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              addGitHub ? Color(0xFF1c74bb) : Colors.grey[300]!,
                          width: addGitHub ? 2 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Add GitHub',
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF165d96),
                          ),
                        ),
                        secondary: Icon(
                          Icons.code,
                          color: Color(0xFF1c74bb),
                        ),
                        activeColor: Color(0xFF1c74bb),
                        value: addGitHub,
                        onChanged: (value) {
                          setState(() {
                            addGitHub = value!;
                            if (!addGitHub) gitHubLink = '';
                          });
                        },
                      ),
                    ),
                    if (addGitHub)
                      Column(
                        children: [
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'GitHub Username',
                              labelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              floatingLabelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon:
                                  Icon(Icons.code, color: Color(0xFF1c74bb)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color(0xFF1c74bb), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.leagueSpartan(fontSize: 15),
                            validator: (value) =>
                                addGitHub && (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                            onSaved: (value) => gitHubUsername = value!,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'GitHub Profile URL',
                              labelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              floatingLabelStyle: GoogleFonts.leagueSpartan(
                                color: Color(0xFF1c74bb),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon:
                                  Icon(Icons.link, color: Color(0xFF1c74bb)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Color(0xFF1c74bb), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.leagueSpartan(fontSize: 15),
                            initialValue: gitHubLink,
                            validator: (value) =>
                                addGitHub && (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                            onSaved: (value) => gitHubLink = value!,
                          ),
                        ],
                      ),
                    SizedBox(height: 20),

                    // Objective
                    SectionHeader(title: 'Objective'),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Objective',
                        hintText: 'Describe your career goals...',
                        hintStyle: GoogleFonts.leagueSpartan(
                          color: Colors.grey[400],
                        ),
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.flag_outlined,
                              color: Color(0xFF1c74bb)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(fontSize: 15),
                      maxLines: 4,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                      onSaved: (value) => objective = value!,
                    ),
                    SizedBox(height: 20),

                    // Education
                    SectionHeader(title: 'Education'),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Number of Education Entries',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.format_list_numbered,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(
                          fontSize: 15, color: Colors.black),
                      value: educationCount,
                      items: List.generate(
                        3,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}',
                              style: GoogleFonts.leagueSpartan()),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          educationCount = value!;
                          _addEducationField(value);
                        });
                      },
                      validator: (value) => value == null || value < 1
                          ? 'At least 1 required'
                          : null,
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: educationCount,
                      itemBuilder: (context, index) {
                        return EducationForm(
                          index: index + 1,
                          education: educations[index],
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Skills
                    SectionHeader(title: 'Skills'),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Number of Skill Sections',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.format_list_numbered,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(
                          fontSize: 15, color: Colors.black),
                      value: skillsCount,
                      items: List.generate(
                        5,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}',
                              style: GoogleFonts.leagueSpartan()),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          skillsCount = value!;
                          _addSkillField(value);
                        });
                      },
                      validator: (value) => value == null || value < 1
                          ? 'At least 1 required'
                          : null,
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: skillsCount,
                      itemBuilder: (context, index) {
                        return SkillForm(
                          index: index + 1,
                          skill: skills[index],
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Projects
                    SectionHeader(title: 'Projects'),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Number of Projects',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.format_list_numbered,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(
                          fontSize: 15, color: Colors.black),
                      value: projectsCount,
                      items: List.generate(
                        3,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}',
                              style: GoogleFonts.leagueSpartan()),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          projectsCount = value!;
                          _addProjectField(value);
                        });
                      },
                      validator: (value) => value == null || value < 1
                          ? 'At least 1 required'
                          : null,
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: projectsCount,
                      itemBuilder: (context, index) {
                        return ProjectForm(
                          index: index + 1,
                          project: projects[index],
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Experience
                    SectionHeader(title: 'Experience'),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Number of Experiences',
                        labelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: GoogleFonts.leagueSpartan(
                          color: Color(0xFF1c74bb),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.format_list_numbered,
                            color: Color(0xFF1c74bb)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1c74bb), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.leagueSpartan(
                          fontSize: 15, color: Colors.black),
                      value: experienceCount,
                      items: List.generate(
                        5,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}',
                              style: GoogleFonts.leagueSpartan()),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          experienceCount = value!;
                          _addExperienceField(value);
                        });
                      },
                      validator: (value) => value == null || value < 1
                          ? 'At least 1 required'
                          : null,
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: experienceCount,
                      itemBuilder: (context, index) {
                        return ExperienceForm(
                          index: index + 1,
                          experience: experiences[index],
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      margin: EdgeInsets.only(top: 10, bottom: 20),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _submitForm,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded,
                                    color: Colors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'Generate CV',
                                  style: GoogleFonts.leagueSpartan(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    generateCV();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // هنا يمكنك معالجة البيانات، إرسالها إلى السيرفر أو تخزينها
      // ثم الانتقال إلى صفحة عرض السيرة الذاتية أو أي إجراء آخر

      // مثال بسيط:
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('CV Data'),
          content: SingleChildScrollView(
            child: Text('Name: $name\n'
                'Birthdate: ${birthdate != null ? DateFormat('yyyy-MM-dd').format(birthdate!) : ''}\n'
                'Phone: $phoneNumber\n'
                'Email: $email\n'
                'Objective: $objective\n'
                // يمكنك إضافة بقية البيانات هنا
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// نماذج البيانات

class Education {
  String universityName = '';
  String degree = '';
  String from = '';
  String to = '';
  String description = '';
}

class Skill {
  String head = '';
  String skills = '';
}

class Project {
  String head = '';
  String description = '';
}

class Experience {
  String description = '';
}

// ويدجت لعرض العناوين للأقسام
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1c74bb).withOpacity(0.1),
            Color(0xFF18bebc).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Color(0xFF1c74bb),
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForTitle(title),
            color: Color(0xFF1c74bb),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.leagueSpartan(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF165D96),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'personal information':
        return Icons.person_outline_rounded;
      case 'linkedin & github':
        return Icons.link_rounded;
      case 'objective':
        return Icons.flag_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'skills':
        return Icons.stars_outlined;
      case 'projects':
        return Icons.work_outline_rounded;
      case 'experience':
        return Icons.business_center_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

// ويدجت لنموذج التعليم
class EducationForm extends StatelessWidget {
  final int index;
  final Education education;

  const EducationForm(
      {super.key, required this.index, required this.education});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1c74bb).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1c74bb).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: Color(0xFF1c74bb), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Education $index',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165d96),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'University Name',
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.location_city, color: Color(0xFF1c74bb)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => education.universityName = value!,
          ),
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Degree',
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.school_outlined, color: Color(0xFF1c74bb)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => education.degree = value!,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'From',
                    labelStyle: GoogleFonts.leagueSpartan(
                      color: Color(0xFF1c74bb),
                      fontWeight: FontWeight.w600,
                    ),
                    floatingLabelStyle: GoogleFonts.leagueSpartan(
                      color: Color(0xFF1c74bb),
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Color(0xFF1c74bb), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFF1c74bb), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: GoogleFonts.leagueSpartan(fontSize: 15),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => education.from = value!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'To',
                    labelStyle: GoogleFonts.leagueSpartan(
                      color: Color(0xFF1c74bb),
                      fontWeight: FontWeight.w600,
                    ),
                    floatingLabelStyle: GoogleFonts.leagueSpartan(
                      color: Color(0xFF1c74bb),
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Color(0xFF1c74bb), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFF1c74bb), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: GoogleFonts.leagueSpartan(fontSize: 15),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => education.to = value!,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your achievements...',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.description, color: Color(0xFF1c74bb)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            maxLines: 3,
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => education.description = value!,
          ),
        ],
      ),
    );
  }
}

// ويدجت لنموذج المهارات
class SkillForm extends StatelessWidget {
  final int index;
  final Skill skill;

  const SkillForm({super.key, required this.index, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1c74bb).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1c74bb).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stars, color: Color(0xFF1c74bb), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Skill Section $index',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165d96),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Head',
              hintText: 'e.g., Programming Languages',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.title, color: Color(0xFF1c74bb)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => skill.head = value!,
          ),
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Skills (separated by comma)',
              hintText: 'Python, Java, C++',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.list, color: Color(0xFF1c74bb)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => skill.skills = value!,
          ),
        ],
      ),
    );
  }
}

// ويدجت لنموذج المشاريع
class ProjectForm extends StatelessWidget {
  final int index;
  final Project project;

  const ProjectForm({super.key, required this.index, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1c74bb).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1c74bb).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.work_outline,
                    color: Color(0xFF1c74bb), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Project $index',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165d96),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Project Name',
              hintText: 'e.g., E-Commerce Website',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(Icons.folder, color: Color(0xFF1c74bb)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => project.head = value!,
          ),
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your project...',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.description, color: Color(0xFF1c74bb)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            maxLines: 3,
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => project.description = value!,
          ),
        ],
      ),
    );
  }
}

// ويدجت لنموذج الخبرة
class ExperienceForm extends StatelessWidget {
  final int index;
  final Experience experience;

  const ExperienceForm(
      {super.key, required this.index, required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1c74bb).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1c74bb).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.business_center,
                    color: Color(0xFF1c74bb), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Experience $index',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165d96),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your work experience...',
              hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey[400]),
              labelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: GoogleFonts.leagueSpartan(
                color: Color(0xFF1c74bb),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.work, color: Color(0xFF1c74bb)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1c74bb), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.leagueSpartan(fontSize: 15),
            maxLines: 4,
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => experience.description = value!,
          ),
        ],
      ),
    );
  }
}
