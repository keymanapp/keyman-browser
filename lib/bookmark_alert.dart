import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BookmarkAlert extends StatefulWidget {
  const BookmarkAlert({
    required this.controller, 
    required this.bookmarks,
    super.key});
  
  @override
  BookmarkAlertState createState() => BookmarkAlertState();
  final List<String> bookmarks;
  final WebViewController controller; 
}

class BookmarkAlertState extends State<BookmarkAlert> {
  BookmarkAlertState({dynamic key});
  bool outline = false;
  String enteredUrlText = ''; 
  var textController = TextEditingController();

void saveBookmark() {
  var urlFuture = widget.controller.currentUrl();
  urlFuture.then((url) {
    setState(() {
      if (url != null) {
        // Check if the word pair already exists in the list
        final alreadyAdded = widget.bookmarks.contains(url);

        // If the word pair does not exist in the list, add it
        if (!alreadyAdded) {
          widget.bookmarks.insert(0, url); //new bookmark alwasy appear first in the list
          enteredUrlText = '';
        }
      }
    });
  });
}



// @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       padding: EdgeInsets.zero,
//       icon: Icon(
//         outline? Icons.bookmark : Icons.bookmark_outline,
//         color: Theme.of(context).primaryColor,
//       ),
//       onPressed: () {
//         setState(() {
//           outline =!outline; 
//           saveBookmark(); 
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(outline? 'Bookmark added' : 'Bookmark removed'),
//           ),
//         );
//       },
//     );
//   }
// }


// @override
//   Widget build(BuildContext context) {
  
//     return 
//      IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: (){
//                       textController.clear();
//                     }
//                   ),

//     IconButton(
//       padding: EdgeInsets.zero,
//       icon: Icon(
//         outline? Icons.bookmark : Icons.bookmark_outline,
//         color: outline? Theme.of(context).primaryColor:null,
//       ),
//       onPressed: () {
//         setState(() {
//           outline = true;
//           saveBookmark();  
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(outline? 'Bookmark added' : 'Bookmark removed'),
//           ),
//         );
//       },
//     );
//   }
// }

@override
Widget build(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          textController.clear();
        }
      ),
      IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          outline? Icons.bookmark : Icons.bookmark_outline,
          color: outline? Theme.of(context).primaryColor:null,
        ),
        onPressed: () {
          setState(() {
            outline = true;
            saveBookmark();  
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(outline? 'Bookmark added' : 'Bookmark removed'),
            ),
          );
        },
      ),
    ],
  );
}}