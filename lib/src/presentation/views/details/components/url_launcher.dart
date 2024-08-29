import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherComponent extends StatelessWidget {
  const UrlLauncherComponent(this.url, {super.key});

  final String url;

  Uri get _url => Uri.parse(url);

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _launchUrl,
      child: Text(url, style: const TextStyle(color: Colors.blue)),
    );
  }
}
