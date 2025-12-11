import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/intro_page.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/Login%20&%20Register/Register_login.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/ProfilePage.dart';
import 'package:studymate/pages/Settings/Settings.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/Resuorces/Courses.dart';
import 'package:studymate/pages/Resuorces/MaterialCourses.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Career/CareerHome.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/Game/GameHome.dart';
import 'package:studymate/pages/Game/GameLeaderBoard.dart';
import 'package:studymate/pages/AboLayla/AboLayla.dart';
import 'package:studymate/pages/Notifications/Notification.dart';
import 'package:studymate/pages/Settings/NotificationSettingsPage.dart';
import 'package:studymate/pages/Performance/PerformanceHome.dart';
import 'package:studymate/pages/Login%20&%20Register/Forget_Pass.dart';
import 'package:studymate/pages/OTP.dart';
import 'package:studymate/pages/CollageInformatio.dart';

/// Route names for easy reference throughout the app
class AppRoutes {
  // Auth routes
  static const intro = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const collegeInfo = '/college-info';

  // Main app routes
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const schedule = '/schedule';
  static const resources = '/resources';
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const performance = '/performance';

  // Resources routes
  static const courses = '/courses';
  static const materialCourses = '/material-courses';
  static const courseContent = '/course-content';
  static const srs = '/srs';

  // Feature routes
  static const career = '/career';
  static const quiz = '/quiz';
  static const game = '/game';
  static const leaderboard = '/leaderboard';
  static const aboLayla = '/abolayla';
}

/// Global navigator key for navigation without context
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: AppRoutes.intro,
  
  // Redirect logic for authentication
  redirect: (BuildContext context, GoRouterState state) {
    final userBox = Hive.box('userBox');
    final isLoggedIn = userBox.get('username') != null;
    final isOnAuthPage = state.matchedLocation == AppRoutes.intro ||
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register ||
        state.matchedLocation == AppRoutes.forgotPassword ||
        state.matchedLocation == AppRoutes.otp ||
        state.matchedLocation == AppRoutes.collegeInfo;

    // If not logged in and trying to access protected routes
    if (!isLoggedIn && !isOnAuthPage) {
      return AppRoutes.login;
    }

    // If logged in and trying to access auth pages, redirect to home
    if (isLoggedIn && isOnAuthPage && state.matchedLocation != AppRoutes.intro) {
      return AppRoutes.home;
    }

    return null; // No redirect needed
  },

  // Error page
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('Could not find route: ${state.matchedLocation}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),

  routes: [
    // Auth Routes
    GoRoute(
      path: AppRoutes.intro,
      name: 'intro',
      builder: (context, state) => const IntroPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => RegisterLogin(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => ForgetPass(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OTP(user: extra?['user']);
      },
    ),
    GoRoute(
      path: AppRoutes.collegeInfo,
      name: 'collegeInfo',
      builder: (context, state) => CollageInformation(),
    ),

    // Main App Routes
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return Homepage(student: extra?['student']);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => Profilepage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => Settings(),
    ),
    GoRoute(
      path: AppRoutes.schedule,
      name: 'schedule',
      builder: (context, state) => ScheduleView(),
    ),
    GoRoute(
      path: AppRoutes.resources,
      name: 'resources',
      builder: (context, state) => Resources(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return NotificationPage(notifications: extra?['notifications'] ?? []);
      },
    ),
    GoRoute(
      path: AppRoutes.notificationSettings,
      name: 'notificationSettings',
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.performance,
      name: 'performance',
      builder: (context, state) => InsightsPage(),
    ),

    // Resources Routes
    GoRoute(
      path: AppRoutes.courses,
      name: 'courses',
      builder: (context, state) => Courses(),
    ),
    GoRoute(
      path: AppRoutes.materialCourses,
      name: 'materialCourses',
      builder: (context, state) => Materialcourses(),
    ),
    GoRoute(
      path: AppRoutes.courseContent,
      name: 'courseContent',
      builder: (context, state) => CourseContent(),
    ),
    GoRoute(
      path: AppRoutes.srs,
      name: 'srs',
      builder: (context, state) => SRS(),
    ),

    // Feature Routes
    GoRoute(
      path: AppRoutes.career,
      name: 'career',
      builder: (context, state) => CareerHome(),
    ),
    GoRoute(
      path: AppRoutes.quiz,
      name: 'quiz',
      builder: (context, state) => QuizHome(),
    ),
    GoRoute(
      path: AppRoutes.game,
      name: 'game',
      builder: (context, state) => GameHome(),
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => GameLeaderBoard(),
    ),
    GoRoute(
      path: AppRoutes.aboLayla,
      name: 'aboLayla',
      builder: (context, state) => AboLayla(),
    ),
  ],
);
