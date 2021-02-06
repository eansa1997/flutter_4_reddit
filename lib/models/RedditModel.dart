import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/models/SubmissonData.dart';
import 'dart:convert' as json;
import '../utils/ReadAndSaveCredentials.dart';

class RedditModel with ChangeNotifier {
  BuildContext _context;
  Reddit _reddit;
  String _subReddit = "all";
  String _client;
  String _agent;
  List<SubmissionData> _currentPostsData;
  StreamController _controller;
  StreamController _subredditController;
  Uri _authUrl;
  String getSubReddit() {
    return _subReddit;
  }

  int getCurrentPostsLength() {
    return _currentPostsData.length;
  }

  void changeSubReddit(String newSubReddit) {
    _subReddit = newSubReddit;
    _subredditController.add(_subReddit);

    getCurrentPosts();
  }

  Future<void> signOutUser() async {
    await ReadAndSaveCredentials.deleteFile();
    _reddit = Reddit.createInstalledFlowInstance(
        clientId: _client,
        userAgent: _agent,
        redirectUri: Uri.parse("https://www.google.com"));
    _controller.add("login");
    _subReddit = "all";
    _subredditController.add(_subReddit);
  }

  Future<void> passController(StreamController controller) async {
    _controller = controller;
    await initAPI();
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
    _agent = keysJSON["AGENT"];

    String jsonCredentials = await ReadAndSaveCredentials.readFile();

    if (jsonCredentials == null) {
      _reddit = Reddit.createInstalledFlowInstance(
          clientId: _client,
          userAgent: _agent,
          redirectUri: Uri.parse("https://www.google.com"));
      _controller.add("login");
    } else {
      _reddit = Reddit.restoreInstalledAuthenticatedInstance(jsonCredentials,
          userAgent: _agent,
          clientId: _client,
          redirectUri: Uri.parse("https://www.google.com"));
      getCurrentPosts();
    }
  }

  String getAuthenticateUrl() {
    if (_authUrl == null) _authUrl = _reddit.auth.url(['*'], 'foobar');
    return _authUrl.toString();
  }

  Future<void> authenticate(String response) async {
    int indexOfCode = response.indexOf("code=");
    String authCode = response.substring(indexOfCode + 5);

    await _reddit.auth.authorize(authCode);
    String credentials = _reddit.auth.credentials.toJson();

    ReadAndSaveCredentials.writeFile(credentials);
    getCurrentPosts();
  }

  Future<void> testAPI() async {
    var posts = _reddit.front.hot(limit: 10);
    await for (Submission s in posts) {
      print("Title: " + s.title + "\n");
    }
  }

  void getCurrentPosts() async {
    _controller.add("loading"); // 1 == loading
    _currentPostsData.clear();
    var posts = _reddit.subreddit(_subReddit).hot(limit: 100);
    await for (Submission s in posts) {
      SubmissionData data = new SubmissionData(s);
      _currentPostsData.add(data);
    }
    _controller.add("loaded"); // 3 = list loaded
  }

  Future<void> loadMorePosts() async {
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
