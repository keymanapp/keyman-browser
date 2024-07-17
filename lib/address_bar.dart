import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:keyman_browser/bookmark_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class AddressBar extends StatefulWidget {
  final WebViewController controller;
  final List<String> bookmarks;

  const AddressBar({Key? key, required this.controller, required this.bookmarks}) : super(key: key);

  @override
  _AddressBarState createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController textController;
  bool isLoading = false;
  bool isBookmarked = false;
  String searchEngineUrl = "https://www.google.com/";

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    widget.controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          isLoading = true;
        });
      },
      onPageFinished: (url) {
        setState(() {
          isLoading = false;
          textController.text = url;
        });
      },
    ));
  }

  // @override
  // void dispose() {
  //   textController.dispose();
  //   super.dispose();
  // }

  Future<bool> _isValidUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) {
        return false;
      }
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _toggleBookmark() async {
    var url = await widget.controller.currentUrl();
    if (url != null && !url.startsWith("about:blank") && !url.endsWith("about:blank")) {
      if (await _isValidUrl(url)) {
        setState(() {
          if (widget.bookmarks.contains(url)) {
            widget.bookmarks.remove(url);
            isBookmarked = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bookmark removed'),),
            );
          } else {
            widget.bookmarks.add(url);
            isBookmarked = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bookmark added'),),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot bookmark invalid or inaccessible URL.')),
        );
      }
    }
  }

  void _loadUrl(String value) {
    Uri uri = Uri.parse(value);
    if (!uri.isAbsolute) {
      uri = Uri.parse("${searchEngineUrl}search?q=$value");
    }
    widget.controller.loadRequest(uri);
    _updateBookmarkState();

    if (value.isEmpty) {
      setState(() {
        isBookmarked = false;
      });
    }
  }

  void _updateBookmarkState() async {
    var url = await widget.controller.currentUrl();
    if (url != null) {
      setState(() {
        isBookmarked = widget.bookmarks.contains(url);
        textController.text = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Navigate to',
          contentPadding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              var url = textController.text;
              _loadUrl(url);
            },
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textController.clear();
                  setState(() {
                    isBookmarked = false; 
                  });
                },
              ),
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookMarkList(
                      bookmarks: widget.bookmarks,
                      controller: widget.controller,
                      onBookmarkTapped: (url) {
                        widget.controller.loadRequest(Uri.parse(url));
                        textController.text = url;
                        setState(() {
                          if (widget.bookmarks.contains(url)) {
                            isBookmarked = true;
                          }
                        });
                        Navigator.pop(context);
                      },
                      onBookmarkRemoved: (url) {
                        setState(() {
                          widget.bookmarks.remove(url);
                          isBookmarked = widget.bookmarks.contains(url);
                        });
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share(textController.text);
                },
              )
            ],
          ),
        ),
        onSubmitted: (value) async {
          if (value.contains('.')) {
            if (!(value.startsWith('http://') || value.startsWith('https://'))) {
              widget.controller.loadRequest(Uri.parse('https://$value')); 
              _updateBookmarkState();
            }
          } else {
            _loadUrl(value);
          }
        },
        onChanged: (value) {
          setState(() {
            isBookmarked = false;
          });
        },
      ),
    );
  }
}
