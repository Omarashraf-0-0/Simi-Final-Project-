import 'package:flutter/material.dart';
import 'UserSettings.dart';
import 'PersonalSettings.dart';
import 'Universitysettings.dart';
import '../../theme/app_constants.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.buildAppBar(
        title: 'Settings',
        leading: AppConstants.buildBackButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header text with styled segments
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Select ',
                    style: AppConstants.sectionHeader.copyWith(
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  TextSpan(
                    text: 'Option!',
                    style: AppConstants.sectionHeader.copyWith(
                      color: AppConstants.primaryCyan,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.spacingL),
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsOption(
                    context,
                    icon: Icons.person_outline,
                    title: 'User Settings',
                    subtitle: 'Manage your account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserSettings()),
                      );
                    },
                  ),
                  _buildSettingsOption(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Personal Settings',
                    subtitle: 'Customize your preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PersonalSettings()),
                      );
                    },
                  ),
                  _buildSettingsOption(
                    context,
                    icon: Icons.school_outlined,
                    title: 'University Settings',
                    subtitle: 'Update university information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Universitysettings()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppConstants.elevationS,
      margin: EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      shadowColor: Theme.of(context).colorScheme.onSurface,
      surfaceTintColor: Theme.of(context).colorScheme.onSurface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryCyan,
          child: Icon(
            icon,
            color: AppConstants.textOnPrimary,
          ),
        ),
        title: Text(
          title,
          style: AppConstants.subtitle.copyWith(
            fontWeight: AppConstants.fontWeightBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppConstants.smallText.copyWith(
                  color: Colors.grey[700],
                ),
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.onSurface),
        onTap: onTap,
      ),
    );
  }
}
