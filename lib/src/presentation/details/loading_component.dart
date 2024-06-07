import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'not_found_screen.dart';
import 'web_component.dart';


class LoadingComponent extends StatefulWidget {
  const LoadingComponent(
      {super.key,
        required this.isMovie,
        required this.homeUrl,
        required this.title, required this.base});

  final bool isMovie;
  final String homeUrl;
  final String title;
  final String base;

  @override
  State<LoadingComponent> createState() => _LoadingComponentState();
}

class _LoadingComponentState extends State<LoadingComponent> {
  late String url;
  late final bool isMovie = widget.isMovie;
  late final String title = widget.title;

  @override
  void initState() {
    final dummyUrl = widget.homeUrl.split('/');
    //take the last element
    final lastElement = dummyUrl.last;
    //make the full url using the base url
    url = "${widget.base}/$lastElement";
    dev.log('Url for loading component set to $url');
    _setDelayed();
    super.initState();
  }

  // bool _delayed = false;
  // bool get delayed => _delayed;

  Future _setDelayed() async {
    await Future.delayed(const Duration(seconds: 25));
    // setState(() => _delayed = true);
    simulateDownloadProcess();
  }

  bool isProcessing = true; // Set to true initially

  // Simulating a delay of 5 seconds before handling the timeout scenario
  Future<void> simulateDownloadProcess() async {
    // After the delay, check if the process is still ongoing
    if(mounted) {
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotFoundScreen(),
            ));
      });
    }
  }

  @override
  void dispose() {
    isProcessing = false; // Set to false when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (!_delayed)
            const Column(
              children: [
                SpinKitFadingCircle(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  "Please wait while we generate the download link...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Do not close this screen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            _web(title: title)
          ],
        ),
      ),
    );
  }

  Widget _web({required String title}) => Offstage(
    offstage: true,
    child: SizedBox(
      height: 700,
      width: 500,
      child: WebComponent(
          url: url, title: title, type: isMovie ? 'movie' : 'tv'),
    ),
  );
}