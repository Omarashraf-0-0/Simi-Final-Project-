// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/Classes/User.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Logo scale animation
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _logoController.forward();
    _fadeController.forward();

    Future.delayed(Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void checkLoginStatus() {
    if (!isLoggedIn()) {
      context.go(AppRoutes.login);
    } else {
      Student user = Student();
      user.fullName = Hive.box('userBox').get('fullName');
      user.email = Hive.box('userBox').get('email');
      user.password = Hive.box('userBox').get('password');
      context.go(AppRoutes.home, extra: {'student': user});
    }
  }

  bool isLoggedIn() {
    Box userBox = Hive.box('userBox');
    bool loggedIn = userBox.get('isLoggedIn', defaultValue: false);

    if (loggedIn) {
      int loginTime = userBox.get('loginTime', defaultValue: 0);
      DateTime loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      Duration durationSinceLogin = DateTime.now().difference(loginDateTime);

      // Check if the session has expired (30 minutes)
      if (durationSinceLogin.inMinutes > 30) {
        logout();
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    Box userBox = Hive.box('userBox');
    await userBox.put('isLoggedIn', false);
    await userBox.put('loginTime', 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1c74bb), // Primary Blue
              Color(0xFF165d96), // Primary Blue Dark
              Color(0xFF18bebc), // Primary Cyan
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.3,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with scale animation
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // App title
                    Text(
                      'El Batal',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Study Mate',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 60),

                    // Loading indicator
                    RotationTransition(
                      turns: _loadingAnimation,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Loading text
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom decorative line
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your Study Partner',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
