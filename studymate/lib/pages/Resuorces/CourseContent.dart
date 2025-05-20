import 'dart:isolate'; // Add this import
import 'dart:ui';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Resuorces/CourseClass.dart';
class CourseContent extends StatefulWidget {
  const CourseContent({super.key});

  @override
  _CourseContentState createState() => _CourseContentState();
}

String? courseName;
String? courseIndex;

class _CourseContentState extends State<CourseContent> {
  ////////////////////////////////////////////////////////////
  String? taskId; // Store taskId as a class member
  String userRole = '';
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    // Initialize FlutterDownloader
    // Register the SendPort to communicate with the background isolate
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    // Listen for data from the background isolate
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      if (taskId == id) {
        // Update UI or state based on download progress
        print('Download status: $status, Progress: $progress%');
        setState(() {
          // Update your state here if needed
        });
      }
    });

    // Register the static callback
    FlutterDownloader.registerCallback(downloadCallback);

    userRole = Hive.box('userBox').get('role') ?? 'student';
    // Other initialization code...
    getcources();
  }

  @override
  void dispose() {
    // Unregister the SendPort
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
    super.dispose();
  }

  // The callback function must be static and match the expected signature
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void _downloadPdf(String subject) async {
    final url = subjectLinks[subject];

    if (url != null) {
      // Request storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) {
        // Get the external storage directory
        final externalDir = await getExternalStorageDirectory();

        // Enqueue the download task
        taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir!.path,
          fileName: '$subject.pdf',
          showNotification:
              true, // Show download progress in status bar (for Android)
          openFileFromNotification:
              true, // Click on notification to open downloaded file (for Android)
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$subject download started.')),
        );
      } else {
        // Handle permission denial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } else {
      print('No URL available for this subject.');
    }
  }

  ////////////////////////////////////////////////////////////
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
  List<String> listFromR = [];
  List<String> Rnames = [];
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
    } else {
      Mcat = 'R';
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

  // Future<void> getcources() async {
  //   const url = 'https://alyibrahim.pythonanywhere.com/CourseContent';
  //   print('srsdkajsdfk$courseIndex');
  //   final Map<String, dynamic> requestBody = {
  //     'courseIdx': Hive.box('userBox').get('COId'),
  //     'username': Hive.box('userBox').get('username'),
  //   };
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(requestBody),
  //   );

  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body);
  //     print("print the json: $jsonResponse");
  //     print("print the json: $courseIndex");
  //     setState(() {
  //       jsonResponse['subInfo'].forEach((resource) {
  //         String category = resource['RCat'];
  //         if (!categorizedList.containsKey(category)) {
  //           categorizedList[category] = [];
  //         }
  //         categorizedList[category]
  //             ?.add('${resource['RName']}: ${resource['RFileURL']}');
  //         subjectIds[resource['RName']] = resource['RId'];
  //       });

  //       print(categorizedList);
  //       if (categorizedList['L'] == null) {
  //         categorizedList['L'] = [];
  //       }
  //       if (categorizedList['Su'] == null) {
  //         categorizedList['Su'] = [];
  //       }
  //       if (categorizedList['Q'] == null) {
  //         categorizedList['Q'] = [];
  //       }
  //       if (categorizedList['Se'] == null) {
  //         categorizedList['Se'] = [];
  //       }
  //       if (categorizedList['R'] == null) {
  //         categorizedList['R'] = [];
  //       }
  //       listFromL = categorizedList['L']!;
  //       listFromSU = categorizedList['Su']!;
  //       listFromQ = categorizedList['Q']!;
  //       listFromSE = categorizedList['Se']!;
  //       listFromR = categorizedList['R']!;
  //       lnames = listFromL.map((e) => e.split(':')[0]).toList();
  //       SEnames = listFromSE.map((e) => e.split(':')[0]).toList();
  //       SUnames = listFromSU.map((e) => e.split(':')[0]).toList();
  //       Qnames = listFromQ.map((e) => e.split(':')[0]).toList();
  //       Rnames = listFromR.map((e) => e.split(':')[0]).toList();

  //       categorizedList.forEach((category, subjects) {
  //         for (var subject in subjects) {
  //           var index = subject.indexOf(': ');
  //           if (index != -1) {
  //             var subjectName = subject.substring(0, index);
  //             var link = subject.substring(index + 2);
  //             subjectLinks[subjectName] = link;
  //           }
  //         }
  //       });
  //     });
  //   } else {
  //     print('Request failed with status: ${response.body}.');
  //   }
  // }

Future<void> getcources() async {
  const url = 'https://alyibrahim.pythonanywhere.com/CourseContent';
  print('srsdkajsdfk$courseIndex');
  final Map<String, dynamic> requestBody = {
    'courseIdx': Hive.box('userBox').get('COId'),
    'username': Hive.box('userBox').get('username'),
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
      // --- Composite pattern START ---
      // Initialize category composites
      final Map<String, ResourceComposite> categoryComposites = {
        'L': ResourceComposite('Lectures'),
        'Su': ResourceComposite('Summaries'),
        'Q': ResourceComposite('Quizzes'),
        'Se': ResourceComposite('Sections'),
        'R': ResourceComposite('Resources')
      };
      subjectIds.clear();
      subjectLinks.clear();

      // Fill composites
      jsonResponse['subInfo'].forEach((resource) {
        String category = resource['RCat'];
        String name = resource['RName'];
        String url = resource['RFileURL'];

        categoryComposites.putIfAbsent(category, () => ResourceComposite(category));
        categoryComposites[category]?.add(ResourceLeaf(name, url));
        subjectIds[name] = resource['RId'];
        subjectLinks[name] = url;
      });

      // --- For UI: get lists of names as before ---
      lnames = categoryComposites['L']?.children.map((e) => e.name).toList() ?? [];
      SEnames = categoryComposites['Se']?.children.map((e) => e.name).toList() ?? [];
      SUnames = categoryComposites['Su']?.children.map((e) => e.name).toList() ?? [];
      Qnames = categoryComposites['Q']?.children.map((e) => e.name).toList() ?? [];
      Rnames = categoryComposites['R']?.children.map((e) => e.name).toList() ?? [];

      // --- For UI: get lists of ResourceLeaf objects (optional) ---
      listFromL = categoryComposites['L']?.children.map((e) => (e as ResourceLeaf).name).toList() ?? [];
      listFromSE = categoryComposites['Se']?.children.map((e) => (e as ResourceLeaf).name).toList() ?? [];
      listFromSU = categoryComposites['Su']?.children.map((e) => (e as ResourceLeaf).name).toList() ?? [];
      listFromQ = categoryComposites['Q']?.children.map((e) => (e as ResourceLeaf).name).toList() ?? [];
      listFromR = categoryComposites['R']?.children.map((e) => (e as ResourceLeaf).name).toList() ?? [];
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

  Future<void> addMaterial(String Rurl, String Title, String Mcat, String subid) async {
    const url = 'https://alyibrahim.pythonanywhere.com/addMaterial';
    if (Mcat == 'Lectures') {
      Mcat = 'L';
    } else if (Mcat == 'Sections') {
      Mcat = 'Se';
    } else if (Mcat == 'Summaries') {
      Mcat = 'Su';
    } else if (Mcat == 'Quizzes') {
      Mcat = 'Q';
    } else {
      Mcat = 'R';
    }
    print(Mcat);
    final Map<String, dynamic> requestBody = {
      'materialUrl': Rurl,
      'materialTitle': Title,
      'materialMcat': Mcat,
      'subid': subid,
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

  // @override
  // void initState() {
  //   super.initState();
  //   getcources();
  // }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    // courseName = args?['courseId'];
    // courseIndex = args?['courseIndex'];

    return Scaffold(
      appBar: AppBar(
      backgroundColor: Color(0xFF165d96),

        title: Center(
          child: Text(
            'Course Content',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
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
            _buildTermDropdownLinks('Resources', Rnames),
            if (userRole == 'moderator') // Add this condition
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
              const Icon(Icons.my_library_books,
                  color: Color.fromARGB(255, 104, 110, 114)),
              const SizedBox(width: 15),
              Text(
                term,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          children: subjects.map((subject) {
            return ListTile(
              leading: const Icon(Icons.book),
              title: Text(subject),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download icon
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () => _downloadPdf(subject),
                  ),
                  if (userRole == 'moderator') // Add this condition
                    // Edit icon
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _showEditPopup(context, subject),
                    ),
                ],
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
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTermDropdownLinks(String term, List<String> subjects) {
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
              const Icon(Icons.my_library_books,
                  color: Color.fromARGB(255, 104, 110, 114)),
              const SizedBox(width: 15),
              Text(
                term,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          children: subjects.map((subject) {
            return ListTile(
              leading: const Icon(Icons.book),
              title: Text(subject),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userRole == 'moderator') // Add this condition
                    // Edit icon
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _showEditPopup(context, subject),
                    ),
                ],
              ),
              onTap: () {
                final link = subjectLinks[subject];
                if (link != null) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => UrlLauncherPage(url: link),
                  //   ),
                  // );
                } else {
                  print('No link found for $subject');
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditPopup(BuildContext context, String subject) {
    // Initialize controllers and variables
    final TextEditingController titleController =
        TextEditingController(text: subject);
    String? selectedCategory; // Nullable to avoid mismatch
    final List<String> categories = [
      "Resources",
      "Lectures",
      "Sections",
      "Summaries",
      "Quizzes"
    ];

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
                    subject,
                    style: const TextStyle(fontSize: 18),
                    overflow:
                        TextOverflow.ellipsis, // Truncate text if it overflows
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
                    print('Title: ${titleController.text}');
                    deleteMaterial(subjectIds[subject]!);
                    print('$selectedCategory');
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory == null ||
                        selectedCategory == "Select Category") {
                      // Show error if no valid category is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a valid category.')),
                      );
                      return;
                    }
                    print('Title: ${titleController.text}');
                    updateMaterial(subjectIds[subject]!, titleController.text,
                        selectedCategory!);
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
    final List<String> categories = [
      "Resources",
      "Lectures",
      "Sections",
      "Summaries",
      "Quizzes"
    ];

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
                // Add the new material
                print('Title: ${titleController.text}');
                print('Category: $selectedCategory');
                print('URL: ${urlController.text}');

                addMaterial(
                  urlController.text,
                  titleController.text,
                  selectedCategory!,
                  Hive.box('userBox').get('COId'),
                );
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
