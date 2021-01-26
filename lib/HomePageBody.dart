import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter4reddit/PostListView.dart';

import 'package:flutter4reddit/SubmissonData.dart';
import 'package:provider/provider.dart';
import 'RedditModel.dart';
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
  StreamController
      _controller; // 1 = loading, 2 = error with API, else build list
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _controller = StreamController();
    _stream = _controller.stream;
    _controller.add(1);
    Provider.of<RedditModel>(widget.context, listen: false)
        .passController(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.data == 1) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == 2) {
            return Center(
              child: Text("Error loading, try again."),
            );
          }
          if (snapshot.data == 3) return PageListView();

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
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Text(data.getSubmissionTitle()),
                          onTap: () async {
                            //await myReddit.loadPostData(index);
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
