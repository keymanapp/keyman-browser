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
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 133, 98, 87)),
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
  late final List<String> bookmarks;
  late final Function(String) onBookmarkTapped;
  late final Function(String) onBookmarkRemoved;

  final urlNotifier = ValueNotifier<String>('');
  

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://keyman.com')
      );
    bookmarks = [];

     onBookmarkTapped = (url) {
      controller.loadRequest(Uri.parse(url));
      Navigator.pop(context);
    };

    onBookmarkRemoved = (url) {
      setState(() {
        bookmarks.remove(url);
        // Update any related state
        // isBookmarked = bookmarks.contains(url);
      });
    };

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
        height: 40, // Set the height to a non-zero value
        child: AddressBar(controller: controller, bookmarks: bookmarks),
    ),
    
      ),
      body: BrowserWebView(controller: controller),
      bottomNavigationBar: NavigationControls(
        controller: controller,  
        bookmarks: bookmarks,
        onBookmarkRemoved: onBookmarkRemoved,
        onBookmarkTapped: onBookmarkTapped,)
    );
  }
}