import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Pop-ups/ModernPopup.dart';

/// Example page showing all popup types
class PopupExamplesPage extends StatelessWidget {
  const PopupExamplesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modern Popups Demo',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1c74bb),
                Color(0xFF165d96),
                Color(0xFF18bebc),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Basic Popups'),
          _buildPopupButton(
            context,
            'Success Popup',
            Icons.check_circle,
            Colors.green,
            () {
              ModernPopup.showSuccess(
                context: context,
                title: 'Success!',
                message: 'Your operation completed successfully.',
                onConfirm: () {
                  print('User confirmed success');
                },
              );
            },
          ),
          _buildPopupButton(
            context,
            'Error Popup',
            Icons.error,
            Colors.red,
            () {
              ModernPopup.showError(
                context: context,
                title: 'Error!',
                message: 'Something went wrong. Please try again.',
              );
            },
          ),
          _buildPopupButton(
            context,
            'Warning Popup',
            Icons.warning,
            Colors.orange,
            () {
              ModernPopup.showWarning(
                context: context,
                title: 'Warning!',
                message: 'This action may have unintended consequences.',
              );
            },
          ),
          _buildPopupButton(
            context,
            'Info Popup',
            Icons.info,
            Colors.blue,
            () {
              ModernPopup.showInfo(
                context: context,
                title: 'Information',
                message: 'Here is some useful information for you.',
              );
            },
          ),
          SizedBox(height: 20),
          _buildSectionTitle('Interactive Popups'),
          _buildPopupButton(
            context,
            'Confirmation Popup',
            Icons.help,
            Color(0xFF1c74bb),
            () async {
              final result = await ModernPopup.showConfirmation(
                context: context,
                title: 'Confirm Action',
                message: 'Are you sure you want to proceed with this action?',
                confirmText: 'Yes',
                cancelText: 'No',
              );

              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User confirmed!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User cancelled')),
                );
              }
            },
          ),
          _buildPopupButton(
            context,
            'Dangerous Confirmation',
            Icons.warning_amber,
            Colors.red,
            () async {
              final result = await ModernPopup.showConfirmation(
                context: context,
                title: 'Delete Item',
                message:
                    'Are you sure you want to delete this item? This action cannot be undone.',
                confirmText: 'Delete',
                cancelText: 'Cancel',
                isDangerous: true,
              );

              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item deleted!')),
                );
              }
            },
          ),
          _buildPopupButton(
            context,
            'Loading Popup',
            Icons.sync,
            Color(0xFF18bebc),
            () async {
              ModernPopup.showLoading(
                context: context,
                message: 'Processing your request...',
              );

              // Simulate async operation
              await Future.delayed(Duration(seconds: 3));

              // Close loading
              Navigator.of(context).pop();

              // Show success
              ModernPopup.showSuccess(
                context: context,
                title: 'Done!',
                message: 'Processing completed successfully.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.leagueSpartan(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF165d96),
        ),
      ),
    );
  }

  Widget _buildPopupButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
