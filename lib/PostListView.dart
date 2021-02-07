import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/models/SubmissonData.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher.dart';

class PostListView extends StatefulWidget {
  final SubmissionData data;
  PostListView(this.data);
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
    return Scaffold(
      body: postViewStream(context),
    );
  }

  Widget postViewStream(BuildContext context) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(8, 15, 0, 5),
          child: Text(
            widget.data.getSubmissionTitle(),
            style: TextStyle(color: Colors.green),
          ),
        ),
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(8, 5, 0, 10),
          child: Text(
            "${widget.data.getUpvotes()}  -  ${(comments == null) ? 0 : comments.length} comments",
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(8, 5, 0, 10),
          child: HTML.toRichText(context, widget.data.getPostSelfText(),
              linksCallback: (link) {
            launch(link as String);
          }, defaultTextStyle: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Widget buildComment(BuildContext context, int index) {
    Comment c;
    c = comments[index - 1];
    return Material(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
            child: Text(
              c.author,
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ),
          Container(
              padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
              child: HTML.toRichText(context, c.body,
                  defaultTextStyle:
                      TextStyle(fontSize: 14, color: Colors.white),
                  linksCallback: (link) {
                launch(link as String);
              })),
        ],
      ),
    );
  }
}
