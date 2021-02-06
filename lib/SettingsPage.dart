import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter4reddit/models/RedditModel.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          InkWell(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: Text(
                    "Sign out of account",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () async {
                  await Provider.of<RedditModel>(context, listen: false)
                      .signOutUser();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
