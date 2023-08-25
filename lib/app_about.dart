import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppAbout extends StatefulWidget {
  const AppAbout({super.key});

  @override
  State<AppAbout> createState() => _AboutState();
}

class _AboutState extends State<AppAbout> {
  String _version = '';

  @override
  Widget build(BuildContext context) {
    // The reason for the package-info-plus dependency.  And yes... it requires
    // promises to look it up.
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
      });
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        title: const Text("Keyman Browser"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'App version: $_version',
            )
          ],
        ),
      ),
    );
  }
}
