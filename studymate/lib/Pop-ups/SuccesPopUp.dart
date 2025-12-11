import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Classes/User.dart';
import '../pages/HomePage/HomePage.dart';
import '../pages/LoginPage.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class DonePopUp extends StatefulWidget {
  final String? title;
  final String? description;
  final Color? color;
  final Color? textColor;
  final String? icon;
  final String? routeName;
  final Student? user;

  const DonePopUp({
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CircularWidget(
        title: widget.title ?? 'Default Title',
        description: widget.description ?? 'Default Description',
        color: widget.color ?? Color(0xff3BBD5E),
        textColor: widget.textColor ?? Colors.black,
        routeName: widget.routeName ?? "/HomePage",
        user: widget.user,
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
  final Student? user;
  const CircularWidget({
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Lottie.asset(
            'assets/animations/SuccesAnimation.json',
            height: 200,
            width: 200,
            fit: BoxFit.fill,
          ),
          SizedBox(height: 20),
          // Dynamic title text
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          // Dynamic description text
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25),
          // Elevated Button for "Done"
          ElevatedButton(
            onPressed: () {
              // Close dialog first
              Navigator.of(context).pop();
              // Navigate using GoRouter
              if (routeName == "/HomePage" || routeName == "/home") {
                context.go(AppRoutes.home);
              } else if (routeName == "/login") {
                context.go(AppRoutes.login);
              } else {
                // Default to home if unknown route
                context.go(AppRoutes.home);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: Size(280, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Done",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
