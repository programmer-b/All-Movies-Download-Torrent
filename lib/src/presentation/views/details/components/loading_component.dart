import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../utils/strings.dart';
import '../fragments/to_download_fragment.dart';
import 'web_component.dart';

class LoadingComponent extends StatefulWidget {
  const LoadingComponent(
      {super.key,
        required this.isMovie,
        required this.homeUrl,
        required this.title,
        required this.base,
        required this.fileName,
        this.torrents});

  final bool isMovie;
  final String homeUrl;
  final String title;
  final String base;
  final String fileName;
  final List<dynamic>? torrents;

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

  Future _setDelayed() async {
    await Future.delayed(const Duration(seconds: 25));
    simulateDownloadProcess();
  }

  bool isProcessing = true; // Set to true initially

  Future<void> simulateDownloadProcess() async {
    if(mounted) {
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToDownloadFragment(title: title),
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
             Column(
              children: [
                const SpinKitFadingCircle(
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  pleaseWaitText, // Use the variable
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  doNotCloseScreenText, // Use the variable
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
          fileName: widget.fileName,
          url: url,
          title: title,
          type: isMovie ? 'movie' : 'tv',
          torrents: widget.torrents),
    ),
  );
}
