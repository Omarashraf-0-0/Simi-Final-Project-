import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/pages/Resuorces/SRS.dart';

class CourseContent extends StatefulWidget {
  const CourseContent({super.key});

  @override
  _CourseContentState createState() => _CourseContentState();
}

String? courseName;
String? courseIndex;

class _CourseContentState extends State<CourseContent> {
  List<String> selectedCourseContent = [];
  Map<String, List<String>> categorizedList = {};
  List<String> listFromL = [];
  List<String> lnames = [];
  List<String> listFromQ = [];
  List<String> Qnames = [];
  List<String> listFromSE = [];
  List<String> SEnames = [];
  List<String> listFromSU = [];
  List<String> SUnames = [];
  final Map<String, String> subjectLinks = {};
  final Map<String, int> subjectIds = {};

  Future<void> updateMaterial(int idx, String Title, String Mcat) async {
    const url = 'https://alyibrahim.pythonanywhere.com/updateMaterial';
    if (Mcat == 'Lectures') {
      Mcat = 'L';
    } else if (Mcat == 'Sections') {
      Mcat = 'Se';
    } else if (Mcat == 'Summaries') {
      Mcat = 'Su';
    } else if (Mcat == 'Quizzes') {
      Mcat = 'Q';
    }
    print(Mcat);
    final Map<String, dynamic> requestBody = {
      'materialIdx': idx,
      'materialTitle': Title,
      'materialMcat': Mcat,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Request successful');
      print(response.body);
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }

  Future<void> getcources() async {
    const url = 'https://alyibrahim.pythonanywhere.com/CourseContent';
    print('srsdkajsdfk$courseIndex');
    final Map<String, dynamic> requestBody = {
      'courseIdx': Hive.box('userBox').get('COId'),
      'username' : Hive.box('userBox').get('username'),
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("print the json: $jsonResponse");
      print("print the json: $courseIndex");
      setState(() {
        jsonResponse['subInfo'].forEach((resource) {
          String category = resource['RCat'];
          if (!categorizedList.containsKey(category)) {
            categorizedList[category] = [];
          }
          categorizedList[category]?.add('${resource['RName']}: ${resource['RFileURL']}');
          subjectIds[resource['RName']] = resource['RId'];
        });

        print(categorizedList);
        if (categorizedList['L'] == null) {
          categorizedList['L'] = [];
        }
        if (categorizedList['Su'] == null) {
          categorizedList['Su'] = [];
        }
        if (categorizedList['Q'] == null) {
          categorizedList['Q'] = [];
        }
        if (categorizedList['Se'] == null) {
          categorizedList['Se'] = [];
        }
        listFromL = categorizedList['L']!;
        listFromSU = categorizedList['Su']!;
        listFromQ = categorizedList['Q']!;
        listFromSE = categorizedList['Se']!;
        lnames = listFromL.map((e) => e.split(':')[0]).toList();
        SEnames = listFromSE.map((e) => e.split(':')[0]).toList();
        SUnames = listFromSU.map((e) => e.split(':')[0]).toList();
        Qnames = listFromQ.map((e) => e.split(':')[0]).toList();

        categorizedList.forEach((category, subjects) {
          for (var subject in subjects) {
            var index = subject.indexOf(': ');
            if (index != -1) {
              var subjectName = subject.substring(0, index);
              var link = subject.substring(index + 2);
              subjectLinks[subjectName] = link;
            }
          }
        });
      });
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }

  Future<void> deleteMaterial(int idx) async {
    const url = 'https://alyibrahim.pythonanywhere.com/deleteMaterial';

    final Map<String, dynamic> requestBody = {
      'materialIdx': idx,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Request successful');
      print(response.body);
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }

 Future<void> addMaterial(String Rurl, String Title, String Mcat , String subid) async {
    const url = 'https://alyibrahim.pythonanywhere.com/addMaterial';
    if (Mcat == 'Lectures') {
      Mcat = 'L';
    } else if (Mcat == 'Sections') {
      Mcat = 'Se';
    } else if (Mcat == 'Summaries') {
      Mcat = 'Su';
    } else if (Mcat == 'Quizzes') {
      Mcat = 'Q';
    }
    print(Mcat);
    final Map<String, dynamic> requestBody = {

      'materialUrl': Rurl,
      'materialTitle': Title,
      'materialMcat': Mcat,
      'subid' : subid,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Request successful');
      print(response.body);
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }
  
  @override
  void initState() {
    super.initState();
    getcources();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    courseName = args?['courseId'];
    courseIndex = args?['courseIndex'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Content',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildTermDropdown('Lectures', lnames),
            _buildTermDropdown('Sections', SEnames),
            _buildTermDropdown('Summaries', SUnames),
            _buildTermDropdown('Quizzes', Qnames),
            ElevatedButton(
              onPressed: () => _showAddMaterialPopup(context),
              child: const Text('Add Material'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermDropdown(String term, List<String> subjects) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.my_library_books, color: Color.fromARGB(255, 104, 110, 114)),
              const SizedBox(width: 15),
              Text(
                term,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          children: subjects
              .map(
                (subject) => ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(subject),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _showEditPopup(context, subject),
                  ),
                  onTap: () {
                    final link = subjectLinks[subject];
                    if (link != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialCourses(pdfUrl: link),
                        ),
                      );
                    } else {
                      print('No link found for $subject');
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showEditPopup(BuildContext context, String subject) {
    // Initialize controllers and variables
    final TextEditingController titleController = TextEditingController(text: subject);
    String? selectedCategory; // Nullable to avoid mismatch
    final List<String> categories = ["Resource link", "Lectures", "Sections", "Summaries", "Quizzes"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Tooltip(
                  message: subject,
                  child: Text(
                    '$subject',
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis, // Truncate text if it overflows
                    maxLines: 1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title input field
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              // Dropdown for category selection
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value; // Update selected category
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // if (selectedCategory == null || selectedCategory == "Select Category") {
                    //   // Show error if no valid category is selected
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Please select a valid category.')),
                    //   );
                    //   return;
                    // }
                    print('Title: ${titleController.text}');
                    deleteMaterial(subjectIds[subject]!);
                    print('$selectedCategory');
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory == null || selectedCategory == "Select Category") {
                      // Show error if no valid category is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a valid category.')),
                      );
                      return;
                    }
                    print('Title: ${titleController.text}');
                    updateMaterial(subjectIds[subject]!, titleController.text, selectedCategory!);
                    print('$selectedCategory');
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddMaterialPopup(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    String? selectedCategory;
    final List<String> categories = ["Resource link", "Lectures", "Sections", "Summaries", "Quizzes"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title input field
              
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              // Dropdown for category selection
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              // URL input field
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Resource URL'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add the new material (You can integrate it with backend logic here)
                print('Title: ${titleController.text}');
                print('Category: $selectedCategory');
                print('URL: ${urlController.text}');
                
                addMaterial(urlController.text, titleController.text, selectedCategory!, Hive.box('userBox').get('COId'),);
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
