import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class SubmissionData {
  Image thumbnail;
  String upvotes;
  String selfText;
  Submission submission;
  SubmissionData(Submission s) {
    submission = s;
  }
  String getPostSelfText() {
    if (selfText != null) return selfText;
    selfText = "";
    if (submission.selftext != null) {
      var unescapeHTML = HtmlUnescape();
      selfText = unescapeHTML.convert(submission.selftext);
    }
    return selfText;
  }

  String getSubmissionTitle() {
    return submission.title;
  }

  Image getThumbnail() {
    if (thumbnail != null) return thumbnail;
    String imgURI = submission.thumbnail.toString();
    if (imgURI.contains(".")) {
      thumbnail = Image.network(
        imgURI,
        width: 60,
        height: 60,
      );
    }
    return thumbnail;
  }

  String getUpvotes() {
    // anything greater than 9999 gets turned into 10k
    if (upvotes != null) return upvotes;
    int numOfUpvotes = submission.upvotes;
    if (numOfUpvotes > 9999) {
      int thousands = (numOfUpvotes ~/ 1000);
      upvotes = thousands.toString() + "k";
    } else {
      upvotes = numOfUpvotes.toString();
    }
    return upvotes;
  }

  String getSubredditName() {
    return submission.subreddit.displayName;
  }

  String getThumbnailHD() {
    return submission.url.toString();
  }

  Future<List<dynamic>> getComments() async {
    await submission.refreshComments();
    await submission.comments.replaceMore(limit: 0);
    return submission.comments.comments;
  }
}
