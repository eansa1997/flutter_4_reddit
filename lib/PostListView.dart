import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/models/SubmissonData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as mkDwn;

import 'package:url_launcher/url_launcher.dart';

class PostListView extends StatefulWidget {
  SubmissionData data;
  PostListView(SubmissionData d) {
    data = d;
  }
  @override
  State<StatefulWidget> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  StreamController _controller;
  Stream _stream;
  List<dynamic> comments;
  Future<void> getComments() async {
    comments = await widget.data.getComments();
    _controller.add("loaded");
  }

  @override
  void initState() {
    super.initState();
    _controller = StreamController();
    _stream = _controller.stream;
    _controller.add("loading");
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        initialData: "loading",
        builder: (context, snapshot) {
          if (snapshot.data == "loading") {
            return ListView(
              children: [
                buildSubmissionTitleAndBody(context),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            );
          }
          if (snapshot.data == "loaded") {
            return buildSubmissionListView(context);
          }
          return Container();
        });
  }

  Widget buildSubmissionListView(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildSubmissionTitleAndBody(context);
        } else {
          return buildComment(context, index);
        }
      },
      itemCount: comments.length + 1,
    );
  }

  Widget buildSubmissionTitleAndBody(BuildContext context) {
    return Card(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
              child: Text(
                widget.data.getSubmissionTitle(),
                style: TextStyle(color: Colors.green),
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 10),
              child: Text(
                "${widget.data.getUpvotes()}  -  ${(comments == null) ? 0 : comments.length} comments",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
            Html(
              data: mkDwn.markdownToHtml(widget.data.getPostSelfText(),
                  inlineSyntaxes: [new mkDwn.InlineHtmlSyntax()]),
              onLinkTap: (link) {
                launch(link);
              },
            ),
          ],
        ));
  }

  Widget buildComment(BuildContext context, int index) {
    Comment c;
    c = comments[index - 1];
    return Card(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.author,
            style: TextStyle(color: Colors.blueGrey),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: Html(
              data: mkDwn.markdownToHtml(c.body,
                  inlineSyntaxes: [new mkDwn.InlineHtmlSyntax()]),
              onLinkTap: (link) {
                launch(link);
              },
            ),
          )
        ],
      ),
    );
  }
}
