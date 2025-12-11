/// Semantic identifiers for Appium testing
///
/// Usage: Wrap widgets with Semantics() and use these keys for consistent identification
/// Example:
/// ```dart
/// Semantics(
///   label: SemanticsKeys.loginButton,
///   child: ElevatedButton(...),
/// )
/// ```
class SemanticsKeys {
  // Login Page
  static const String loginUsernameField = 'login_username_field';
  static const String loginPasswordField = 'login_password_field';
  static const String loginButton = 'login_button';
  static const String loginRememberMeCheckbox = 'login_remember_me';
  static const String loginForgotPasswordButton = 'login_forgot_password';
  static const String loginRegisterButton = 'login_register_button';
  static const String loginPasswordVisibilityToggle =
      'login_password_visibility';

  // Register Page
  static const String registerUsernameField = 'register_username_field';
  static const String registerEmailField = 'register_email_field';
  static const String registerPasswordField = 'register_password_field';
  static const String registerConfirmPasswordField =
      'register_confirm_password_field';
  static const String registerButton = 'register_button';
  static const String registerLoginButton = 'register_login_button';

  // Home Page
  static const String homeGreeting = 'home_greeting';
  static const String homeNavigationBar = 'home_navigation_bar';
  static const String homeScheduleSection = 'home_schedule_section';
  static const String homeCoursesSection = 'home_courses_section';
  static const String homeCourseCard = 'home_course_card_'; // append index
  static const String homeEventCard = 'home_event_card_'; // append index

  // Navigation
  static const String navHomeTab = 'nav_home_tab';
  static const String navScheduleTab = 'nav_schedule_tab';
  static const String navResourcesTab = 'nav_resources_tab';
  static const String navProfileTab = 'nav_profile_tab';
  static const String navSettingsTab = 'nav_settings_tab';

  // Profile Page
  static const String profileAvatar = 'profile_avatar';
  static const String profileName = 'profile_name';
  static const String profileEmail = 'profile_email';
  static const String profileEditButton = 'profile_edit_button';
  static const String profileLogoutButton = 'profile_logout_button';
  static const String profileXpDisplay = 'profile_xp_display';
  static const String profileLevelDisplay = 'profile_level_display';

  // Schedule Manager
  static const String scheduleDayView = 'schedule_day_view';
  static const String scheduleWeekView = 'schedule_week_view';
  static const String scheduleMonthView = 'schedule_month_view';
  static const String scheduleAddEventButton = 'schedule_add_event_button';
  static const String scheduleEventItem = 'schedule_event_item_'; // append id

  // Resources Page
  static const String resourcesSearchField = 'resources_search_field';
  static const String resourcesFilterButton = 'resources_filter_button';
  static const String resourcesListItem =
      'resources_list_item_'; // append index
  static const String resourcesUploadButton = 'resources_upload_button';

  // Quiz
  static const String quizStartButton = 'quiz_start_button';
  static const String quizQuestion = 'quiz_question';
  static const String quizOption = 'quiz_option_'; // append index
  static const String quizNextButton = 'quiz_next_button';
  static const String quizSubmitButton = 'quiz_submit_button';
  static const String quizScore = 'quiz_score';

  // Settings
  static const String settingsThemeToggle = 'settings_theme_toggle';
  static const String settingsNotificationToggle =
      'settings_notification_toggle';
  static const String settingsLanguageSelector = 'settings_language_selector';
  static const String settingsSaveButton = 'settings_save_button';

  // Notifications
  static const String notificationsList = 'notifications_list';
  static const String notificationItem = 'notification_item_'; // append id
  static const String notificationMarkReadButton = 'notification_mark_read_';

  // Career
  static const String careerCVButton = 'career_cv_button';
  static const String careerJobsButton = 'career_jobs_button';
  static const String careerCVPreviewButton = 'career_cv_preview_button';

  // Game/Gamification
  static const String gameHomeButton = 'game_home_button';
  static const String gameLeaderboardButton = 'game_leaderboard_button';
  static const String gameAchievementsButton = 'game_achievements_button';

  // AboLayla Chat
  static const String chatMessageInput = 'chat_message_input';
  static const String chatSendButton = 'chat_send_button';
  static const String chatMessageItem = 'chat_message_'; // append index

  // Common UI Elements
  static const String backButton = 'back_button';
  static const String closeButton = 'close_button';
  static const String confirmButton = 'confirm_button';
  static const String cancelButton = 'cancel_button';
  static const String deleteButton = 'delete_button';
  static const String editButton = 'edit_button';
  static const String saveButton = 'save_button';
  static const String searchField = 'search_field';
  static const String loadingIndicator = 'loading_indicator';
  static const String errorMessage = 'error_message';
  static const String successMessage = 'success_message';

  // Dialogs/Popups
  static const String dialogTitle = 'dialog_title';
  static const String dialogMessage = 'dialog_message';
  static const String dialogConfirm = 'dialog_confirm_button';
  static const String dialogCancel = 'dialog_cancel_button';
}
