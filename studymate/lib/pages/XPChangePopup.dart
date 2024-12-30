import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XPChangePopup extends StatefulWidget {
  final int xpChange; // Positive for gain, negative for loss
  final String message;

  const XPChangePopup({Key? key, required this.xpChange, required this.message})
      : super(key: key);

  @override
  _XPChangePopupState createState() => _XPChangePopupState();
}

class _XPChangePopupState extends State<XPChangePopup>
    with SingleTickerProviderStateMixin {
  // Animation controller for scaling the popup
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Colors according to your branding
  final Color blue1 = const Color(0xFF1C74BB);
  final Color blue2 = const Color(0xFF165D96);
  final Color cyan1 = const Color(0xFF18BEBC);
  final Color cyan2 = const Color(0xFF139896);
  final Color redAccent = const Color(0xFFB3141C);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the XP change is positive or negative
    bool isPositive = widget.xpChange >= 0;

    // Icon based on XP change
    IconData iconData = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    // Color based on XP change
    Color xpColor = isPositive ? cyan1 : redAccent;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: xpColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: xpColor.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // XP Change Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: xpColor,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${isPositive ? '+' : ''}${widget.xpChange} XP',
                      style: GoogleFonts.bungee(
                        fontSize: 32,
                        color: xpColor,
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
                  ],
                ),
                const SizedBox(height: 20),
                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14,
                    color: white,
                  ),
                ),
                const SizedBox(height: 30),
                // Close Button
                ElevatedButton(
                  onPressed: () {
                    // Close the popup
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: xpColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}