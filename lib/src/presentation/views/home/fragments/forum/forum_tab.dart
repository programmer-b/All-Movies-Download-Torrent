import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../../utils/urls.dart';
import '../../../auth/auth_state.dart';
import 'forum_cohort.dart';
import 'forum_text_field.dart';

class ForumTabFragment extends StatefulWidget {
  const ForumTabFragment({super.key});

  @override
  State<ForumTabFragment> createState() => _ForumTabFragmentState();
}

class _ForumTabFragmentState extends State<ForumTabFragment> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: _Talks(
        rebuild: () => setState(() {}),
      ));
}

class _Talks extends StatefulWidget {
  const _Talks({required this.rebuild});

  final void Function() rebuild;

  @override
  State<_Talks> createState() => _TalksState();
}

class _TalksState extends State<_Talks> {
  late String username;
  late ScrollController _scrollController;
  int _currentPage = 1;
  double _previousScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final String jwt = isLoggedIn ? context.read<AuthProvider>().jwt : "";
    username = isLoggedIn ? JwtDecoder.decode(jwt)?["sub"]?["username"] : "";
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ForumProvider>().talksLengths = [];
      context.read<ForumProvider>().noMoreTalks = false;
      context
          .read<ForumProvider>()
          .callTalks(username: username, page: _currentPage);
      _scrollController.addListener(() => _scrollListener());
    });
  }

  _scrollListener() {
    if (_scrollController.position.pixels > _previousScrollPosition &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent / 2) {
      //check if no more data first
      if (!context.read<ForumProvider>().noMoreTalks) {
        if (kDebugMode) print('Getting more data');
        _currentPage++;
        context
            .read<ForumProvider>()
            .callTalks(username: username, page: _currentPage);
      } else {
        if (kDebugMode) print('No more data');
      }
    }
    _previousScrollPosition = _scrollController.position.pixels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Forum',
          ),
        ),
        body: Consumer<ForumProvider>(builder: (context, provider, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.grey,
                        size: 12,
                      ),
                      SizedBox(width: 5),
                      Text('Please be polite and respectful to others',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              if (provider.talksLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                    child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                      //set physics to bouncy
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      controller: _scrollController,
                      itemCount: provider.talksData.length,
                      itemBuilder: (context, index) => ForumCohort(
                          rebuild: widget.rebuild,
                          index: index,
                          username: username,
                          controller: _scrollController)),
                )),
              ForumTextField(
                call: (text) {
                  final talkBody = {
                    "username": username,
                    "message": text,
                    "colorCode": provider.myColorCode,
                  };
                  provider.callTalk(talkBody: talkBody);
                  widget.rebuild();
                },
                showKeyBoardImmediately: false,
                hintText: 'Type your request or review here...',
              ),
            ],
          );
        }));
  }
}

class ForumProvider extends ChangeNotifier {
  //save scroll position

  double _scrollPosition = 0.0;

  double get scrollPosition => _scrollPosition;

  set scrollPosition(double value) {
    _scrollPosition = value;
    notifyListeners();
  }

  bool _talksLoading = true;

  bool get talksLoading => _talksLoading;

  List<dynamic> _talksLengths = [];

  List<dynamic> get talksLengths => _talksLengths;

  set talksLengths(List<dynamic> value) {
    _talksLengths = value;
    notifyListeners();
  }

  bool _noMoreTalks = false;

  bool get noMoreTalks => _noMoreTalks;

  set noMoreTalks(bool value) {
    _noMoreTalks = value;
    notifyListeners();
  }

  List<dynamic> _talksData = [];

  List<dynamic> get talksData => _talksData;

  set talksData(List<dynamic> value) {
    _talksData = value;
    // dev.log('Talks data: $_talksData');
    notifyListeners();
  }

  set talksLoading(bool value) {
    _talksLoading = value;
    notifyListeners();
  }

  String _myColorCode = "";

  String get myColorCode => _myColorCode;

  set myColorCode(String value) {
    _myColorCode = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> callTalks(
      {int page = 1, required String username}) async {
    //set my color code first
    if (getStringAsync("myColorCode") == "") {
      //get color code from the list randomly
      myColorCode = colorCodes[Random().nextInt(colorCodes.length)];
      await setValue("myColorCode", myColorCode);
    } else {
      myColorCode = getStringAsync("myColorCode");
    }
    try {
      if (page == 1) _talksLoading = true;
      final uri = Uri.parse('$talks?page=$page&username=$username');
      dev.log('Uri: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // dev.log('Data: ${response.body}');
        //if talks length is equal to fetched talks length no more talks
        //add talks length to talkLengths
        if (talksLengths.isNotEmpty &&
            talksLengths.contains(data['talks'].length)) {
          _noMoreTalks = true;
        }
        talksLengths = [...talksLengths, data['talks'].length];
        if (data['talks'].isEmpty) {
          _noMoreTalks = true;
        } else {
          talksData = data['talks'];
        }
        return {"connection": "successful"};
      }
      if (response.statusCode == 404) {
        return {"error": "An error occurred", "message": "No data found"};
      } else {
        return {"error": "An error occurred", "message": "Can't connect"};
      }
    } catch (e) {
      return {"error": "An error occurred", "message": "Can't connect"};
    } finally {
      _talksLoading = false;
    }
  }

  Future<bool> callTalk({required Map<String, dynamic> talkBody}) async {
    //add this talk to the list
    talksData = [talkBody, ...talksData];
    try {
      Dio dio = Dio();
      final response = await dio.post(talk, data: talkBody);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> callReply({required Map<String, dynamic> replyBody}) async {
    //add this reply to the talk
    talksData = talksData.map((e) {
      if (e["id"] == replyBody["talkId"]) {
        e["replies"] = [...e["replies"], replyBody];
      }
      return e;
    }).toList();
    try {
      Dio dio = Dio();
      final response = await dio.post(reply, data: replyBody);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> callLike({required Map<String, dynamic> likeBody}) async {
    // first of all set the liked value to true
    talksData = talksData.map((e) {
      if (e["id"] == likeBody["talkId"]) {
        if (likeBody["replyId"] != "" && likeBody["replyId"] != null) {
          //this is a reply
          e["replies"] = e["replies"].map((reply) {
            if (reply["id"] == likeBody["replyId"]) {
              reply["liked"] = !reply["liked"];
              if (reply["liked"]) {
                reply["likes"] = reply["likes"] + 1;
              } else {
                reply["likes"] = reply["likes"] - 1;
              }
              //remove the dislike if it exists
              if (reply["disliked"]) {
                reply["disliked"] = !reply["disliked"];
                reply["dislikes"] = reply["dislikes"] - 1;
              }
            }
            return reply;
          }).toList();
        } else {
          if (likeBody["action"] == "like") {
            e["liked"] = true;
            e["likes"] = e["likes"] + 1;
            if (e["disliked"]) {
              e["disliked"] = false;
              e["dislikes"] = e["dislikes"] - 1;
            }
          }
          if (likeBody["action"] == "unlike") {
            e["liked"] = false;
            e["likes"] = e["likes"] - 1;
          }
        }
      }
      return e;
    }).toList();
    try {
      Dio dio = Dio();
      final response = await dio.post(like, data: likeBody);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> callDislike({required Map<String, dynamic> dislikeBody}) async {
    //first of all set the liked value to true
    talksData = talksData.map((e) {
      if (e["id"] == dislikeBody["talkId"]) {
        if (dislikeBody["replyId"] != "" && dislikeBody["replyId"] != null) {
          //this is a reply
          e["replies"] = e["replies"].map((reply) {
            if (reply["id"] == dislikeBody["replyId"]) {
              reply["disliked"] = !reply["disliked"];
              if (reply["disliked"]) {
                reply["dislikes"] = reply["dislikes"] + 1;
              } else {
                reply["dislikes"] = reply["dislikes"] - 1;
              }
              //remove the like if it exists
              if (reply["liked"]) {
                reply["liked"] = !reply["liked"];
                reply["likes"] = reply["likes"] - 1;
              }
            }
            return reply;
          }).toList();
        } else {
          dev.log("Action is ${dislikeBody["action"]}");
          dev.log("Reply Id is ${e["replyId"]}");
          if (dislikeBody["action"] == "dislike") {
            e["disliked"] = true;
            e["dislikes"] = e["dislikes"] + 1;
            if (e["liked"]) {
              e["liked"] = false;
              e["likes"] = e["likes"] - 1;
            }
          }
          if (dislikeBody["action"] == "undislike") {
            dev.log("Action is undislike:  setting dislike to false");
            e["disliked"] = false;
            e["dislikes"] = e["dislikes"] - 1;
          }
        }
      }
      return e;
    }).toList();
    try {
      Dio dio = Dio();
      final response = await dio.post(dislike, data: dislikeBody);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> callDelete({required Map<String, dynamic> deleteBody}) async {
    //remove the talk from the list
    talksData = talksData
        .where((element) => element["id"] != deleteBody["talkId"])
        .toList();
    try {
      Dio dio = Dio();
      final response = await dio.delete(deleteTalk, data: deleteBody);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

List<String> colorCodes = [
  "0xFFB44227",
  "0xFF1E9F27",
  "0xFF1E2C5B",
  "0xFFB128AA",
  "0xFFB44227",
  "0xFF1E9F7F",
  "0xFFB2891B",
  "0xFF4E1E9F",
  "0xFF1E9F8D",
  "0xFFB12746"
];

String getTimeAgo(DateTime pastTime) {
  DateTime currentTime = DateTime.now().toUtc();
  Duration difference = currentTime.difference(pastTime).abs();

  if (difference.inSeconds < 60) {
    return "${difference.inSeconds} ${difference.inSeconds == 1 ? "second" : "seconds"}";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"}";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"}";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} ${difference.inDays == 1 ? "day" : "days"}";
  } else if ((difference.inDays / 7).floor() < 4) {
    return "${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? "week" : "weeks"}";
  } else {
    int monthsDifference = currentTime.month -
        pastTime.month +
        (12 * (currentTime.year - pastTime.year));
    if (monthsDifference == 1) {
      return "1 month";
    } else if (monthsDifference < 12) {
      return "$monthsDifference months";
    } else {
      int yearsDifference = monthsDifference ~/ 12;
      return "$yearsDifference years";
    }
  }
}
