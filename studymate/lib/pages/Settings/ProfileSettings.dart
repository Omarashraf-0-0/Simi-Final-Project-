import 'package:flutter/material.dart';
import 'package:studymate/theme/app_constants.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.buildAppBar(
        title: 'Profile Settings',
        leading: AppConstants.buildBackButton(context),
      ),
      body: Center(
        child: Text('Profile Settings Page Content'),
      ),
    );
  }
}
