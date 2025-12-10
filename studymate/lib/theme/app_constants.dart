import 'package:flutter/material.dart';

/// Core Design System Constants
/// All UI elements should use these constants for consistency
class AppConstants {
  AppConstants._();

  // ========== COLORS ==========

  // Primary Brand Colors (from theme.dart)
  static const Color primaryCyan = Color(0xFF18bebc); // Cyan 1
  static const Color primaryCyanDark = Color(0xFF139896); // Cyan 2
  static const Color primaryBlue = Color(0xFF1c74bb); // Blue 1
  static const Color primaryBlueDark = Color(0xFF165d96); // Blue 2

  // Base Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundDarkCard = Color(0xFF1E1E2A);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Game/Rank Colors
  static const Color rankElBatal = Color(0xFFb3141c);
  static const Color rankLegend = Color(0xFFFFD700);
  static const Color rankMentor = Color(0xFF6F42C1);
  static const Color rankExpert = Color(0xFFFD7E14);
  static const Color rankChallenger = Color(0xFFFFC107);
  static const Color rankAchiever = Color(0xFF28A745);
  static const Color rankExplorer = Color(0xFF007BFF);
  static const Color rankNewComer = Color(0xFF808080);

  // ========== TYPOGRAPHY ==========

  // Font Family
  static const String fontFamily = 'League Spartan';

  // Font Sizes
  static const double fontSizeXXL = 32.0; // Page Titles
  static const double fontSizeXL = 28.0; // Section Headers
  static const double fontSizeL = 24.0; // Card Titles
  static const double fontSizeM = 20.0; // Subtitles
  static const double fontSizeRegular = 16.0; // Body Text
  static const double fontSizeS = 14.0; // Small Text
  static const double fontSizeXS = 12.0; // Captions

  // Font Weights
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightRegular = FontWeight.w400;

  // ========== TEXT STYLES ==========

  // AppBar Title
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeM,
    fontWeight: fontWeightBold,
    color: textOnPrimary,
  );

  // Page Title (Large Heading)
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXXL,
    fontWeight: fontWeightBold,
  );

  // Section Header
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXL,
    fontWeight: fontWeightBold,
  );

  // Card Title
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeL,
    fontWeight: fontWeightSemiBold,
  );

  // Subtitle
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeM,
    fontWeight: fontWeightMedium,
  );

  // Body Text
  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeRegular,
    fontWeight: fontWeightRegular,
  );

  // Small Text
  static const TextStyle smallText = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeS,
    fontWeight: fontWeightRegular,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXS,
    fontWeight: fontWeightRegular,
  );

  // ========== SPACING ==========

  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ========== BORDER RADIUS ==========

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;

  // ========== ICON SIZES ==========

  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 28.0;
  static const double iconSizeXL = 32.0;

  // ========== ELEVATION ==========

  static const double elevationNone = 0.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // ========== COMMON WIDGETS HELPERS ==========

  // Standard AppBar
  static AppBar buildAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
  }) {
    return AppBar(
      backgroundColor: backgroundColor ?? primaryBlueDark,
      elevation: elevationNone,
      centerTitle: centerTitle,
      leading: leading,
      title: Text(
        title,
        style: appBarTitle,
      ),
      actions: actions,
      iconTheme: IconThemeData(color: textOnPrimary),
    );
  }

  // Standard Back Button
  static Widget buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: textOnPrimary,
        size: iconSizeL,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  // Standard Loading Indicator
  static Widget buildLoadingIndicator({Color? color}) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? primaryCyan,
        ),
      ),
    );
  }
}
