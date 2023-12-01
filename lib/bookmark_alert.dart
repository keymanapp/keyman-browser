import 'package:flutter/material.dart';
import 'package:keyman_browser/bookmark_list.dart';
import 'package:keyman_browser/address_bar.dart';

/// Flutter code sample for [showDialog].

void main() => runApp(const BookmarkAlert());

// class BookmarkAlert extends StatelessWidget {
//   const BookmarkAlert({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//           colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
//       home: const DialogExample(),
//     );
//   }
// }

class BookmarkAlert extends StatelessWidget {
  const BookmarkAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
            iconSize: 18.0,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.bookmark_add),
            onPressed: () => _dialogBuilder(context),
       );
  
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Basic dialog title'),
          content: const Text(
            'The link has been added to the bookmark list. '
            'Do you want to see the list?', 
           //TextEditingController.text

          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('yes'),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookMarkList()),
                );
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('no'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
