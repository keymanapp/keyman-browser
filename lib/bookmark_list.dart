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
    required this.onBookmarkRemoved,
  }) : super(key: key);

  @override
  _BookMarkListState createState() => _BookMarkListState();
}

class _BookMarkListState extends State<BookMarkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(217, 0, 0, 0),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange.shade600, Colors.deepOrange.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: widget.bookmarks.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Smaller border radius
              ),
              child: ListTile(
               
                title: Linkify(
                  text: widget.bookmarks[index],
                  overflow: TextOverflow.ellipsis,
                  linkStyle: const TextStyle(fontSize: 16.0, color: Color.fromARGB(222, 16, 109, 184)),
                  onOpen: (link) => widget.onBookmarkTapped(link.url),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Color.fromARGB(217, 0, 0, 0)),
                  onPressed: () {
                    setState(() {
                      if (index >= 0 && index < widget.bookmarks.length) {
                        widget.onBookmarkRemoved(widget.bookmarks[index]);
                      }
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
