import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';
import 'package:studymate/theme/app_constants.dart';

class Universitysettings extends StatefulWidget {
  const Universitysettings({super.key});

  @override
  _UniversitysettingsState createState() => _UniversitysettingsState();
}

class _UniversitysettingsState extends State<Universitysettings> {
  String? selectedUniversity;
  String? selectedCollege;
  String? selectedMajor;
  String? selectedTermLevel;

  final TextEditingController registrationNumberController =
      TextEditingController();

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
  final List<String> termLevels = [
    'Prep',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  final _userUpdater =
      UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  final RegExp inputRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  @override
  void initState() {
    super.initState();
    // Initialize the variables from Hive
    selectedUniversity = Hive.box('userBox').get('university');
    selectedCollege = Hive.box('userBox').get('college');
    selectedMajor = Hive.box('userBox').get('major');
    selectedTermLevel = '${Hive.box('userBox').get('term_level')}';
    registrationNumberController.text =
        Hive.box('userBox').get('Registration_Number') ?? '';
  }

  bool validateInput(String input) {
    return inputRegExp.hasMatch(input);
  }

  Future<void> updateData() async {
    final username = Hive.box('userBox').get('username');
    if (!validateInput(username) ||
        !validateInput(registrationNumberController.text)) {
      // Handle invalid input
      print('Invalid input');
      return;
    }

    final Map<String, dynamic> requestData = {
      'username': username,
      'university': selectedUniversity,
      'college': selectedCollege,
      'major': selectedMajor,
      'term_level': selectedTermLevel,
      'Registration_Number': registrationNumberController.text,
    };

    await _userUpdater.updateUserData(
      requestData: requestData,
      context: context,
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    registrationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.buildAppBar(
        title: 'University Settings',
        leading: AppConstants.buildBackButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'University Information',
                  style: AppConstants.cardTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // University Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'University',
                  prefixIcon: Icon(Icons.school),
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
              ),
              SizedBox(height: 20),
              // College Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'College',
                  prefixIcon: Icon(Icons.account_balance),
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
              ),
              SizedBox(height: 20),
              // Major Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Major',
                  prefixIcon: Icon(Icons.menu_book),
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
              ),
              SizedBox(height: 20),
              // Term Level Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Term Level',
                  prefixIcon: Icon(Icons.bar_chart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                value: selectedTermLevel,
                items: termLevels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child:
                        Text(value == 'Prep' ? 'Preparatory' : 'Term $value'),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedTermLevel = value;
                  });
                },
              ),
              SizedBox(height: 20),
              // Registration Number Field
              TextField(
                controller: registrationNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.confirmation_num),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 30),
              // Save Changes Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlueDark,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: AppConstants.subtitle.copyWith(
                      color: AppConstants.textOnPrimary,
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
