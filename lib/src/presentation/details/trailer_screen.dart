import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';

class TrailerReceiver extends StatelessWidget {
  const TrailerReceiver({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final args = ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;
            return _TrailerScreen(youtubeKey: args["youtubeKey"]);
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

class _TrailerScreen extends StatefulWidget {
  const _TrailerScreen({this.youtubeKey});

  final dynamic youtubeKey;

  @override
  State<_TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<_TrailerScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
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
    createBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: adsLow
          ? bannerAd != null
          ? Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 12),
        child: AdWidget(ad: bannerAd!),
      )
          : null
          : null,
      appBar: AppBar(
        title: const Text('Trailer'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}