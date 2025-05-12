import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class Materialcourses extends StatefulWidget {
  const Materialcourses({super.key});

  @override
  State<Materialcourses> createState() => _MaterialcoursesState();
}

class _MaterialcoursesState extends State<Materialcourses> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        final String link = args['link']; // Get the course ID
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Courses'),
      ),
      body: FutureBuilder(
        future: _loadPdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const PDF().cachedFromUrl(
              link,
              placeholder: (progress) => Center(child: Text('$progress %')),
              errorWidget: (error) => const Center(child: Text('Error loading PDF')),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadPdf() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      print('Error loading PDF: $e');
      rethrow;
    }
  }
}