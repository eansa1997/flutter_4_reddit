import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart';

class SubmissionData {
  Image _thumbnail;
  String _upvotes;
  String _selfText;
  Submission _submission;
  SubmissionData(Submission s) {
    _submission = s;
  }
  Submission getSubmission() {
    return _submission;
  }

  String getPostSelfText() {
    if (_selfText != null) return _selfText;
    _selfText = "";
    if (_submission.selftext != null) {
      var unescapeHTML = HtmlUnescape();
      _selfText = markdownToHtml(unescapeHTML.convert(_submission.selftext));
      //print(_selfText);
    }
    return _selfText;
  }

  String getSubmissionTitle() {
    return _submission.title;
  }

  Image getThumbnail() {
    if (_thumbnail != null) return _thumbnail;
    String imgURI = _submission.thumbnail.toString();
    if (imgURI.contains(".")) {
      _thumbnail = Image.network(
        imgURI,
        width: 60,
        height: 60,
      );
    }
    return _thumbnail;
  }

  String getUpvotes() {
    // anything greater than 9999 gets turned into 10k
    if (_upvotes != null) return _upvotes;
    int numOfUpvotes = _submission.upvotes;
    if (numOfUpvotes > 9999) {
      int thousands = (numOfUpvotes ~/ 1000);
      _upvotes = thousands.toString() + "k";
    } else {
      _upvotes = numOfUpvotes.toString();
    }
    return _upvotes;
  }

  String getSubredditName() {
    return _submission.subreddit.displayName;
  }

  String getThumbnailHD() {
    return _submission.url.toString();
  }

  Future<List<dynamic>> getComments() async {
    await _submission.refreshComments();
    await _submission.comments.replaceMore(limit: 0);
    return _submission.comments.comments;
  }
}
