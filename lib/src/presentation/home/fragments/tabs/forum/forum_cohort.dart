import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:lucy/src/presentation/home/fragments/tabs/forum/forum_sub_tab.dart';
import 'package:lucy/src/presentation/home/fragments/tabs/forum/forum_tab.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/variables.dart';
import '../../../../authentication/auth_state.dart';
import 'ask_to_login.dart';

class ForumCohort extends StatefulWidget {
  const ForumCohort(
      {super.key,
      this.isReply = false,
      required this.index,
      this.parentIndex = 0,
      required this.username,
      required this.rebuild,
      required this.controller,
      this.isSpecific = false});

  final bool isReply;
  final int index;
  final int parentIndex;
  final String username;
  final void Function() rebuild;
  final ScrollController controller;
  final bool isSpecific;

  @override
  State<ForumCohort> createState() => _ForumCohortState();
}

class _ForumCohortState extends State<ForumCohort> {
  bool _showReplies = false;

  bool get showReplies => _showReplies;

  set showReplies(bool value) {
    setState(() {
      _showReplies = value;
    });
  }

  void performAction(BuildContext context, Function action) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      action();
    } else {
      showDialog(
        context: context,
        builder: (context) => AskToLogin(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForumProvider>(builder: (context, provider, child) {
      final message = widget.isReply == false
          ? provider.talksData[widget.index]["message"]
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
              ["message"];
      final username = widget.isReply == false
          ? provider.talksData[widget.index]["username"]
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
              ["username"];
      final likes = widget.isReply == false
          ? provider.talksData[widget.index]["likes"] ?? 0
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
                  ["likes"] ??
              0;
      final dislikes = widget.isReply == false
          ? provider.talksData[widget.index]["dislikes"] ?? 0
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
                  ["dislikes"] ??
              0;
      final liked = widget.isReply == false
          ? provider.talksData[widget.index]["liked"] ?? false
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
                  ["liked"] ??
              false;
      final disliked = widget.isReply == false
          ? provider.talksData[widget.index]["disliked"] ?? false
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
                  ["disliked"] ??
              false;
      final replies = widget.isReply == false
          ? provider.talksData[widget.index]["replies"] ?? []
          : [];
      final createdAt = widget.isReply == false
          ? provider.talksData[widget.index]["createdAt"]
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
              ["createdAt"];
      final colorCode = widget.isReply == false
          ? provider.talksData[widget.index]["colorCode"]
          : provider.talksData[widget.parentIndex]["replies"][widget.index]
              ["colorCode"];
      final Map<String, dynamic> forum = {
        "username": username,
        "widgetUsername": widget.username,
        "message": message,
        "likes": likes,
        "dislikes": dislikes,
        "liked": liked,
        "disliked": disliked,
        "replies": replies,
        "createdAt": createdAt,
        "colorCode": colorCode,
        "index": widget.index,
        "parentIndex": widget.parentIndex,
        "rebuild": widget.rebuild,
        "controller": widget.controller,
        "isReply": widget.isReply,
      };
      return Column(
        children: [
          Card(
            child: ListTile(
              onTap: widget.isReply || widget.isSpecific
                  ? null
                  : () => performAction(
                      context,
                      () => ForumSubTab(forum: forum).launch(context,
                          pageRouteAnimation: PageRouteAnimation.Slide)),
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundColor: Color(username == widget.username
                    ? int.parse(provider.myColorCode)
                    : int.parse(
                        colorCode ?? colorCodes[Random().nextInt(100)])),
                child: Text(username[0].toUpperCase()),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "@$username",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  const Icon(Icons.circle, size: 5, color: Colors.grey),
                  const SizedBox(width: 2.5),
                  Builder(builder: (context) {
                    final timeStamp = DateTime.parse(
                        createdAt ?? DateTime.now().toIso8601String());
                    return Text(
                      getTimeAgo(timeStamp),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    );
                  })
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => performAction(context, () async {
                          final id = widget.isReply
                              ? provider.talksData[widget.parentIndex]["id"]
                              : provider.talksData[widget.index]["id"];
                          if (id == null || id == "") {
                            toast("Refresh the page in order to like this talk",
                                length: Toast.LENGTH_LONG);
                            return;
                          }
                          final replyId = widget.isReply
                              ? provider.talksData[widget.parentIndex]
                                  ["replies"][widget.index]["id"]
                              : "";
                          if (widget.isReply) {
                            if (replyId == null || replyId == "") {
                              toast(
                                  "Refresh the page in order to like this talk",
                                  length: Toast.LENGTH_LONG);
                              return;
                            }
                          }
                          if (liked) {
                            await provider.callLike(likeBody: {
                              "talkId": id,
                              "username": widget.username,
                              "replyId": replyId,
                              "action": "unlike"
                            });
                          } else {
                            await provider.callLike(likeBody: {
                              "talkId": id,
                              "username": widget.username,
                              "replyId": replyId,
                              "action": "like"
                            });
                          }
                        }),
                        child: Row(
                          children: [
                            Icon(
                              size: 17,
                              liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              color: liked ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text("${likes ?? 0}",
                                style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () => performAction(context, () async {
                          final id = widget.isReply
                              ? provider.talksData[widget.parentIndex]["id"]
                              : provider.talksData[widget.index]["id"];
                          if (id == null || id == "") {
                            toast(
                                "Refresh the page in order to dislike this talk",
                                length: Toast.LENGTH_LONG);
                            return;
                          }
                          final replyId = widget.isReply
                              ? provider.talksData[widget.parentIndex]
                                  ["replies"][widget.index]["id"]
                              : "";
                          dev.log("Reply id is $replyId");
                          if (widget.isReply) {
                            if (replyId == null || replyId == "") {
                              toast(
                                  "Refresh the page in order to dislike this talk",
                                  length: Toast.LENGTH_LONG);
                              return;
                            }
                          }
                          if (disliked) {
                            await provider.callDislike(dislikeBody: {
                              "talkId": id,
                              "username": widget.username,
                              "replyId": replyId,
                              "action": "undislike"
                            });
                          } else {
                            await provider.callDislike(dislikeBody: {
                              "talkId": id,
                              "username": widget.username,
                              "replyId": replyId,
                              "action": "dislike"
                            });
                          }
                        }),
                        child: Row(
                          children: [
                            Icon(
                              size: 17,
                              disliked
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              color: disliked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text("${dislikes ?? 0}",
                                style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      if (widget.isSpecific == false)
                        if (widget.isReply == false)
                          InkWell(
                            onTap: () => performAction(
                                context,
                                () => ForumSubTab(
                                      forum: forum,
                                      showKeyBoardImmediately: true,
                                    ).launch(context)),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.reply,
                                  size: 17,
                                ),
                                if (!widget.isReply) const SizedBox(width: 5),
                                if (!widget.isReply)
                                  Text(replies.length.toString(),
                                      style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                      if (!widget.isReply)
                        if (username == widget.username &&
                            widget.isSpecific == false)
                          const SizedBox(width: 15),
                      if (!widget.isReply)
                        if (username == widget.username &&
                            widget.isSpecific == false)
                          InkWell(
                            child: const Icon(
                              Icons.delete,
                              size: 17,
                              color: Colors.red,
                            ),
                            onTap: () => performAction(context, () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this talk?'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            //delete the talk
                                            final deleteBody = {
                                              "talkId": provider
                                                      .talksData[widget.index]
                                                  ["id"],
                                            };
                                            provider.callDelete(
                                                deleteBody: deleteBody);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No'),
                                        )
                                      ],
                                    );
                                  });
                            }),
                          ),
                      if (!widget.isSpecific)
                        Row(
                          children: [
                            if (!widget.isReply)
                              if (replies.length > 0) const SizedBox(width: 15),
                            if (!widget.isReply)
                              if (replies.length > 0)
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                        showReplies
                                            ? 'Hide replies'
                                            : 'Show replies',
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.blue)),
                                  ),
                                  onTap: () {
                                    showReplies = !showReplies;
                                  },
                                ),
                          ],
                        )
                    ],
                  )
                ],
              ),
            ),
          ),
          if ((showReplies && replies.length > 0) || widget.isSpecific)
            ListView.builder(
              controller: widget.controller,
              shrinkWrap: true,
              itemCount: replies.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(
                      width: context.width() * 0.85,
                      child: ForumCohort(
                        parentIndex: widget.index,
                        index: index,
                        isReply: true,
                        username: widget.username,
                        controller: widget.controller,
                        rebuild: widget.rebuild,
                      ),
                    ),
                  ],
                );
              },
            )
        ],
      );
    });
  }
}
