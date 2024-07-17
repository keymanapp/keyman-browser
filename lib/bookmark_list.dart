import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class BookMarkList extends StatefulWidget {
  final List<String> bookmarks;
  final WebViewController controller;
  final Function(String) onBookmarkTapped;
  final Function(String) onBookmarkRemoved;
  
  const BookMarkList({
    Key? key, 
    required this.bookmarks, 
    required this.controller, 
    required this.onBookmarkTapped,
    required this.onBookmarkRemoved
  }) : super(key: key);

  @override
  _BookMarkListState createState() => _BookMarkListState();
}

class _BookMarkListState extends State<BookMarkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Bookmark List'),
      ),
      body: ListView.builder(
        itemCount: widget.bookmarks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Linkify(
              text: widget.bookmarks[index],
              overflow: TextOverflow.fade,
              linkStyle: const TextStyle(fontSize: 16.0, color: Colors.blue),
              onOpen: (link) => widget.onBookmarkTapped(link.url),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Before calling onBookmarkRemoved, ensure the index is valid
                if (index >= 0 && index < widget.bookmarks.length) {
                  widget.onBookmarkRemoved(widget.bookmarks[index]);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
