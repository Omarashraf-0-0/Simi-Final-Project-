import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class Materialcourses extends StatefulWidget {
  @override
  State<Materialcourses> createState() => _MaterialcoursesState();
}

class _MaterialcoursesState extends State<Materialcourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Courses'),
      ),
      body: FutureBuilder(
        future: _loadPdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return PDF().cachedFromUrl(
              'https://www.dropbox.com/scl/fi/2gll149sd0368gdafa5zw/Lect-3.pdf?rlkey=1fiaiq706ty1pxjdw8zzt5sz1&st=3zooguvb&dl=1',
              placeholder: (progress) => Center(child: Text('$progress %')),
              errorWidget: (error) => Center(child: Text('Error loading PDF')),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadPdf() async {
    try {
      await Future.delayed(Duration(seconds: 5));
    } catch (e) {
      print('Error loading PDF: $e');
      throw e;
    }
  }
}