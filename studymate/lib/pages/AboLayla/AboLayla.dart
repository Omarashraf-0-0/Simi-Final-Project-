import 'package:flutter/material.dart';
import 'package:studymate/pages/AboLayla/AboLaylaCourses.dart';

class AboLayla extends StatelessWidget {
  const AboLayla({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF165D96);
    const String fontFamily = 'League Spartan';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Abo Layla',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/AboLayla.jpg'),
              const SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 30,
                        fontFamily: fontFamily,
                      ),
                  children: [
                    const TextSpan(text: 'Hello, I am\n'),
                    const TextSpan(
                      text: 'Abo Layla',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start chatting with me now. You can ask me anything related to your course.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: fontFamily,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboLaylaCourses()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Start Chat',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: fontFamily,
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