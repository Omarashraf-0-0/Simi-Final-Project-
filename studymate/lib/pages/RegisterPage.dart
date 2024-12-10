// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studymate/pages/LoginPage.dart';
import '../Classes/User.dart';
import '../Pop-ups/PopUps_Warning.dart';
import '../util/TextField.dart';
import 'CollageInformatio.dart';

class RegisterPage extends StatefulWidget {
    User? user;
    RegisterPage({
      super.key,
      this.user,
    });
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FullNameController = TextEditingController();
  final UsernameController = TextEditingController();
  final PhoneController = TextEditingController();
  final AddressController = TextEditingController();
  final BirthDateController = TextEditingController();
  // final User user = User();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // add a back button arrow to the left with a circular outlayer
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Etfadal Ma3anaa',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                          controller: FullNameController,
                          hintText: 'Full name',
                          suffixIcon: Icon(Icons.person),
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      width: 375,
                      child: Textfield(
                          controller: PhoneController,
                          hintText: 'Phone number',
                          suffixIcon: Icon(Icons.phone))),
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                            controller: BirthDateController,
                            hintText: 'Date of Birth',
                            isDateField: true,
                            suffixIcon: Icon(Icons.calendar_today)
                            )),
                            SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                          controller: AddressController,
                          hintText: 'Address',
                          suffixIcon: Icon(Icons.home),
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String fullName = FullNameController.text;
          
                        String phoneNumber = PhoneController.text;
                        String address = AddressController.text;
                        String dateOfBirth = BirthDateController.text; // Assuming you have a DateOfBirthController

                        if (fullName.isEmpty || phoneNumber.isEmpty || address.isEmpty || dateOfBirth.isEmpty) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('Please fill in all fields.')),
                          // );
                          showWarningPopup(context, 'Please fill in all fields.','', 'OK');
                        } else if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(phoneNumber)) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('Phone number must be 11 digits and start with 010, 011, 012, or 015.')),
                          // );
                          showWarningPopup(context, 'Phone number must be 11 digits and start with 010, 011, 012, or 015.','', 'OK');
                        } else {
                          DateTime dob;
                          try {
                            dob = DateTime.parse(dateOfBirth);
                            if (dob.isAfter(DateTime.now())) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(content: Text('Date of birth must be in the past.')),
                              // );
                              showWarningPopup(context, 'Date of birth must be in the past.', 'OK');
                            } else {
                              widget.user?.fullName = fullName;
                              widget.user?.phoneNumber = phoneNumber;
                              widget.user?.role = 'student';
                              widget.user?.address = address;
                              widget.user?.birthDate = dateOfBirth; // Assuming you have a dateOfBirth field in user
                              // showWarningPopup(context, 'user info', '${widget.user?.fullName} ${widget.user?.phoneNumber} ${widget.user?.role} ${widget.user?.address} ${widget.user?.birthDate}', 'OK');
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CollageInformation(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Invalid date of birth format.')),
                            // );
                            showWarningPopup(context, 'Invalid date of birth format.', 'OK');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                        // add color #165D96 to the background
                        backgroundColor: Color(0xff165D96),
                        // rounded corners remove
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Column(
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 5),
                        // add color #165D96 to the background
                        backgroundColor: Color(0xff165D96),
                        // rounded corners remove
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
