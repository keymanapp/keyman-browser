import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:keyman_browser/app_about.dart';
import 'package:keyman_browser/bookmark_list.dart';
import 'package:share_plus/share_plus.dart';


enum _BrowserMenuOptions {
  reload,
  share,
  bookmark,
  about,
}

class BrowserMenu extends StatefulWidget {
  final List<String> bookmarks;
  final WebViewController controller;
  final Function(String) onBookmarkTapped;
  final Function(String) onBookmarkRemoved;

  const BrowserMenu({
    required this.controller, 
    required this.bookmarks,
    required this.onBookmarkTapped,
    required this.onBookmarkRemoved,
    super.key});

 @override
  BrowserMenuState createState() => BrowserMenuState();
}

class BrowserMenuState extends State<BrowserMenu>  {

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
            MaterialPageRoute(builder: (context) =>  BookMarkList(
              bookmarks: widget.bookmarks, 
              controller: widget.controller, 
              onBookmarkRemoved: widget.onBookmarkRemoved,
              onBookmarkTapped: widget.onBookmarkTapped
            ))     
          );
          break;
          case _BrowserMenuOptions.share:
            // Fetch the URL from WebViewController
            final url = await widget.controller.currentUrl() ?? '';
            Share.share(url);
          break;
          case _BrowserMenuOptions.reload:
            widget.controller.reload();
          break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.reload,
          child: ListTile(
            leading: Icon(Icons.replay),
            title: Text('Reload'),
          ),
        ),
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.share,
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
          ),
        ),
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.bookmark,
          child: ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmark'),
          ),
        ),
        const PopupMenuItem<_BrowserMenuOptions>(
          value: _BrowserMenuOptions.about,
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Us'),
          ),
        ),
      ],
    );
  }
}