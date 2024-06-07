import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/functions.dart';
import 'to_download_screen.dart';



class LoadMst extends StatefulWidget {
  const LoadMst(
      {super.key,
        required this.url,
        // this.supportMultipleWindows = true,
        this.isDownloading = true,
        required this.title,
        this.rootImageUrl,
        required this.type});

  final String url;

  // final bool supportMultipleWindows;
  final bool isDownloading;
  final String title;
  final String? rootImageUrl;
  final String type;

  @override
  State<LoadMst> createState() => _LoadMstState();
}

class _LoadMstState extends State<LoadMst> {
  late String url = widget.url;
  late bool isDownloading = widget.isDownloading;
  late String title = widget.title;

  // late String rootImageUrl = widget.rootImageUrl;
  late String type = widget.type;
  late Future<String?> aa;

  Future<String?> get _aa async {
    var grdurl = await getGrbdurl(url);
    if (grdurl != null) {
      var masterUrl = await getMasterurl(grdurl.grdurl);
      return masterUrl;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    aa = _aa;
  }

  restart() {
    setState(() {
      aa = _aa;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: aa,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.done) {
                if (snap.data == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Failed to load $type url',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);

                          ///todo: retry
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.black54,
                        ),
                        label: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                      )
                    ],
                  );
                } else {
                  final uri = snap.data;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    if (isDownloading) {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ToDownloadScreen(
                                dash: "$uri",
                                title: title,
                              )));
                    } else {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ToDownloadScreen(
                                dash: "$uri",
                                title: title,
                              )));
                    }
                  });
                }
              }
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("Almost there...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                ],
              );
            }));
  }
}

extension StringExt on String {
  _aa(wrd) => substring(indexOf(wrd) + 4);
  get _a => _aa('vd="');
  get _b => _aa('tk="');
  get _id => _a.substring(0, _a.indexOf('"'));
  get _tk => _b.substring(0, _b.indexOf('"'));
  String get grdurl => 'https://www.wootly.ch/grabd?t=$_tk&id=$_id';
}