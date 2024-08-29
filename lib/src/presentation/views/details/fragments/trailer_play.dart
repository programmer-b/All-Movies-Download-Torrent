import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrailerPlay extends StatefulWidget {
  const TrailerPlay({super.key, this.youtubeKey});

  final dynamic youtubeKey;

  @override
  State<TrailerPlay> createState() => _TrailerPlayState();
}

class _TrailerPlayState extends State<TrailerPlay> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://www.youtube.com/embed/${widget.youtubeKey}?autoplay=1'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trailer'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}