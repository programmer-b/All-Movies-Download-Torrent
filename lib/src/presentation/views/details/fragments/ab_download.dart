import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'to_download_fragment.dart';

class AbDownload extends StatefulWidget {
  const AbDownload(
      {super.key,
      required this.url,
      required this.title,
      this.fileName,
      this.torrents});

  final String url;
  final String title;
  final String? fileName;
  final List<dynamic>? torrents;

  @override
  State<AbDownload> createState() => _AbDownloadState();
}

class _AbDownloadState extends State<AbDownload> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  'Please wait...',
                ),
              ],
            ),
          ),
          Offstage(
            offstage: true,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  useOnDownloadStart: true,
                  useOnLoadResource: true,
                  useShouldInterceptAjaxRequest: true,
                  useShouldInterceptFetchRequest: true),
              onWebViewCreated: (controller) => webViewController = controller,
              onLoadResource: (controller, resource) {
                developer.log('======= onLoadResource: ${resource.url}');

                controller.evaluateJavascript(source: '''
      document.getElementById("downloadButton").click();
    ''');
              },
              onLoadStart: (controller, url) =>
                  developer.log('======= Download URL load start: $url'),
              onLoadStop: (controller, url) {
                controller.evaluateJavascript(source: '''
            document.getElementById("downloadButton").click();
                ''');
                // var url = controller.getUrl();
                // if ('$url'.contains('kissorgrab.com')) {
                //   debugPrint('======= Download URL load stop: $url');
                // }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // if (kDebugMode) {
                //   print("===========    shouldOverrideUrlLoading ${navigationAction.request.url}");
                // }
                developer.log(
                    '======= shouldOverrideUrlLoading: ${navigationAction.request.url}');
                var url = navigationAction.request.url;
                if ('$url'.contains('kissorgrab.com') ||
                    '$url'.contains('meetdownload.com')) {
                  developer.log('======= Download URL override: $url');

                  //url contains mkv
                  debugPrint(
                      '\n======= contains mkv is ${'$url'.contains('mkv')}\n');
                  if ("$url".length > 200) {
                    developer.log(
                        '======= Matches the Url =====\n\n 😎😎😎😎😎😎😎 \n\n');
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ToDownloadFragment(
                            dash: url.toString(),
                            title: widget.title,
                            fileName: widget.fileName,
                            torrents: widget.torrents,
                          );
                        },
                      ),
                    );
                  }
                }
                controller.evaluateJavascript(source: '''
            document.getElementById("downloadButton").click();
                ''');
                if ("$url".contains("meetdownload.com")) {
                  return NavigationActionPolicy.ALLOW;
                }
                return NavigationActionPolicy.CANCEL;
              },
              onConsoleMessage: (controller, consoleMessage) {
                if (kDebugMode) {
                  print("console message: ${consoleMessage.message}");
                }
              },
              onProgressChanged: (controller, progress) {
                // if (kDebugMode) {
                //   print("progress: $progress");
                // }
                developer.log('======= Download URL progress: $progress');
                var url = controller.getUrl();
                if ('$url'.contains('kissorgrab.com')) {
                  debugPrint('======= Download URL on progress: $url');
                }
              },
              onAjaxReadyStateChange: (controller, ajax) async {
                // if (kDebugMode) {
                //   print("ajax: ${ajax.url}");
                // }
                developer
                    .log('======= Download URL ajax ready state: ${ajax.url}');
                var url = ajax.url;
                if ('$url'.contains('kissorgrab.com')) {
                  debugPrint('======= Download URL ajax ready state: $url');
                }
                return AjaxRequestAction.PROCEED;
              },
              onAjaxProgress: (controller, ajax) async {
                // if (kDebugMode) {
                //   print("ajax: ${ajax.url}");
                // }
                var url = ajax.url;
                if ('$url'.contains('kissorgrab.com')) {
                  debugPrint('======= Download URL on ajax progress: $url');
                }
                return AjaxRequestAction.PROCEED;
              },
              onCreateWindow: (controller, createWindowRequest) async {
                if (kDebugMode) {
                  print("onCreateWindow: ${createWindowRequest.request.url}");
                }
                return false;
              },
              onDownloadStartRequest: (controller, url) {
                if (kDebugMode) {
                  print("onDownloadStart: $url");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// bool pushed = false;
