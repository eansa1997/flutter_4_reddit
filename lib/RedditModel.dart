import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter4reddit/SubmissonData.dart';
import 'dart:convert' as json;

class RedditModel with ChangeNotifier {
  BuildContext _context;
  Reddit _reddit;
  String _subReddit = "all";
  String _secret;
  String _client;
  String _agent;
  List<SubmissionData> _currentPostsData;
  StreamController _controller;
  StreamController _subredditController;
  String getSubReddit() {
    return _subReddit;
  }

  int getCurrentPostsLength() {
    return _currentPostsData.length;
  }

  void changeSubReddit(String newSubReddit) {
    _subReddit = newSubReddit;
    _subredditController.add(_subReddit);
    //notifyListeners();
    getCurrentPosts();
  }

  Future<void> passController(StreamController controller) async {
    _controller = controller;
    await initAPI();
    getCurrentPosts();
  }

  void passAppbarController(StreamController con) {
    _subredditController = con;
    _subredditController.add(_subReddit);
  }

  RedditModel(BuildContext c) {
    this._context = c;
    _currentPostsData = new List<SubmissionData>();
  }
  Future<void> initAPI() async {
    String s =
        await DefaultAssetBundle.of(_context).loadString("assets/keys.json");
    Map keysJSON = json.jsonDecode(s);
    _client = keysJSON["CLIENT"];
    _secret = keysJSON["SECRET"];
    _agent = keysJSON["AGENT"];
    _reddit = await Reddit.createReadOnlyInstance(
      clientId: _client,
      clientSecret: _secret,
      userAgent: _agent,
      //username: USERNAME,
      //password: PASSWORD
    );

    // testAPI(); uncomment to verify API connected
    //getCurrentPosts();
  }

  Future<void> testAPI() async {
    /*
        Redditor me = await r.user.me();
        Submission sub;
        print("My name is ${me.displayName}");
        */
    var posts = _reddit.front.hot(limit: 10);
    await for (Submission s in posts) {
      print("Title: " + s.title + "\n");
    }
  }

  void getCurrentPosts() async {
    _controller.add(1); // 1 == loading
    print("loading..");
    _currentPostsData.clear();
    var posts = _reddit.subreddit(_subReddit).hot(limit: 100);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      _currentPostsData.add(data);
    }
    _controller.add(3); // 3 = list loaded
    print("loaded.");
    //notifyListeners();
  }

  Future<void> loadMorePosts() async {
    print("loading more posts..");
    var posts = _reddit.subreddit(_subReddit).hot(
        limit: 100,
        after: _currentPostsData[_currentPostsData.length - 1]
            .getSubmission()
            .fullname);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      _currentPostsData.add(data);
    }
    notifyListeners();
  }

  SubmissionData getSubmissionData(int index) {
    return _currentPostsData[index];
  }

  Future<List<SubredditRef>> searchForSubredditsWithName(String name) async {
    var results = _reddit.subreddits.searchByName(name);
    return results;
  }
}
