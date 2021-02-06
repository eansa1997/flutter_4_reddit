import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter4reddit/PostListView.dart';

import 'package:flutter4reddit/models/SubmissonData.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'models/RedditModel.dart';
import 'package:photo_view/photo_view.dart';

class HomePageBody extends StatefulWidget {
  BuildContext context;
  HomePageBody(BuildContext con) {
    context = con;
  }

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  StreamController _controller;
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _controller = StreamController();
    _stream = _controller.stream;
    Provider.of<RedditModel>(widget.context, listen: false)
        .passController(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: _stream,
        initialData: "loading",
        builder: (context, snapshot) {
          if (snapshot.data == "loading") {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == "error") {
            return Center(
              child: Text("Error loading, try again."),
            );
          }
          if (snapshot.data == "loaded") return PageListView();

          if (snapshot.data == "login") {
            return Container(
              child: InkWell(
                onTap: () {
                  String authUrl =
                      Provider.of<RedditModel>(context, listen: false)
                          .getAuthenticateUrl();
                  int i = authUrl.indexOf("www.");
                  authUrl = authUrl.substring(0, i) +
                      "old." +
                      authUrl.substring(i + 4);
                  print(authUrl);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_context) => WebView(
                                javascriptMode: JavascriptMode.unrestricted,
                                initialUrl: authUrl,
                                navigationDelegate: (navReq) {
                                  if (navReq.url
                                      .startsWith('https://www.google.com')) {
                                    Provider.of<RedditModel>(context,
                                            listen: false)
                                        .authenticate(navReq.url);
                                    Navigator.pop(context);
                                  }
                                  return NavigationDecision.navigate;
                                },
                              )));
                },
                child: Center(child: Text("Click to login")),
              ),
            );
          }
          return Container();
        });
  }
}

class PageListView extends StatelessWidget {
  const PageListView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RedditModel>(
      builder: (context, myReddit, child) => ListView.separated(
          separatorBuilder: (context, index) => Divider(
                color: Colors.blueGrey,
              ),
          itemCount: myReddit.getCurrentPostsLength(),
          itemBuilder: (context, index) {
            SubmissionData data = myReddit.getSubmissionData(index);
            if (index == myReddit.getCurrentPostsLength() - 1) {
              myReddit.loadMorePosts();
            }
            return Card(
              margin: EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Text(data.getSubmissionTitle()),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostListView(data)));
                          },
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Text(
                                data.getSubredditName(),
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 10),
                              ),
                            ),
                            Text(
                              "  ${data.getUpvotes()}",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    child: Container(
                      child: data.getThumbnail(),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Container(
                              child: PhotoView(
                                imageProvider:
                                    NetworkImage(data.getThumbnailHD()),
                              ),
                            ),
                          ));
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
