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

  String getSubReddit() {
    return _subReddit;
  }

  int getCurrentPostsLength() {
    return _currentPostsData.length;
  }

  void changeSubReddit(String newSubReddit) {
    _subReddit = newSubReddit;
    notifyListeners();
    getCurrentPosts();
  }

  RedditModel(BuildContext c) {
    this._context = c;
    _currentPostsData = new List<SubmissionData>();
    initAPI();
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
    getCurrentPosts();
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
    _currentPostsData.clear();
    var posts = _reddit.subreddit(_subReddit).hot(limit: 100);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      _currentPostsData.add(data);
    }

    notifyListeners();
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
