import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressBar extends StatefulWidget {
  const AddressBar({required this.controller, super.key});
  final WebViewController controller;

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  var isLoading = false;
  String enteredUrlText = '';

  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller
      .setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            if(!url.startsWith("about:blank") || !url.endsWith("about:blank")) {
              enteredUrlText = url;
              textController.text = url;
            }
            isLoading = true;
          });
        },
        onPageFinished: (url) {
          setState(() {
            isLoading = false;
          });
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5)
      ),
      child:
        TextField(
          controller: textController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: isLoading ? const Icon(Icons.stop) : const Icon(Icons.refresh),
              onPressed: () async {
                if (isLoading) {
                  widget.controller.loadRequest(Uri.parse("about:blank"));
                } else {
                  if((await widget.controller.currentUrl()).toString() == "about:blank") {
                    widget.controller.loadRequest(Uri.parse(enteredUrlText));
                  } else {
                    widget.controller.reload();
                  }
                }
              }
            ),
            hintText: 'Navigate to...',
            border: InputBorder.none
          ),
          onSubmitted: (text) async {
            try {
              enteredUrlText = text;

              var baseParse = Uri.parse(text);
              if(baseParse.host == '') {
                // Prefer the secure versions of sites if a host isn't specified.
                widget.controller.loadRequest(Uri.parse('https://$text'));
              } else {
                widget.controller.loadRequest(Uri.parse(text));
              }
            } catch (err) {
              // Backup plans:  fallback to plain, unsecured http if https isn't available.
              try {
                widget.controller.loadRequest(Uri.parse('http://$text'));
              } catch (err) {
                // If the site simply doesn't exist, we should show an error.
                // For now... 'about:blank' will have to suffice.
                widget.controller.loadRequest(Uri.parse('about:blank'));
              }
            }
          }
      )
    );
  }
}
