import 'package:flutter/material.dart';
import 'package:flutter4reddit/RedditModel.dart';
import 'package:flutter4reddit/HomePageListView.dart';
import 'package:flutter4reddit/searchPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => RedditModel(context),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String subReddit = "all";
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Consumer<RedditModel>(
              builder: (context, myReddit, child) =>
                  Text("r/${myReddit.getSubReddit()}"))),
      body: HomePageListView(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: Colors.black,
        onTap: (value) {
          _currentIndex = value;
          handleTap();
        },
        items: [
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            label: "Search Subs",
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(
              Icons.portrait,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void handleTap() {
    if (_currentIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new SearchPage()),
      );
    }
  }
}
