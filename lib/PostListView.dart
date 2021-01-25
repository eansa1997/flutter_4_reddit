import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/SubmissonData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as mkDwn;

import 'package:url_launcher/url_launcher.dart';

class PostListView extends StatefulWidget {
  SubmissionData data;
  List<dynamic> comments = new List();
  PostListView(SubmissionData d) {
    data = d;
  }
  @override
  State<StatefulWidget> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  Future<void> getComments() async {
    widget.comments = await widget.data.getComments();
    setState(() {});
  }

  @override
  void initState() {
    getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //sub = Provider.of<RedditModel>(context, listen: false).currentPosts[index];
    Comment c;
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.blueGrey,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
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
                      "${widget.data.getUpvotes()}  -  ${widget.comments.length} comments",
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
        c = widget.comments[index - 1];

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
      },
      itemCount: widget.comments.length + 1,
    );
  }
}
