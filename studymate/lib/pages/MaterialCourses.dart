// import 'package:flutter/material.dart';
// // import 'package:url_launcher/url_launcher.dart';

// class Materialcourses extends StatefulWidget {
//   const Materialcourses({super.key});

//   @override
//   _MaterialcoursesState createState() => _MaterialcoursesState();
// }

// class _MaterialcoursesState extends State<Materialcourses> {
//   // Function to open a PDF URL


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//   //     appBar: AppBar(
//   //       title: const Text(
//   //         'Courses',
//   //         style: TextStyle(color: Colors.black),
//   //       ),
//   //     ),
//   //     body: Padding(
//   //       padding: const EdgeInsets.all(8.0),
//   //       child: ListView(
//   //         children: [
//   //           _buildTermDropdown('Lectures', [
//   //             'https://docs.google.com/presentation/d/1eTigDY1YfC8RlKfD13EaRECf0Ou0yT2v/edit?usp=drive_link&ouid=112621359805334751051&rtpof=true&sd=true',
//   //           ]),
//   //           _buildTermDropdown('Sections', []),
//   //           _buildTermDropdown('Summaries', []),
//   //           _buildTermDropdown('Resources', []),
//   //           _buildTermDropdown('Quizzes', []),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildTermDropdown(String term, List<String> subjects) {
//   //   return Padding(
//   //     padding: const EdgeInsets.all(16.0),
//   //     child: Container(
//   //       decoration: BoxDecoration(
//   //         border: Border.all(color: Colors.grey),
//   //         borderRadius: BorderRadius.circular(8),
//   //       ),
//   //       child: ExpansionTile(
//   //         title: Row(
//   //           children: [
//   //             const Icon(Icons.my_library_books, color: Color.fromARGB(255, 104, 110, 114)),
//   //             const SizedBox(width: 15),
//   //             Text(
//   //               term,
//   //               style: const TextStyle(fontSize: 18),
//   //             ),
//   //           ],
//   //         ),
//   //         children: subjects
//   //             .map(
//   //               (subject) => ListTile(
//   //                 leading: const Icon(
//   //                   Icons.picture_as_pdf,
//   //                   color: Colors.red,
//   //                 ),
//   //                 title: Text(subject),
//   //                 onTap: () {
//   //                   _openPdf(subject); // Open the PDF URL
//   //                 },
//   //               ),
//   //             )
//   //             .toList(),
//   //       ),
//   //     ),
//     );
//   }
// }
