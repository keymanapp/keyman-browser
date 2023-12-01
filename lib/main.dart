import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'address_bar.dart';
import 'browser_web_view.dart';
import 'navigation_controls.dart';

void main() {
  final theme = ThemeData(
    // This is the theme of your application.
    //
    // TRY THIS: Try running your application with "flutter run". You'll see
    // the application has a blue toolbar. Then, without quitting the app,
    // try changing the seedColor in the colorScheme below to Colors.green
    // and then invoke "hot reload" (save your changes or press the "hot
    // reload" button in a Flutter-supported IDE, or press "r" if you used
    // the command line to start the app).
    //
    // Notice that the counter didn't reset back to zero; the application
    // state is not lost during the reload. To reset the state, use hot
    // restart instead.
    //
    // This works for code too, not just values: Most code changes can be
    // tested with just a hot reload.
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    useMaterial3: true,
  );

  runApp(MaterialApp(
    theme: theme,
    home: const KeymanBrowserApp()
  ));
}

class KeymanBrowserApp extends StatefulWidget {
  const KeymanBrowserApp({super.key});

  @override
  State<KeymanBrowserApp> createState() => _KeymanBrowserAppState();
}

class _KeymanBrowserAppState extends State<KeymanBrowserApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://keyman.com')
      );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AddressBar(controller: controller)
      ),
      body: BrowserWebView(controller: controller),
      bottomNavigationBar: NavigationControls(controller: controller)
    );
  }
}