import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserWebView extends StatefulWidget {
  const BrowserWebView({required this.controller, super.key});
  final WebViewController controller;

  @override
  State<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller
      .setNavigationDelegate(NavigationDelegate(
        // onWebResourceError: (error) {

        // },
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        // // May be useful should we desire to handle Keyman keyboard download links
        // // in a special manner from the browser app.
        // onNavigationRequest: (navigation) {
        //   final host = Uri.parse(navigation.url).host;
        //   if (host.contains('youtube.com')) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('Blocking navigation to $host')
        //       )
        //     );

        //     return NavigationDecision.prevent;
        //   }
        //   return NavigationDecision.navigate;
        // }
      ));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: widget.controller
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0
          )
      ]
    );
  }
}