import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/models/RedditModel.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> searchResults;

  @override
  void initState() {
    super.initState();
    searchResults = new List<String>.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: null,
        ),
        centerTitle: true,
        title: Text("Search Subreddits..."),
      ),
      body: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            String sub = searchResults[index];
            return Material(
                color: Colors.black,
                child: InkWell(
                  onTap: () {
                    setSubReddit(sub);
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text(
                      "$sub",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ));
          }),
      bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                padding: EdgeInsets.all(15),
              ),
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  onFieldSubmitted: (String value) {
                    setSubReddit(value);
                    Navigator.pop(context);
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: 'Search..',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (String value) async {
                    await searchForSub(value);
                    showResults();
                    //setSubReddit(value);
                  },
                ),
              )
            ],
          )),
    );
  }

  void showResults() {
    setState(() {});
  }

  void setSubReddit(String val) {
    Provider.of<RedditModel>(context, listen: false).changeSubReddit(val);
  }

  Future<void> searchForSub(String name) async {
    searchResults = new List<String>.empty(growable: true);

    searchResults.add(name);
    List<SubredditRef> results =
        await Provider.of<RedditModel>(context, listen: false)
            .searchForSubredditsWithName(name);
    for (int i = 0; i < results.length; i++) {
      searchResults.add(results[i].displayName);
    }

    return null;
  }
}
