import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Extension methods for easier navigation
extension NavigationExtension on BuildContext {
  /// Navigate to home page
  void goToHome({Map<String, dynamic>? extra}) {
    go(AppRoutes.home, extra: extra);
  }

  /// Navigate to login page
  void goToLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to profile page
  void goToProfile() {
    push(AppRoutes.profile);
  }

  /// Navigate to settings page
  void goToSettings() {
    push(AppRoutes.settings);
  }

  /// Navigate to resources page
  void goToResources() {
    push(AppRoutes.resources);
  }

  /// Navigate to schedule page
  void goToSchedule() {
    push(AppRoutes.schedule);
  }

  /// Navigate to career page
  void goToCareer() {
    push(AppRoutes.career);
  }

  /// Navigate to quiz page
  void goToQuiz() {
    push(AppRoutes.quiz);
  }

  /// Navigate to game page
  void goToGame() {
    push(AppRoutes.game);
  }

  /// Navigate to notifications page
  void goToNotifications() {
    push(AppRoutes.notifications);
  }

  /// Navigate to AboLayla chat
  void goToAboLayla() {
    push(AppRoutes.aboLayla);
  }

  /// Navigate to performance page
  void goToPerformance() {
    push(AppRoutes.performance);
  }

  /// Navigate to leaderboard
  void goToLeaderboard() {
    push(AppRoutes.leaderboard);
  }

  /// Pop current route
  void goBack() {
    if (canPop()) {
      pop();
    }
  }
}
