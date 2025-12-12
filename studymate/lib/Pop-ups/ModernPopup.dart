import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// Modern, themed popup dialog system
/// Supports: Success, Error, Warning, Info, Confirmation
class ModernPopup {
  // Theme Colors
  static const Color primaryColor = Color(0xFF1c74bb);
  static const Color secondaryColor = Color(0xFF165d96);
  static const Color accentColor = Color(0xFF18bebc);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  /// Show Success Popup
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    bool dismissible = true,
  }) {
    return _showModernDialog(
      context: context,
      type: PopupType.success,
      title: title,
      message: message,
      buttonText: buttonText ?? 'Great!',
      onConfirm: onConfirm,
      dismissible: dismissible,
    );
  }

  /// Show Error Popup
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    bool dismissible = true,
  }) {
    return _showModernDialog(
      context: context,
      type: PopupType.error,
      title: title,
      message: message,
      buttonText: buttonText ?? 'OK',
      onConfirm: onConfirm,
      dismissible: dismissible,
    );
  }

  /// Show Warning Popup
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    bool dismissible = true,
  }) {
    return _showModernDialog(
      context: context,
      type: PopupType.warning,
      title: title,
      message: message,
      buttonText: buttonText ?? 'Understood',
      onConfirm: onConfirm,
      dismissible: dismissible,
    );
  }

  /// Show Info Popup
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    bool dismissible = true,
  }) {
    return _showModernDialog(
      context: context,
      type: PopupType.info,
      title: title,
      message: message,
      buttonText: buttonText ?? 'Got it',
      onConfirm: onConfirm,
      dismissible: dismissible,
    );
  }

  /// Show Confirmation Popup with Yes/No buttons
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ModernConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText ?? 'Confirm',
        cancelText: cancelText ?? 'Cancel',
        isDangerous: isDangerous,
      ),
    );
  }

  /// Show Loading Popup
  static void showLoading({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ModernLoadingDialog(
        message: message ?? 'Loading...',
      ),
    );
  }

  /// Internal method to show modern dialog
  static Future<void> _showModernDialog({
    required BuildContext context,
    required PopupType type,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onConfirm,
    bool dismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => _ModernPopupDialog(
        type: type,
        title: title,
        message: message,
        buttonText: buttonText,
        onConfirm: onConfirm,
      ),
    );
  }
}

enum PopupType { success, error, warning, info }

/// Modern Popup Dialog Widget
class _ModernPopupDialog extends StatelessWidget {
  final PopupType type;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onConfirm;

  const _ModernPopupDialog({
    required this.type,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onConfirm,
  });

  Color get primaryColor {
    switch (type) {
      case PopupType.success:
        return ModernPopup.successColor;
      case PopupType.error:
        return ModernPopup.errorColor;
      case PopupType.warning:
        return ModernPopup.warningColor;
      case PopupType.info:
        return ModernPopup.infoColor;
    }
  }

  IconData get icon {
    switch (type) {
      case PopupType.success:
        return Icons.check_circle_rounded;
      case PopupType.error:
        return Icons.error_rounded;
      case PopupType.warning:
        return Icons.warning_rounded;
      case PopupType.info:
        return Icons.info_rounded;
    }
  }

  String? get lottieAsset {
    switch (type) {
      case PopupType.success:
        return 'assets/animations/success.json';
      case PopupType.error:
        return null;
      case PopupType.warning:
        return null;
      case PopupType.info:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
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
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: lottieAsset != null
                    ? Lottie.asset(
                        lottieAsset!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  // Message
                  Text(
                    message,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  // Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).pop();
                          onConfirm?.call();
                        },
                        child: Center(
                          child: Text(
                            buttonText,
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
      ),
    );
  }
}

/// Modern Confirmation Dialog Widget
class _ModernConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDangerous;

  const _ModernConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDangerous,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        isDangerous ? ModernPopup.errorColor : ModernPopup.primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    confirmColor,
                    confirmColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDangerous
                        ? Icons.warning_rounded
                        : Icons.help_outline_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  // Message
                  Text(
                    message,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 15,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pop(false),
                              child: Center(
                                child: Text(
                                  cancelText,
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Confirm Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                confirmColor,
                                confirmColor.withOpacity(0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: confirmColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pop(true),
                              child: Center(
                                child: Text(
                                  confirmText,
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

/// Modern Loading Dialog Widget
class _ModernLoadingDialog extends StatelessWidget {
  final String message;

  const _ModernLoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ModernPopup.primaryColor,
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
