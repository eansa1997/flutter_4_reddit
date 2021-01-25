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
  List<SubmissionData> currentPostsData;
  void changeSubReddit(String newSubReddit) {
    subReddit = newSubReddit;
    notifyListeners();
    getCurrentPosts();
  }

  RedditModel(BuildContext c) {
    this.context = c;
    currentPostsData = new List<SubmissionData>();
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
    currentPostsData.clear();
    var posts = r.subreddit(subReddit).hot(limit: 100);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      currentPostsData.add(data);
    }

    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    print("loading more posts..");
    var posts = r.subreddit(subReddit).hot(
        limit: 100,
        after:
            currentPostsData[currentPostsData.length - 1].submission.fullname);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      currentPostsData.add(data);
    }
    notifyListeners();
  }

  SubmissionData getSubmissionData(int index) {
    return currentPostsData[index];
  }

  Future<List<SubredditRef>> searchForSubredditsWithName(String name) async {
    var results = r.subreddits.searchByName(name);
    return results;
  }
}
