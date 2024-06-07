import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';

import 'load_mst.dart';

class WebComponent extends StatefulWidget {
  const WebComponent(
      {super.key,
        // this.webViewPopupController,
        required this.url,
        // this.supportMultipleWindows = true,
        this.isDownloading = true,
        required this.title,
        required this.type});

  // final InAppWebViewController? webViewPopupController;
  final String url;

  // final bool supportMultipleWindows;
  final bool isDownloading;
  final String title;
  final String type;

  @override
  State<WebComponent> createState() => _WebComponentState();
}

class _WebComponentState extends State<WebComponent> {
  late String url = widget.url;
  late bool isDownloading = widget.isDownloading;
  late String title = widget.title;
  late String type = widget.type;

  // bool get webAccessed => getBoolAsync(keyWebAccessed);
  int urlHit = 0;

  InAppWebViewController? webViewController;

  InAppWebViewSettings options() => InAppWebViewSettings(
    // useShouldOverrideUrlLoading: false,
    // mediaPlaybackRequiresUserGesture: false,
      javaScriptCanOpenWindowsAutomatically: true,
      // supportMultipleWindows: widget.supportMultipleWindows,
      supportMultipleWindows: true,
      useShouldInterceptRequest: true);

  final InAppWebViewSettings options2 = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    // mediaPlaybackRequiresUserGesture: false,
    javaScriptCanOpenWindowsAutomatically: true,
    useShouldInterceptAjaxRequest: true,
    // useShouldInterceptFetchRequest: true
    useShouldInterceptRequest: true,
  );

  Widget _web(BuildContext context) => InAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    initialSettings: options2,
    onWebViewCreated: (controller) {
      webViewController = controller;
    },
    shouldInterceptRequest: (controller, request) async {
      // log(" androidShouldInterceptRequest: $request");
      final uri = request.url;
      final params = uri.queryParameters;
      if (params["usr"] != null
      // &&
      //  widget.supportMultipleWindows
      ) {
        log("$uri");
        // if(webAccessed){
        //   if (isDownloading) {
        //     finish(context);
        //     KFMovieResults(
        //       masterUrl: "$uri",
        //       title: title,
        //       isDownloading: isDownloading,
        //     ).launch(context);
        //   } else {
        //     finish(context);
        //     KFVideoPlayerScreen(
        //       masterUrl: "$uri",
        //     ).launch(context);
        //   }
        // }
        // await setValue(keyWebAccessed, true);
      }

      return null;
    },
    onAjaxReadyStateChange: (controller, ajaxRequest) async {
      // log("onAjaxReadyStateChange: ${ajaxRequest.responseText}");
      String response = ajaxRequest.responseText ?? "";
      if (response != "") {
        var document = parse(response);

        final iframe = document.getElementsByTagName("iframe");
        if (iframe.isNotEmpty) {
          final srcDoc = iframe[0].attributes["src"];

          final masterUrl = srcDoc;
          log('MASTER URL: $masterUrl');
          if (Uri.tryParse(masterUrl ?? "")?.hasAbsolutePath ?? false) {
            // finish(context);
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LoadMst(url: masterUrl!, title: title, type: type);
            }));
            // controller
            //     .loadUrl(
            //         urlRequest: URLRequest(url: Uri.parse(masterUrl ?? "")))
            //     .then((value) => controller.setOptions(options: options()));
          }
        }
      }
      return AjaxRequestAction.PROCEED;
    },
    shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
      // log("shouldInterceptAjaxRequest: $ajaxRequest");
      return ajaxRequest;
    },
    onAjaxProgress:
        (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
      // log("STATUS CODE", error: ajaxRequest.status);
      return AjaxRequestAction.PROCEED;
    },
    shouldInterceptFetchRequest: (controller, fetchRequest) async {
      // log("shouldInterceptFetchRequest: $fetchRequest");
      return fetchRequest;
    },
    onReceivedServerTrustAuthRequest: (controller, challenge) async {
      // log("onReceivedServerTrustAuthRequest: $challenge");
      return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED);
    },
    onLoadStart: (controller, url) {
      if ("$url".contains("prime")) {
        controller
            .loadUrl(urlRequest: URLRequest(url: WebUri(this.url)))
            .then((value) => controller.setSettings(settings: options2));
      }
    },
    shouldOverrideUrlLoading: (controller, navigationAction) async {
      var uri = navigationAction.request.body;

      log("shouldOverrideUrlLoading: $uri");

      return NavigationActionPolicy.CANCEL;
    },
    onLoadStop: (controller, url) async {
      await controller.evaluateJavascript(source: '''
document.getElementById('prime').click()
''');
    },
    onProgressChanged: (controller, progress) {},
    onUpdateVisitedHistory: (controller, url, androidIsReload) {},
    onConsoleMessage: (controller, consoleMessage) {
      // log("onConsoleMessage: ${jsonDecode("$consoleMessage")}");
    },
  );

  @override
  Widget build(BuildContext context) {
    log("running web");
    return _web(context);
  }
}