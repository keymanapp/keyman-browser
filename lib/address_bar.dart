import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:keyman_browser/browser_menu.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
  String? _fontName;
  static const platform = MethodChannel('com.example.font_channel');

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    widget.controller.setNavigationDelegate(NavigationDelegate(
       onNavigationRequest: (NavigationRequest request) {
      if (request.url.startsWith("http://")) {
        final secureUrl = request.url.replaceFirst("http://", "https://");
        widget.controller.loadRequest(Uri.parse(secureUrl));
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    },
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
        });
        if (_fontName != null && _fontName!.isNotEmpty) {
          _injectFont(_fontName!);
        }
      },
    ));

    platform.setMethodCallHandler((call) async {
      if (call.method == "onFontNameReceived") {
        String fontName = call.arguments;
        setState(() {
          _fontName = fontName;
        });
        _injectFont(fontName);

        Fluttertoast.showToast(
          msg: "Using font: $fontName",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    });
  }

  Future<void> _injectFont(String fontName) async {
    if (fontName.isEmpty) return;

    final encodedFontName = Uri.encodeComponent(fontName);
    final fontUrl = 'https://s.keyman.com/font/deploy/$encodedFontName';

    final jsStr = """
      (function() {
        var existingStyle = document.getElementById('km-font-style');
        if (existingStyle) {
          existingStyle.remove();
        }

        var style = document.createElement('style');
        style.id = 'km-font-style';
        style.type = 'text/css';
        style.innerHTML = \`
          @font-face {
            font-family: "KMRemoteFont";
            src: url("$fontUrl");
          }
          * {
            font-family: "KMRemoteFont" !important;
          }
        \`;
        document.head.appendChild(style);
      })();
    """;

    try {
      await widget.controller.runJavaScript(jsStr);
      print("Font injected successfully: $fontUrl");
    } catch (e) {
      print("Font injection failed: $e");
    }
  }


  void _toggleBookmark() async {
    var url = await widget.controller.currentUrl();
    if (url != null && !url.startsWith("about:blank") && !url.endsWith("about:blank")) {
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
                    _loadUrl(value);
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
