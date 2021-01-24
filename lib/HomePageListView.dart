import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/PostListView.dart';

import 'package:flutter4reddit/SubmissonData.dart';
import 'package:provider/provider.dart';
import 'RedditModel.dart';
import 'package:photo_view/photo_view.dart';

class HomePageListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RedditModel>(
      builder: (context, myReddit, child) => ListView.separated(
          separatorBuilder: (context, index) => Divider(
                color: Colors.blueGrey,
              ),
          itemCount: myReddit.currentPosts.length,
          itemBuilder: (context, index) {
            SubmissionData data = myReddit.getSubmissionData(index);
            Submission sub = myReddit.currentPosts[index];
            if (index == myReddit.currentPosts.length - 1) {
              // myReddit.loadMorePosts(); current method re downloads ALL tho posts instead of lazy loading
              // widgets rebuild unneccarily
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
                          child: Text(data.title),
                          onTap: () async {
                            //await myReddit.loadPostData(index);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PostListView(sub, data)));
                          },
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Text(
                                data.sub,
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 10),
                              ),
                            ),
                            Text(
                              "  ${data.upvotes}",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    child: Container(
                      child: data.thumbnail,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Container(
                              child: PhotoView(
                                imageProvider: NetworkImage(data.thumbnailHQ),
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