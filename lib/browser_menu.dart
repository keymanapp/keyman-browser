import 'package:flutter/material.dart';
import 'package:keyman_browser/app_about.dart';
import 'package:keyman_browser/bookmark_list.dart';

enum _BrowserMenuOptions {
  about,
  bookmark
}

class BrowserMenu extends StatelessWidget {
  const BrowserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BrowserMenuOptions>(
      iconSize: 18,
      padding: EdgeInsets.zero,
      onSelected: (value) async {
        switch (value) {
          case _BrowserMenuOptions.about:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppAbout()             
              )
            );
            break;
          case _BrowserMenuOptions.bookmark:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookMarkList()             
              )
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.about,
          child: Text('About...')
        ),
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.bookmark,
          child: Text('Bookmark')
        )
      ],
      
    );
  }
}