import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/RegisterPage.dart';
import '../Classes/User.dart';
import '../util/TextField.dart';
import 'CollageInformatio.dart';

class RegisterLogin extends StatefulWidget {
    User? user;
    RegisterLogin({super.key,
    this.user,
    });

  @override
  State<RegisterLogin> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<RegisterLogin> {
  final UsernameController = TextEditingController();
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();
  final ConfirmPasswordController = TextEditingController();
  final GenderController = TextEditingController();

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
                    Text('Personal information',
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
                            controller: EmailController, hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: Icon(Icons.email),
                            )),
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                          controller: UsernameController,
                          hintText: 'Username',
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                          controller: PasswordController,
                          hintText: 'Password',
                          obscureText: true,
                          toggleVisability: false,
                        )),
                        SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                        width: 375,
                        child: Textfield(
                            controller: ConfirmPasswordController,
                            hintText: 'Confirm Password',
                            obscureText: true,
                            toggleVisability: false)),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 375,
                            child: Text('Gender :',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  textBaseline: TextBaseline.alphabetic,
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 180,
                                child: SizedBox(
                                  width: 180,
                                  child: Row(
                                    children: [
                                      Radio(
                                        value: 'Male',
                                        groupValue: GenderController.text,
                                        onChanged: (value) {
                                          setState(() {
                                            GenderController.text =
                                                value.toString();
                                          });
                                        },
                                      ),
                                      Text('Male'),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: 180,
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'Female',
                                      groupValue: GenderController.text,
                                      onChanged: (value) {
                                        setState(() {
                                          GenderController.text =
                                              value.toString();
                                        });
                                      },
                                    ),
                                    Text('Female'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.user?.username = UsernameController.text;
                        widget.user?.email = EmailController.text;
                        widget.user?.password = PasswordController.text;
                        widget.user?.gender = GenderController.text;
                        // Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(
                              user: widget.user,
                            ),
                          ),
                        );
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
                        // Navigator.pop(context);
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