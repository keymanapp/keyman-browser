import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:keyman_browser/browser_menu.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddressBar extends StatefulWidget {
  final WebViewController controller;
  final List<String> bookmarks;
  final Function(String) onBookmarkTapped;
  final Function(String) onBookmarkRemoved;
  final VoidCallback onNavigation;

  const AddressBar({Key? key, 
  required this.controller, 
  required this.bookmarks,
  required this.onBookmarkTapped,
  required this.onBookmarkRemoved,
  required this.onNavigation,}) : super(key: key);

  @override
  AddressBarState createState() => AddressBarState();
}

class AddressBarState extends State<AddressBar> {
  late TextEditingController textController;
  int loadingPercentage = 0;
  bool isLoading = false;
  bool isBookmarked = false;
  String searchEngineUrl = "https://www.google.com/";

  static const platform = MethodChannel('com.example.kmmanager/font');
  String fontBaseUri = 'file:///android_asset/';
  String loadedFont = 'sans-serif-bold';

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    widget.controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          isLoading = true;
          loadingPercentage = 0;
        });
      },
      onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
      onPageFinished: (url) {
        _updateBookmarkState();
        setState(() {
          isLoading = false;
          textController.text = url;
          loadingPercentage = 100;
          // _injectCustomCSS();
          _loadFont();
        });
      },
    ));
  }

  Future<void> _loadFont() async {
    try {
      final String font = await platform.invokeMethod('getKeyboardFontFilename');

      if (font.isNotEmpty) {
        loadedFont = font;
        final fontUrl = '$fontBaseUri$font';

        final jsStr = """
          var style = document.createElement('style');
          style.type = 'text/css';
          style.innerHTML = '@font-face{font-family:"KMCustomFont";src:url("$fontUrl");} *{font-family:"KMCustomFont" !important;}';
          document.getElementsByTagName('head')[0].appendChild(style);
        """;

        widget.controller.runJavaScript(jsStr);
      } else {
        final jsStr = """
          var style = document.createElement('style');
          style.type = 'text/css';
          style.innerHTML = '*{font-family:"serif" !important;}';
          document.getElementsByTagName('head')[0].appendChild(style);
        """;

        widget.controller.runJavaScript(jsStr);
      }
    } on PlatformException catch (e) {
      print("Failed to get font: ${e.message}");
    }
  }

  Future<bool> _isValidUrl(String url) async {
    try {
      // Parse the URL and check if it has a scheme and host
      final uri = Uri.parse(url);
      if (uri.scheme.isEmpty || uri.host.isEmpty) {
        return false;
      }

      // Optionally check for URL reachability (if needed)
      // final response = await http.get(uri).timeout(const Duration(seconds: 5));
      // return response.statusCode >= 200 && response.statusCode < 300;
      return true;
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
            _updateBookmarkState();
            isBookmarked = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bookmark removed'),),
            );
          } else {
            widget.bookmarks.insert(0, url);
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
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'Enter URL or search',
                    border: InputBorder.none,
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
                        BrowserMenu(
                          bookmarks: widget.bookmarks,
                          controller: widget.controller,
                          onBookmarkRemoved: widget.onBookmarkRemoved,
                          onBookmarkTapped: widget.onBookmarkTapped,
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (value) async {
                    value = value.trim();
                    if (value.contains('.')) {
                      if (!(value.startsWith('http://') || value.startsWith('https://'))) {
                        value = 'https://www.$value';
                      }
                      try {
                        final uri = Uri.parse(value);
                        if (uri.hasScheme && uri.hasAuthority) {
                          widget.controller.loadRequest(uri);
                          _updateBookmarkState();
                        }
                      } catch (e) {
                        debugPrint('Error parsing URL: $e');
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
              ),
            ],
          ),
        ),
        if (isLoading || loadingPercentage < 100)
          LinearProgressIndicator(
            color: Colors.deepOrange,
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}