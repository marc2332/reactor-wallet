import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void openURL(url, BuildContext context) async {
  bool canOpen = await canLaunch(url);

  if (canOpen) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Could not open browser."),
      ),
    );
  }
}
