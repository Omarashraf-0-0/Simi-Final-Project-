import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherPage extends StatefulWidget {
  final String url;

  const UrlLauncherPage({Key? key, required this.url}) : super(key: key);

  @override
  _UrlLauncherPageState createState() => _UrlLauncherPageState();
}

class _UrlLauncherPageState extends State<UrlLauncherPage> {
  @override
  void initState() {
    super.initState();
    _launchUrl(); // Automatically launch the URL
  }

  Future<void> _launchUrl() async {
    if (await canLaunch(widget.url)) {
      await launch(widget.url);
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Launching URL: ${widget.url}...'), // Optional feedback
      ),
    );
  }
}
