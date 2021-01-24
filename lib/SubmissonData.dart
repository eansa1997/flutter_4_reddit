import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class SubmissionData {
  String title;
  String imgURI;
  Image thumbnail;
  int numOfUpvotes;
  int thousands;
  String upvotes;
  String sub;
  String thumbnailHQ;
  String selfText;
  HtmlUnescape unescapeHTML;
  Submission s;
  SubmissionData(Submission s) {
    this.s = s;
    title = s.title;
    imgURI = s.thumbnail.toString();
    if (imgURI == "self" || imgURI == "default" || imgURI == "image") {
      thumbnail = null;
    } else {
      thumbnail = Image.network(
        s.thumbnail.toString(),
        width: 60,
        height: 60,
      );
    }
    numOfUpvotes = s.upvotes;
    if (numOfUpvotes > 9999) {
      thousands = (numOfUpvotes ~/ 1000);
      upvotes = thousands.toString() + "k";
    } else {
      upvotes = numOfUpvotes.toString();
    }
    sub = s.subreddit.displayName;
    thumbnailHQ = s.url.toString();
    getPostSelfText();
  }
  void getPostSelfText() {
    selfText = "";
    if (s.selftext != null) {
      selfText = s.selftext;
      unescapeHTML = HtmlUnescape();
      selfText = unescapeHTML.convert(selfText);
    }
  }
}
