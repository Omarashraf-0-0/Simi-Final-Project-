// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../Classes/User.dart';
import 'package:hive/hive.dart';

import '../Classes/User.dart';
import '../Pop-ups/SuccesPopUp.dart';
import '../util/TextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 encoding
import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart'; // For Hive operations
import '../Pop-ups/PopUps_Success.dart';
import './UserUpdater.dart';

class Profilepage extends StatefulWidget {
  User? user;
  File? _imageFile;
  Profilepage({super.key,this.user});


  Future<bool> fetchAndSaveProfileImage() async {
    final url = 'https://alyibrahim.pythonanywhere.com/get-profile-image'; // Replace with your server URL

// Get the username from Hive box
    final username = Hive.box('userBox').get('username');
    print(">>>>>>>>> $username");

// Create a map with the username
    final Map<String, String> body = {
      'username': username,
    };

// Send the username as JSON in the body of a POST request
    final response = await http
        .post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, // Set content type to JSON
      body: jsonEncode(body), // Encode the body as JSON
    )
        .timeout(
      Duration(seconds: 30), // Adjust the duration as needed
    );
    if (response.statusCode == 200) {
      // Get the image bytes from the response
      final bytes = response.bodyBytes;

      // Get the device's temporary directory to save the image
      final directory = await getTemporaryDirectory();

      // Create a unique file name based on username and extension
      final imagePath = '${directory.path}/${Hive.box('userBox').get('username')}_profile.jpg';

      // Create a file and write the bytes to it
      _imageFile = File(imagePath)..writeAsBytesSync(bytes);

      print(">>>>>>>>>> Done <<<<<<<<");
      // Update the UI to display the image
      return true;
    } else {
      // Handle error if the image is not found or another error occurs
      print("Failed to load image: ${response.statusCode} ===== ${response.body}");
      return false;
    }
  }





  @override
  State<Profilepage> createState() => _ProfilepageState();

}



class _ProfilepageState extends State<Profilepage> {

  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch the profile image when the page is initialized
    widget.fetchAndSaveProfileImage().then((result) {
      setState(() {
        _isImageLoading = false; // Set loading to false once the image is fetched
      });
    });
  }


  @override
  Widget build(BuildContext context) {

     // To hold the selected image file
    final ImagePicker _picker = ImagePicker();


    Future<void> saveProfileImageToHive(File imageFile) async {
      try {
        // Read the image as bytes
        final bytes = await imageFile.readAsBytes();

        // Convert bytes to Base64 string
        final base64String = base64Encode(bytes);

        // Store the Base64 string in Hive
        await Hive.box('userBox').put('profileImageBase64', base64String);

        print('Profile image saved successfully!');
      } catch (e) {
        print('Error saving profile image: $e');
      }finally{
        setState(() {});
      }
    }



    Future<void> uploadImageToServer(File imageFile, String serverUrl, String username) async {
      try {
        // Create a multipart request
        var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

        // Attach the file
        request.files.add(await http.MultipartFile.fromPath(
          'image', // The key to match on the Flask server
          imageFile.path,
        ));

        // Add other fields if needed
        request.fields['username'] = username;

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          print('Image uploaded successfully!');
          // Optional: Decode and use the response from the server
          var responseBody = await response.stream.bytesToString();
          print('Server Response: $responseBody');
          saveProfileImageToHive(imageFile);
        } else {
          print('Failed to upload image. Status code: ${response.statusCode}');
          print('Response: ${await response.stream.bytesToString()}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    

    // Function to pick an image
    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          uploadImageToServer(File(pickedFile.path), 'https://alyibrahim.pythonanywhere.com/upload-image',
              Hive.box('userBox').get('username'));
        });
      }
    }

    print("XP : ${widget.user?.xp}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF01D7ED)),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        title: Center(child: Text('Profile Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // backgroundColor: Colors.black,
          ),
        ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          // backgroundColor: Colors.black,
        ),
        // actions: [
        //   IconButton(
        //       icon: Icon(
        //         Ionicons.settings_outline,
        //         color: Color(0xFF01D7ED),
        //         size: 25,

        //       ),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => ProfileSettings()),
        //         );
        //       }
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    if (Hive.box('userBox').get('profileImageBase64')==null)
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey, // Placeholder color
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01D7ED)), // Change spinner color here
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: MemoryImage(base64Decode(Hive.box('userBox').get('profileImageBase64')))),
                    Positioned(
                      bottom: 0, // Position button slightly outside the avatar
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Hive.box('userBox').get('title'),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: Color(0xFFB20000)
                      ),
                    ),
                    // SizedBox(height: 1),
                    Text(
                        Hive.box('userBox').get('fullName'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.leagueSpartan().fontFamily,

                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      "${Hive.box('userBox').get('level')}",
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
                          value: Hive.box('userBox').get('xp')*0.1,
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              //  fontSize: 24,
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
              "${Hive.box('userBox').get('email')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                 // fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                 // color: Color.fromARGB(255, 0, 0, 0)
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
              "${Hive.box('userBox').get('phone_number')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                 // fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                //color: Color.fromARGB(255, 0, 0, 0)
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
              "${Hive.box('userBox').get('Registration_Number')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                //  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                //  color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 10),
            Text(
              'College Information',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
               // fontSize: 24,
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
              "${Hive.box('userBox').get('university')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                 // fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                 // color: Color.fromARGB(255, 0, 0, 0)
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
              "${Hive.box('userBox').get('college')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                //  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                 // color: Color.fromARGB(255, 0, 0, 0)
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
              "${Hive.box('userBox').get('major')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  //fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                 // color: Color.fromARGB(255, 0, 0, 0)
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
              "${Hive.box('userBox').get('term_level')}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                //  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                //  color: Color.fromARGB(255, 0, 0, 0)
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Courses",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                //fontSize: 24,
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