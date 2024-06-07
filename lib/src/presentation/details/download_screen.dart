import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'not_found_screen.dart';
import 'to_download_screen.dart';

class DownloadReceiver extends StatelessWidget {
  const DownloadReceiver({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return DownloadScreen(
      gojUrl: args["gojUrl"],
      tolerance: args["tolerance"],
      title: args["title"],
    );
  }
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen(
      {super.key,
        required this.gojUrl,
        required this.tolerance,
        required this.title});

  final String gojUrl;
  final int tolerance;
  final String title;

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late final String gojUrl = widget.gojUrl;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  Future _getGRD(
      {required String iframeUrl, required BuildContext context}) async {
    try {
      final headers = {
        'authority': 'www.goojara.to',
        'sec-ch-ua':
        '"Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"',
        'accept': '*/*',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'origin': 'https://www.goojara.to',
        'sec-fetch-site': 'same-origin',
        'sec-fetch-mode': 'cors',
        'sec-fetch-dest': 'empty',
        'referer': gojUrl,
        'accept-language': 'en-US,en;q=0.9',
        'Cookie':
        "wooz=9hbfufc34doqqs4vn6376gl051; sncsu=ObIghC; krnyl=NBpQHS; qzsdz=YNCGeI",
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };
      final body = {
        "qdf": "1",
      };
      debugPrint(
          '\n\n\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n\n\n\n');
      debugPrint("iframeUrl: $iframeUrl");

      await http
          .post(Uri.parse(iframeUrl),
          headers: headers,
          body: body,
          encoding: Encoding.getByName('utf-8'))
          .then((response) {
        if (response.statusCode == 200) {
          final source = response.body;
          debugPrint(
              '\n\n\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n\n\n\n');
          debugPrint("source: $source");
          String constructedUrl = constructUrl(source);
          debugPrint(
              '\n\n\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n\n\n\n');
          debugPrint("constructedUrl: $constructedUrl");
          http.get(Uri.parse(constructedUrl), headers: headers).then((dash) {
            debugPrint(
                '\n\n\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n\n\n\n');
            debugPrint("dash: ${dash.body}");
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToDownloadScreen(
                    dash: dash.body,
                    title: widget.title,
                  ),
                ),
              );
            }
            return response.body;
          });
        } else {
          throw "Something went wrong";
        }
      });
    } on SocketException {
      throw "No Internet connection";
    } catch (e) {
      throw "Something went wrong";
    }
  }

  String constructUrl(html) {
    String extractTK() {
      int startIdx = html.indexOf('tk=');
      debugPrint("\n\n\n ========================= \n\n\n");
      debugPrint("startIdx: $startIdx");
      debugPrint("\n\n\n ========================= \n\n\n");
      int endIdx = html.indexOf(';', startIdx);
      String tk = html.substring(startIdx + 4, endIdx - 1);
      debugPrint("\n\n\n ========================= \n\n\n");
      debugPrint("tk: $tk");
      debugPrint("\n\n\n ========================= \n\n\n");
      return tk;
    }

    String extractVD() {
      int startIdx = html.indexOf('vd=');
      debugPrint("\n\n\n ========================= \n\n\n");
      debugPrint("startIdx: $startIdx");
      debugPrint("\n\n\n ========================= \n\n\n");
      int endIdx = html.indexOf(',', startIdx);
      String vd = html.substring(startIdx + 4, endIdx - 1);
      debugPrint("\n\n\n ========================= \n\n\n");
      debugPrint("vd: $vd");
      debugPrint("\n\n\n ========================= \n\n\n");
      return vd;
    }

    String tk = extractTK();
    String vd = extractVD();
    String baseUri = "https://www.wootly.ch/grabd";
    return "$baseUri?t=$tk&id=$vd";
  }

  bool checkUrlPattern(String url) {
    // Define the regular expression pattern for the URL
    RegExp regExp = RegExp(
        r'https:\/\/www\.wootly\.ch\/n\/[a-zA-Z0-9_-]+\/[0-9]+\/[0-9]+\/[a-zA-Z0-9_-]+');

    // Check if the URL matches the pattern
    return regExp.hasMatch(url);
  }

  @override
  Widget build(BuildContext context) {
    final url = gojUrl;

    return FutureBuilder(
        future: Future.delayed(
            Duration(milliseconds: widget.tolerance), () => true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == true) {
            if (kDebugMode) {
              print(
                  "snapshot: ${snapshot.data} and tolerance is ${widget.tolerance}");
            }
            // Navigator.pop(conte
            // xt);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotFoundScreen(),
                  ));
            });
          }
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text('Download'),
              ),
              body: Stack(
                children: [
                  Offstage(
                    offstage: true,
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(url)),
                      initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          useShouldOverrideUrlLoading: true,
                          useOnDownloadStart: true,
                          useOnLoadResource: true,
                          useShouldInterceptAjaxRequest: true,
                          useShouldInterceptFetchRequest: true),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webViewController = controller;
                      },
                      onLoadStart:
                          (InAppWebViewController controller, Uri? url) {},
                      onLoadStop:
                          (InAppWebViewController controller, Uri? url) async {
                        debugPrint("onLoadStop $url");
                        String html = await controller.evaluateJavascript(
                            source: 'document.documentElement.outerHTML;');
                        final realUrl = url.toString();
                        if (realUrl == gojUrl) {
                          final u2 = extractWootlyHref(html);
                          debugPrint("wootly url: $u2");
                          if (u2 != null) {
                            controller.loadUrl(
                                urlRequest: URLRequest(url: WebUri(u2)));
                          }
                        }
                      },
                      onLoadResource: (controller, resource) async {
                        if (kDebugMode) {
                          print("onLoadResource $resource");
                        }
                        if (checkUrlPattern(resource.url.toString())) {
                          if (kDebugMode) {
                            print("wootly url: ${resource.url}");
                          }
                          _getGRD(
                              iframeUrl: resource.url.toString(),
                              context: context);
                        }
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        if (kDebugMode) {
                          print(
                              "shouldOverrideUrlLoading ${navigationAction.request.url}");
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        if (kDebugMode) {
                          print("console message: ${consoleMessage.message}");
                        }
                      },
                      onProgressChanged: (controller, progress) {
                        if (kDebugMode) {
                          print("progress: $progress");
                        }
                      },
                      onAjaxReadyStateChange: (controller, ajax) async {
                        if (kDebugMode) {
                          print("ajax: ${ajax.url}");
                        }
                        return AjaxRequestAction.PROCEED;
                      },
                      onAjaxProgress: (controller, ajax) async {
                        if (kDebugMode) {
                          print("ajax: ${ajax.url}");
                        }
                        return AjaxRequestAction.PROCEED;
                      },
                      onCreateWindow: (controller, createWindowRequest) async {
                        if (kDebugMode) {
                          print(
                              "onCreateWindow: ${createWindowRequest.request.url}");
                        }
                        return false;
                      },
                    ),
                  ),
                  const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text("Loading..."),
                        ],
                      )),
                ],
              ));
        });
  }

  String? extractWootlyHref(String html) {
    dom.Document document = parse(html);
    List<dom.Element> links = document.querySelectorAll('.bcg');

    for (dom.Element link in links) {
      if (link.text.contains('wootly')) {
        return link.attributes['href'];
      }
    }

    return null;
  }
}