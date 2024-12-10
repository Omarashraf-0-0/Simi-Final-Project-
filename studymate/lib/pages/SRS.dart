import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class SRS extends StatefulWidget {
  const SRS({super.key});

  @override
  State<SRS> createState() => _SRSState();
}

class _SRSState extends State<SRS> {
  String? selectedOption; // Store selected option from the dropdown

  final Map<String, String> pdfUrls = {
    'Quizzes': 'https://www.dropbox.com/scl/fi/z7z2rr3nb7wy4de9praza/Quiz-2.pdf?rlkey=fts7dfjhguhd1uf0zc11pe7je&st=3z4ki6eh&dl=1',
    'Lectures': 'https://www.dropbox.com/scl/fi/2gll149sd0368gdafa5zw/Lect-3.pdf?rlkey=1fiaiq706ty1pxjdw8zzt5sz1&st=3zooguvb&dl=1',
    'Sections': 'https://www.dropbox.com/scl/fi/vn92qc7uodwd93um78wxj/Sec1-SRS.pptx?rlkey=2gq2qkim9flidvh1dqxa808qy&st=7pkb2dvd&dl=1',
    'Summarizes': 'https://www.dropbox.com/scl/fi/023y1nmgaety34197rcep/srsdiagrams.pdf?rlkey=4b4vmdw0q4innmkwq4mh1wmc4&st=y6n29cf9&dl=1',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Resources'),
      ),
      body: Column(
        children: [
          Center(
            child: DropdownButton<String>(
              value: selectedOption,
              hint: const Text('Select Category'),
              items: pdfUrls.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue;
                });
              },
            ),
          ),
          if (selectedOption != null) ...[
            Expanded(
              child: MaterialCourses(pdfUrl: pdfUrls[selectedOption]!),
            ),
          ],
        ],
      ),
    );
  }
}

class MaterialCourses extends StatelessWidget {
  final String pdfUrl;

  const MaterialCourses({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPdf(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading PDF'));
        } else {
          return PDF().cachedFromUrl(
            pdfUrl,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => const Center(child: Text('Error loading PDF')),
          );
        }
      },
    );
  }

  Future<void> _loadPdf() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      print('Error loading PDF: $e');
      throw e;
    }
  }
}
