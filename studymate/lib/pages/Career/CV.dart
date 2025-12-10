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
              'name': linkedInUsername,
              'linkedinURL': linkedInLink,
            }
          : {
              'name': "No linkedin yet",
              'linkedinURL': "",
            },

      // GitHub section (if applicable)
      'github': addGitHub
          ? {
              'name': gitHubUsername,
              'githubURL': gitHubLink,
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
          'descriptions':
              edu.description.split('\n').map((desc) => desc.trim()).toList(),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Maker',
          style: GoogleFonts.leagueSpartan(
            textStyle: TextStyle(
              color: Colors.white, // Change title color to white
              fontWeight: FontWeight.bold, // Make the font bold
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF165D96),
        iconTheme: IconThemeData(
          color: Colors.white, // Change back arrow color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => name = value!,
              ),
              SizedBox(height: 10),
              InputDatePickerFormField(
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                initialDate: birthdate ?? DateTime(2000),
                fieldLabelText: 'Birthdate',
                onDateSaved: (date) => birthdate = date,
                onDateSubmitted: (date) {},
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: phoneNumber,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => phoneNumber = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 20),

              // LinkedIn & GitHub
              SectionHeader(title: 'LinkedIn & GitHub'),
              CheckboxListTile(
                title: Text('Add LinkedIn'),
                value: addLinkedIn,
                onChanged: (value) {
                  setState(() {
                    addLinkedIn = value!;
                    if (!addLinkedIn) linkedInLink = '';
                  });
                },
              ),
              if (addLinkedIn)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'LinkedIn Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          addLinkedIn && (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                      onSaved: (value) => linkedInUsername = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'LinkedIn Profile URL',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: linkedInLink,
                      validator: (value) =>
                          addLinkedIn && (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                      onSaved: (value) => linkedInLink = value!,
                    ),
                  ],
                ),
              SizedBox(height: 10),
              CheckboxListTile(
                title: Text('Add GitHub'),
                value: addGitHub,
                onChanged: (value) {
                  setState(() {
                    addGitHub = value!;
                    if (!addGitHub) gitHubLink = '';
                  });
                },
              ),
              if (addGitHub)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'GitHub Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          addGitHub && (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                      onSaved: (value) => gitHubUsername = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'GitHub Profile URL',
                        border: OutlineInputBorder(),
                      ),
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
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Objective',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => objective = value!,
              ),
              SizedBox(height: 20),

              // Education
              SectionHeader(title: 'Education'),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Number of Education Entries',
                  border: OutlineInputBorder(),
                ),
                value: educationCount,
                items: List.generate(
                  3,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    educationCount = value!;
                    _addEducationField(value);
                  });
                },
                validator: (value) =>
                    value == null || value < 1 ? 'At least 1 required' : null,
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
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Number of Skill Sections',
                  border: OutlineInputBorder(),
                ),
                value: skillsCount,
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    skillsCount = value!;
                    _addSkillField(value);
                  });
                },
                validator: (value) =>
                    value == null || value < 1 ? 'At least 1 required' : null,
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
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Number of Projects',
                  border: OutlineInputBorder(),
                ),
                value: projectsCount,
                items: List.generate(
                  3,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    projectsCount = value!;
                    _addProjectField(value);
                  });
                },
                validator: (value) =>
                    value == null || value < 1 ? 'At least 1 required' : null,
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
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Number of Experiences',
                  border: OutlineInputBorder(),
                ),
                value: experienceCount,
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    experienceCount = value!;
                    _addExperienceField(value);
                  });
                },
                validator: (value) =>
                    value == null || value < 1 ? 'At least 1 required' : null,
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
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  backgroundColor: Color(
                      0xFF165D96), // Use backgroundColor instead of primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Generate CV',
                  style: GoogleFonts.leagueSpartan(
                    textStyle: TextStyle(
                      color: Colors.white, // Change text color to white
                      fontWeight: FontWeight.bold, // Make the font bold
                      fontSize: 18,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF165D96),
        ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education $index',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'University Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => education.universityName = value!,
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Degree',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => education.degree = value!,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => education.from = value!,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => education.to = value!,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => education.description = value!,
        ),
        SizedBox(height: 20),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Section $index',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Head',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => skill.head = value!,
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Skills (separated by comma)',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => skill.skills = value!,
        ),
        SizedBox(height: 20),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project $index',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Head',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => project.head = value!,
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => project.description = value!,
        ),
        SizedBox(height: 20),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience $index',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          onSaved: (value) => experience.description = value!,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
