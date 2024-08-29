import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'forum_cohort.dart';
import 'forum_tab.dart';
import 'forum_text_field.dart';

class ForumSubTab extends StatefulWidget {
  const ForumSubTab(
      {super.key, required this.forum, this.showKeyBoardImmediately = false});

  final Map<String, dynamic> forum;
  final bool showKeyBoardImmediately;

  @override
  State<ForumSubTab> createState() => _ForumSubTabState();
}

class _ForumSubTabState extends State<ForumSubTab> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForumProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("@${widget.forum['username']}"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              children: [
                ForumCohort(
                    isSpecific: true,
                    index: widget.forum["index"],
                    username: widget.forum["username"],
                    rebuild: widget.forum["rebuild"],
                    controller: widget.forum["controller"])
              ],
            ),
          ),
          ForumTextField(
            call: (text) {
              final replyBody = {
                "talkId": widget.forum["isReply"] ?? false
                    ? provider.talksData[widget.forum["parentIndex"]]["id"]
                    : provider.talksData[widget.forum["index"]]["id"],
                "username": widget.forum["widgetUsername"],
                "message": text,
                "colorCode": provider.myColorCode,
              };
              provider.callReply(replyBody: replyBody);
              // Navigator.pop(context);
              //rebuild the widget
              widget.forum["rebuild"]();
            },
            showKeyBoardImmediately: widget.showKeyBoardImmediately,
            hintText: "Type your reply here ...",
          )
        ],
      ),
    );
  }
}