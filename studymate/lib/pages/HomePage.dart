// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
// import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  String? name;
  Homepage({
    super.key,
    this.name,
    });
  
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Center(child: Text('Home Page')),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              size: 36,
            ),
            onPressed: () {
              // Code to open the drawer or any other action
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // Profile picture
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('lib/assets/img/pfp.jpg')),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(46, 58, 89, 1.0), // using RGBO where 1.0 represents full opacity
              ),
              child: Row(
                children: [
                  // app logo
                  Image.asset('lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                      height: 60, width: 60,
                      color: Colors.white),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Study Mate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the Home tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the Settings tap
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/img/ai_icon.png', width: 24) ,
              title: Text('Abo Lyla'),
              onTap: () {
                // Handle the Abo Lyla tap

              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Handle the Help tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle the Logout tap
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ${widget.name}!',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              'Have a nice day.',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(46, 58, 89, 0.5), // using RGBO where 1.0 represents full opacity
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 20,
            ),
            
          ],
        ),
      ),
    );
  }
}
