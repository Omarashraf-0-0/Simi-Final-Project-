import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PopupType {
  success,
  error,
  warning,
  info,
  question,
}

class StylishPopup extends StatefulWidget {
  final String title;
  final String message;
  final PopupType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;

  const StylishPopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancel = false,
  });

  // Helper methods for quick usage
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required PopupType type,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancel = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StylishPopup(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancel: showCancel,
      ),
    );
  }

  static Future<void> success({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: PopupType.success,
      confirmText: confirmText ?? 'Great!',
      onConfirm: onConfirm,
    );
  }

  static Future<void> error({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: PopupType.error,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
    );
  }

  static Future<void> warning({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: PopupType.warning,
      confirmText: confirmText ?? 'Got it',
      onConfirm: onConfirm,
    );
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: PopupType.info,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> question({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    bool? result;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StylishPopup(
        title: title,
        message: message,
        type: PopupType.question,
        confirmText: confirmText ?? 'Yes',
        cancelText: cancelText ?? 'No',
        showCancel: true,
        onConfirm: () {
          result = true;
          Navigator.of(context).pop();
        },
        onCancel: () {
          result = false;
          Navigator.of(context).pop();
        },
      ),
    );
    return result;
  }

  @override
  _StylishPopupState createState() => _StylishPopupState();
}

class _StylishPopupState extends State<StylishPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Brand colors
  final Color blue1 = const Color(0xFF1C74BB);
  final Color blue2 = const Color(0xFF165D96);
  final Color cyan1 = const Color(0xFF18BEBC);
  final Color cyan2 = const Color(0xFF139896);
  final Color redAccent = const Color(0xFFB3141C);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);
  final Color amber = const Color(0xFFFFC107);
  final Color green = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case PopupType.success:
        return green;
      case PopupType.error:
        return redAccent;
      case PopupType.warning:
        return amber;
      case PopupType.info:
        return cyan1;
      case PopupType.question:
        return blue1;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case PopupType.success:
        return Icons.check_circle_rounded;
      case PopupType.error:
        return Icons.error_rounded;
      case PopupType.warning:
        return Icons.warning_rounded;
      case PopupType.info:
        return Icons.info_rounded;
      case PopupType.question:
        return Icons.help_rounded;
    }
  }

  String _getEmoji() {
    switch (widget.type) {
      case PopupType.success:
        return '✅';
      case PopupType.error:
        return '❌';
      case PopupType.warning:
        return '⚠️';
      case PopupType.info:
        return 'ℹ️';
      case PopupType.question:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    final emoji = _getEmoji();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.2),
                      border: Border.all(color: color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: color,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bungee(
                      fontSize: 22,
                      color: color,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          color: black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.showCancel) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.onCancel != null) {
                                widget.onCancel!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                    color: Colors.grey[600]!, width: 2),
                              ),
                            ),
                            child: Text(
                              widget.cancelText ?? 'Cancel',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.onConfirm != null) {
                              widget.onConfirm!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: color.withOpacity(0.5),
                          ),
                          child: Text(
                            widget.confirmText ?? 'OK',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.type == PopupType.warning
                                  ? black
                                  : white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
