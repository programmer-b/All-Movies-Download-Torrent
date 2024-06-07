import 'dart:io';
import 'dart:developer' as dev;

import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucy/src/presentation/details/download_file.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';

class ToDownloadScreen extends StatefulWidget {
  const ToDownloadScreen(
      {super.key,
      required this.dash,
      required this.title,
      this.isTorrent = false});

  final String dash;
  final String title;
  final bool isTorrent;

  @override
  State<ToDownloadScreen> createState() => _ToDownloadScreenState();
}

class _ToDownloadScreenState extends State<ToDownloadScreen> {
  late final String masterUrl = widget.dash;

  bool _isDownloading = false;

  bool get isDownloading => _isDownloading;

  set isDownloading(bool value) {
    setState(() {
      _isDownloading = value;
    });
  }

  Widget _downloadingComponent({required BuildContext context}) {
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Please wait ...'),
        ],
      ),
    );
  }

  Future<File> downloadTorrent(context) async {
    dev.log('Downloading torrent file');
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => _downloadingComponent(context: context));
    Dio dio = Dio();
    try {
      var dir = await getExternalStorageDirectory();
      var filePath = "${dir?.path}/myFile.torrent";
      dev.log('File path: $filePath');

      // Delete the file if it exists
      var file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await dio.download(widget.dash, filePath);
      dev.log('Download complete');
      return file;
    } catch (e) {
      dev.log('Error downloading torrent file: $e');
      rethrow;
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _downloadAndOpenTorrent({required BuildContext context}) async {
    try {
      File torrentFile = await downloadTorrent(context);
      var fileLength = await torrentFile.length();
      dev.log('File length: $fileLength');

      // Open the file directly with the best available application
      final response = await OpenFile.open(torrentFile.path,
          type: 'application/x-bittorrent', uti: 'org.bittorrent.torrent');

      if (response.type == ResultType.error) {
        // If no app can handle the file, throw an exception
        throw Exception('No app found to open the file');
      }
    } catch (e) {
      dev.log('Error downloading and opening torrent file: $e');
      _installADM(e);
    }
  }

  Future<void> _launchDownloadManager() async {
    await Future.delayed(Duration.zero, () async {});
    String url = masterUrl;
    String fileName = widget.title;

    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_main',
        package: 'com.dv.adm',
        componentName: 'com.dv.adm.AEditor',
        arguments: <String, dynamic>{
          'android.intent.extra.TEXT': url,
          'com.android.extra.filename': "$fileName.mp4",
        },
      );
      await intent.launch();
    } on Exception catch (e) {
      _installADM(e);
    }
  }

  Future<void> _installADM(e) async {
    if (kDebugMode) print(e);
    if (mounted) {
      toast("Please install ADM to download this file",
          gravity: ToastGravity.TOP);
      showModalBottomSheet(
        isDismissible: false,
        barrierLabel: 'Install Download Manager',
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              const ListTile(
                title: Text(
                  'Install Download Manager',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const ListTile(
                title: Text(
                  'To download this video, install download manager',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: const Text(
                  'INSTALL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  try {
                    AndroidIntent intent = const AndroidIntent(
                      action: 'action_view',
                      data:
                          'https://play.google.com/store/apps/details?id=com.dv.adm',
                    );
                    await intent.launch();
                  } on Exception catch (e) {
                    toast(
                      "$e",
                      gravity: ToastGravity.TOP,
                    );
                  }
                },
              ),
              ListTile(
                title: const Text(
                  'CANCEL',
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(masterUrl))) {
      throw Exception('Could not launch $masterUrl');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createBannerAd();
  }

  //
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   bannerAd?.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeState>();
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
      appBar: AppBar(title: const Text('Download Options')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Card(
                  child: ListTile(
                    title: const Text(
                      "Download using ADM",
                    ),
                    onTap: () => !isRealDevice &&
                            watcher.hideContentForEmulators
                        ? showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Oops! Content not available'),
                              content: const Text('Please try again later'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          )
                        : widget.isTorrent
                            ? _downloadAndOpenTorrent(context: context)
                            : _launchDownloadManager(),
                    leading: const Icon(Icons.file_download_outlined),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                if (!widget.isTorrent)
                  Card(
                    child: ListTile(
                      onTap: !isRealDevice && watcher.hideContentForEmulators
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Oops! Content not available'),
                                  content: const Text('Please try again later'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : _launchUrl,
                      leading: const Icon(Icons.open_in_browser),
                      title: const Text("Download using Browser"),
                    ),
                  ),
                const SizedBox(
                  height: 8,
                ),
                if (!widget.isTorrent)
                  Card(
                    child: ListTile(
                      onTap: !isRealDevice && watcher.hideContentForEmulators
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Oops! Content not available'),
                                  content: const Text('Please try again later'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : () => DownloadFile(
                                url: widget.dash,
                                title: widget.title,
                              ).launch(context),
                      leading: const Icon(Icons.download_for_offline),
                      title: Row(
                        children: [
                          const Text("Download Here"),
                          // Subtle new label
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!widget.isTorrent)
                  if (!(!isRealDevice && watcher.hideContentForEmulators))
                    const SizedBox(
                      height: 8,
                    ),
                if (!widget.isTorrent)
                  if (!(!isRealDevice && watcher.hideContentForEmulators))
                    Card(
                      child: ListTile(
                        onTap: () async => await Clipboard.setData(
                            ClipboardData(text: masterUrl)),
                        leading: const Icon(Icons.content_copy),
                        title: const Text(
                          "Copy Link",
                        ),
                      ),
                    ),
                // ElevatedButton.icon(
                //   onPressed: () async => await Share.share(masterUrl),
                //   icon: const Icon(Icons.share),
                //   label: const Text(
                //     "Share Link",
                //   ),
                // ),
                if (!widget.isTorrent)
                  if (!(!isRealDevice && watcher.hideContentForEmulators))
                  const SizedBox(
                    height: 8,
                  ),
                if (!widget.isTorrent)
                  if (!(!isRealDevice && watcher.hideContentForEmulators))
                  Card(
                    child: ListTile(
                      onTap: () async => await Share.share(masterUrl),
                      leading: const Icon(Icons.share),
                      title: const Text(
                        "Share Link",
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  "Note: This app does not provide direct downloads due to restrictions. Please use the provided download link to access the movie or episode through other means.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
