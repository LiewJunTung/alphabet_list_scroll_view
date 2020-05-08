import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(MainApp());

class User {
  User(this.name, this.company, this.favourite);
  final String name;
  final String company;
  final bool favourite;
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<User> userList = <User>[];
  List<String> strList = <String>[];
  List<Widget> favouriteList = <Widget>[];
  List<Widget> normalList = <Widget>[];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    for (int i = 0; i < 100; i++) {
      final String name = faker.person.name();
      userList.add(User(name, faker.company.name(), false));
    }
    for (int i = 0; i < 4; i++) {
      final String name = faker.person.name();
      userList.add(User(name, faker.company.name(), true));
    }
    userList.sort((User a, User b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    filterList();
    searchController.addListener(() {
      filterList();
    });
    super.initState();
  }

  void filterList() {
    final List<User> users = <User>[];
    users.addAll(userList);
    favouriteList = <Slidable>[];
    normalList = <Slidable>[];
    strList = <String>[];
    if (searchController.text.isNotEmpty) {
      users.retainWhere((User user) => user.name
          .toLowerCase()
          .contains(searchController.text.toLowerCase()));
    }
    for (final User user in users) {
      if (user.favourite) {
        favouriteList.add(
          Slidable(
            actionPane: const SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {},
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              leading: Stack(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundImage:
                        NetworkImage('http://placeimg.com/200/200/people'),
                  ),
                  Container(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow[100],
                        ),
                      ))
                ],
              ),
              title: Text(user.name),
              subtitle: Text(user.company),
            ),
          ),
        );
      } else {
        normalList.add(
          Slidable(
            actionPane: const SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {},
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage:
                    NetworkImage('http://placeimg.com/200/200/people'),
              ),
              title: Text(user.name),
              subtitle: Text(user.company),
            ),
          ),
        );
        strList.add(user.name);
      }
    }

    setState(() {
      strList = strList;
      favouriteList = favouriteList;
      normalList = normalList;
      strList = strList;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          color: Colors.yellow,
        ),
        showPreview: true,
        itemBuilder: (BuildContext context, int index) {
          return normalList[index];
        },
        indexedHeight: (int i) {
          return 80;
        },
        keyboardUsage: true,
        headerWidgetList: <AlphabetScrollListHeader>[
          AlphabetScrollListHeader(widgetList: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffix: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  labelText: 'Search',
                ),
              ),
            )
          ], icon: Icon(Icons.search), indexedHeaderHeight: (int index) => 80),
          AlphabetScrollListHeader(
              widgetList: favouriteList,
              icon: Icon(Icons.star),
              indexedHeaderHeight: (int index) {
                return 80;
              }),
        ],
      ),
    ));
  }
}
