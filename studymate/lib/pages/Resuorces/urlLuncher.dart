// url_launcher_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherPage extends StatelessWidget {
  // final String url;

  // const UrlLauncherPage({Key? key, required this.url}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Center(
          child: TextButton(
            onPressed: () async {
              var url = 'https://www.youtube.com/watch?v=zsoZqi4RnP0';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: const Text('Open Link'),
          ),
          )
    );
  }
}