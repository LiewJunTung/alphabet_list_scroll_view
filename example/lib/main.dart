import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var strList = [
    "Apple",
    "Anti",
    "AAA",
    "Boy",
    "Cat",
    "Cherry",
    "Moby",
    "Booby, masked",
    "Gecko (unidentified)",
    "Caiman, spectacled",
    "Mongoose, eastern dwarf",
    "Kori bustard",
    "Lion, steller's sea",
    "Glider, squirrel",
    "Large-eared bushbaby",
    "Python (unidentified)",
    "Sloth, two-toed tree",
    "Crane, wattled",
    "Cereopsis goose",
    "Eastern fox squirrel",
    "Beaver, north american",
    "Iguana, marine",
    "Grey-footed squirrel",
    "Salmon pink bird eater tarantula",
    "Cliffchat, mocking",
    "Blue-tongued skink",
    "Wapiti, elk,",
    "Black-necked stork",
    "Two-banded monitor",
    "Racer snake",
    "Dog, raccoon",
    "Wild turkey",
    "Common ringtail",
    "123",
    "诸葛亮"
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: AlphabetListScrollView(
            strList: strList,
            highlightTextStyle: TextStyle(
              color: Colors.green,
            ),
            showPreview: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(strList[index]),
                subtitle: Text(strList[index][0]),
              );
            },
          ),
        ));
  }
}
