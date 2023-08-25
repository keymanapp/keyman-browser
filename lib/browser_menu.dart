import 'package:flutter/material.dart';
import 'package:keyman_browser/app_about.dart';

enum _BrowserMenuOptions {
  about
}

class BrowserMenu extends StatelessWidget {
  const BrowserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BrowserMenuOptions>(
      onSelected: (value) async {
        switch (value) {
          case _BrowserMenuOptions.about:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppAbout())
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.about,
          child: Text('About...')
        )
      ],
    );
  }
}