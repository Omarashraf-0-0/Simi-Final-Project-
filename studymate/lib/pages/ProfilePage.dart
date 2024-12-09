// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/ProfileSettings.dart';
import '../Classes/User.dart';

class Profilepage extends StatefulWidget {
  User? user;
   Profilepage({super.key,this.user});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {

  @override
  Widget build(BuildContext context) {
    print("XP : ${widget.user?.xp}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF01D7ED)), 
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
              color: Color(0xFF01D7ED),
              size: 25,

              ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettings()),
              );
            }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
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
                      "${widget.user?.title}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                        color: Color(0xFFB20000)
                      ),
                    ),
                    // SizedBox(height: 1),
                    Text(
                        "${widget.user?.fullName}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                        
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      "${widget.user?.level}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                        color: Color(0xFFB20000)
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                        height: 10,
                        width: MediaQuery.of(context).size.width * 0.3,  // 80% of the screen width
                        child:
                        LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(5),
                          value: (widget.user?.xp ?? 0)*0.1,
                          backgroundColor: Color(0xFF01D7ED),  // Background color
                          color: Color(0xFFB20000),  // Progress color
                        )
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 35,
                    width: 35,
                    color: Color(0xFFE0F6FC),
                    child: Icon(
                      Ionicons.flash,
                      color: Color(0xFF01D7ED),
                      size: 25,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                    Text(
                      'Day Streak',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF767676),
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 35,
                    width: 35,
                    color: Color(0xFFFDF1CB),
                    child: Icon(
                      Ionicons.medal,
                      color: Color(0xFFFDD539),
                      size: 25,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                    Text(
                      'Top 5 Finishes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF767676),
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                  ],
                ),
              SizedBox(width: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 35,
                    width: 35,
                    color: Color(0xFFF1D6FC),
                    child: Icon(
                      Ionicons.star,
                      color: Color(0xFFC174FA),
                      size: 25,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'x6',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                    Text(
                      'Gems',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF767676),
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
              ),
            ),
            SizedBox(height: 5),

            Text(
              'Email',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
              "${widget.user?.email}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.phoneNumber}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Registration Number',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.registrationNumber}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 10),
            Text(
              'College Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'University',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.university}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 3),
            Text(
              'College',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.collage}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Major',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.major}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 3),
            Text(
                'Term Level',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
            Text(
                "${widget.user?.term_level}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 10),
            Text(
              "${widget.user?.registrationNumber}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Data Structures and Algorithms - Software Requirments and Specification',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                color: Color(0xFF1BC0C4)
              ),
            ),
            SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}