import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Classes/User.dart';
import '../pages/HomePage/HomePage.dart';
import '../pages/LoginPage.dart';

class DonePopUp extends StatefulWidget {
  final String? title;
  final String? description;
  final Color? color;
  final Color? textColor;
  final String? icon;
  final String? routeName;
  Student? user = Student();

  DonePopUp({
    super.key,
    this.title,
    this.description,
    this.color,
    this.textColor,
    this.icon,
    this.routeName,
    this.user,
  });

  @override
  State<DonePopUp> createState() => _DonePopUpState();
}

class _DonePopUpState extends State<DonePopUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularWidget(
            title: widget.title ?? 'Default Title',
            description: widget.description ?? 'Default Description',
            color: widget.color ?? Color(0xff3BBD5E),
            textColor: widget.textColor ?? Colors.black,
            routeName: widget.routeName ?? "/HomePage",
            user: widget.user,
          ),
        ),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final Color textColor;
  final String routeName;
  Student? user;
  CircularWidget({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
    required this.routeName,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // This will follow the app theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            // Lottie animation
            Lottie.asset(
              'lib/assets/animations/SuccesAnimation.json',
              height: 375,
              width: 375,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 40), // Space between animation and title
            // Dynamic title text
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Space between title and description
            // Dynamic description text
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30), // Space between text and button
            // Elevated Button for "Done"
            ElevatedButton(
              onPressed: () {
                // Close the app or perform another action
                if (routeName == "/HomePage") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => routeName == "/HomePage"
                          ? Homepage(student: user)
                          : LoginPage(),
                    ),
                  );
                } else {
                  Navigator.pushReplacementNamed(context, routeName, arguments: routeName);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color, // Button color
                minimumSize: Size(320, 60),
              ),
              child: Text(
                "Done",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
