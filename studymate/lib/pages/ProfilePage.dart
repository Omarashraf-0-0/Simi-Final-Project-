// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded), 
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        title: Center(child: Text('Profile Page')),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          // backgroundColor: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.settings_outline,
              color: Colors.blue,
              size: 25,

              ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('lib/assets/img/pfp.jpg'),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                    // SizedBox(height: 10),
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                        
                      ),
                    ),
                    // SizedBox(height: 10),
                    Text(
                      'Level',
                      style: TextStyle(
                        fontSize: 12,
                        // fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                    
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}