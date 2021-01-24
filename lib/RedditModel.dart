import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter4reddit/SubmissonData.dart';
import 'dart:convert' as json;

class RedditModel with ChangeNotifier {
  BuildContext context;
  Reddit r;
  String subReddit = "all";
  String SECRET;
  String CLIENT;
  String AGENT;
  List<Submission> currentPosts;
  List<SubmissionData> currentPostsData;
  int increment;
  void changeSubReddit(String newSubReddit) {
    subReddit = newSubReddit;
    getCurrentPosts();
    notifyListeners();
  }

  RedditModel(BuildContext c) {
    this.context = c;
    currentPosts = new List<Submission>();
    currentPostsData = new List<SubmissionData>();
    increment = 100;

    print("");
    initAPI();
  }
  Future<void> initAPI() async {
    String s =
        await DefaultAssetBundle.of(context).loadString("assets/keys.json");
    Map keysJSON = json.jsonDecode(s);
    CLIENT = keysJSON["CLIENT"];
    SECRET = keysJSON["SECRET"];
    AGENT = keysJSON["AGENT"];
    r = await Reddit.createReadOnlyInstance(
      clientId: CLIENT,
      clientSecret: SECRET,
      userAgent: AGENT,
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
    var posts = r.front.hot(limit: 10);
    await for (Submission s in posts) {
      print("Title: " + s.title + "\n");
    }
  }

  void getCurrentPosts() async {
    currentPosts.clear();
    currentPostsData.clear();
    var posts = r.subreddit(subReddit).hot(limit: 100);
    await for (Submission s in posts) {
      currentPosts.add(s);
    }
    getCurrentPostsData();
    notifyListeners();
  }

  void getCurrentPostsData() {
    for (int i = 0; i < currentPosts.length; i++) {
      SubmissionData data = new SubmissionData(currentPosts[i]);
      currentPostsData.add(data);
    }
  }

  SubmissionData getSubmissionData(int index) {
    return currentPostsData[index];
  }

  Future<List<SubredditRef>> searchForSubredditsWithName(String name) async {
    var results = r.subreddits.searchByName(name);
    return results;
  }

  Future<void> loadPostData(int index) async {
    await currentPosts[index].refreshComments();
    await currentPosts[index].comments.replaceMore(limit: 0);
    return null;
  }

  Future<void> loadMorePosts() async {
    print("loading more posts");
    if (increment > 800) return null; // reddit api has limit of 1000
    currentPosts.clear();
    currentPostsData.clear();
    var posts = r.subreddit(subReddit).hot(limit: 100 + increment);
    await for (Submission s in posts) {
      currentPosts.add(s);
    }
    increment += 100;
    getCurrentPostsData();
    notifyListeners();
    return null;
  }
}
