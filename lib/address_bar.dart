import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:keyman_browser/browser_menu.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  _AddressBarState createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController textController;
  int loadingPercentage = 0;
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
          _injectCustomCSS();
        });
      },
    ));
  }

  Future<void> _injectCustomCSS() async {
  final fontFamily = "KeymanEmbeddedBrowserFont";
  final fontData = await rootBundle.load('assets/fonts/Caveat-VariableFont_wght.ttf');
  final base64Font = base64Encode(fontData.buffer.asUint8List());

  final fontFaceStyle = """
  @font-face {
    font-family: "$fontFamily";
    src: url(data:font/ttf;charset=utf-8;base64,$base64Font) format('truetype');
  }
  """;

  final jsString = """
  var style = document.createElement('style');
  style.type = 'text/css';
  style.innerHTML = `
  * {
    font-family: "$fontFamily" !important;
  }
  $fontFaceStyle
  `;
  document.getElementsByTagName('head')[0].appendChild(style);
  """;

  try {
    await widget.controller.runJavaScript(jsString);
  } catch (e) {
    print('Error injecting JavaScript: $e');
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
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
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
                        print('Error parsing URL: $e');
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
            color: Colors.red,
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}