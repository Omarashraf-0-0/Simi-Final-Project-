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
    return Container(
      constraints: BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gradient
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Lottie.asset(
                'assets/animations/SuccesAnimation.json',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              children: [
                // Dynamic title text
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14),
                // Dynamic description text
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                // Modern gradient button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
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
                      child: Center(
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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
