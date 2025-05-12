import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'UserSettings.dart';
import 'PersonalSettings.dart';
import 'Universitysettings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  const Color blue1 = Color(0xFF1c74bb);
  const Color blue2 = Color(0xFF165d96);
  const Color cyan1 = Color(0xFF18bebc);
  const Color cyan2 = Color(0xFF139896);
  const Color black = Color(0xFF000000);
  const Color white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.leagueSpartan(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
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
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color ?? black,
                    ),
                  ),
                  TextSpan(
                    text: 'Option!',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cyan1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                        MaterialPageRoute(builder: (context) => const UserSettings()),
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
                        MaterialPageRoute(builder: (context) => const PersonalSettings()),
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
                        MaterialPageRoute(builder: (context) => const Universitysettings()),
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
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      shadowColor: Theme.of(context).colorScheme.onSurface,
      surfaceTintColor: Theme.of(context).colorScheme.onSurface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cyan1,
          child: Icon(
            icon,
            color: white,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.leagueSpartan(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface),
        onTap: onTap,
      ),
    );
  }
}