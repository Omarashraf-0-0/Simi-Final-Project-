import 'package:flutter/material.dart';
import 'package:studymate/pages/Settings/UserSettings.dart';
import 'package:studymate/pages/Game/GameRanks.dart';
import 'package:studymate/pages/Settings/Universitysettings.dart';
import 'package:studymate/pages/Settings/RCoursesSettings.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Game Home',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background with text on the side
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 0, 25, 45),
                  Color(0xFF30457A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'El Batal Game',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // filepath: /d:/Mobile Application/Simi-Final-Project-/studymate/lib/pages/Game/GameHome.dart
                const Text(
                  'Welcome To El Batal Gamifications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFb3141c),
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Placeholder for character image
                Container(
                  width: 350,
                  height: 550,
                  child: Image.asset(
                    'lib/assets/img/GameCharacters/ElBatal.png',
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameRanks()),
                );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFb3141c),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 110, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
