import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart';
import '../../../state/configs.dart';
import '../../home/components/report_confirm_dialog.dart';
import '../../home/fragments/navs/report.dart';
import '../details.dart';

class ToDownloadFragment extends StatefulWidget {
  const ToDownloadFragment(
      {super.key,
      this.dash,
      required this.title,
      this.fileName,
      this.torrents,
      this.isSpecial = false});

  final String? dash;
  final String title;
  final String? fileName;
  final List<dynamic>? torrents;
  final bool isSpecial;

  @override
  State<ToDownloadFragment> createState() => _ToDownloadFragmentState();
}

class _ToDownloadFragmentState extends State<ToDownloadFragment> {
  late final String masterUrl = widget.dash ?? '';

  bool _isDownloading = false;

  bool get isDownloading => _isDownloading;

  set isDownloading(bool value) {
    setState(() {
      _isDownloading = value;
    });
  }

  Future<void> _launchDownloadManager(url) async {
    await Future.delayed(Duration.zero, () async {});
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_main',
        package: 'com.dv.adm',
        componentName: 'com.dv.adm.AEditor',
        arguments: <String, dynamic>{
          'android.intent.extra.TEXT': url,
          'com.android.extra.filename': widget.fileName,
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
      toast(pleaseInstallADMText,
          gravity: ToastGravity.TOP); // Use the variable
      showModalBottomSheet(
        isDismissible: false,
        barrierLabel: installDownloadManagerText, // Use the variable
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                title: Text(
                  installDownloadManagerText, // Use the variable
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  installADMInstructionText, // Use the variable
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: Text(
                  installText, // Use the variable
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                title: Text(
                  cancelText, // Use the variable
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

  final List<String> additionalTrackers = [
    "udp://tracker.internetwarriors.net:1337/announce",
    "udp://tracker.cyberia.is:6969/announce",
    "udp://tracker.torrent.eu.org:451/announce",
    "udp://tracker.tiny-vps.com:6969/announce",
    "udp://open.stealth.si:80/announce",
  ];

  String createMagnetLink(String hash, String title) {
    String baseUrl = 'magnet:?xt=urn:btih:';
    final String encodedName = Uri.encodeComponent(title);
    final String trackerParams = (trackers + additionalTrackers)
        .map((tracker) => '&tr=${Uri.encodeComponent(tracker)}')
        .join('');
    return '$baseUrl$hash&dn=$encodedName$trackerParams';
  }

  @override
  void initState() {
    super.initState();
    createBannerAd();
  }

  void _showFileNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oops'),
          content: const Text('File not found'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
    final bool isRealDevice = configsProvider.isRealDevice;
    return Scaffold(
      bottomNavigationBar: configsProvider.showBannerAds
          ? bannerAd != null
              ? Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AdWidget(ad: bannerAd!),
                )
              : null
          : null,
      appBar: AppBar(title: Text(downloadOptionsTitle)), // Use the variable
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
                if (widget.dash == null && widget.torrents == null)
                  Text(
                    sorryNoDownloadLinksText, // Use the variable
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                if (widget.dash != null)
                  Column(
                    children: [
                      Card(
                        child: ListTile(
                          onTap: () {
                            if (!isRealDevice) {
                              _showFileNotFoundDialog(context);
                            } else {
                              _launchDownloadManager(masterUrl);
                            }
                          },
                          title: Text(downloadUsingADMText), // Use the variable
                          leading: const Icon(Icons.file_download_outlined),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Card(
                        child: ListTile(
                          onTap: () {
                            if (!isRealDevice) {
                              _showFileNotFoundDialog(context);
                            } else {
                              _launchUrl();
                            }
                          },
                          leading: const Icon(Icons.open_in_browser),
                          title: Text(
                              downloadUsingBrowserText), // Use the variable
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Card(
                        child: ListTile(
                          onTap: () async {
                            if (!isRealDevice) {
                              _showFileNotFoundDialog(context);
                            } else {
                              await Clipboard.setData(
                                  ClipboardData(text: masterUrl));
                            }
                          },
                          leading: const Icon(Icons.content_copy),
                          title: Text(copyLinkText), // Use the variable
                        ),
                      ),
                    ],
                  ),
                if (widget.torrents != null) 16.height,
                if (widget.torrents != null)
                  Text(
                    torrentsText, // Use the variable
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.torrents != null)
                  Wrap(children: [
                    for (var torrent in widget.torrents!)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.file_download_outlined),
                          title: Row(
                            children: [
                              Text(
                                "${torrent['quality']}.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(torrent['type'].toString().toUpperCase()),
                              Text(
                                torrent['video_codec'].toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              Text(" - ${torrent['size']}"),
                            ],
                          ),
                          onTap: () async {
                            if (!isRealDevice) {
                              _showFileNotFoundDialog(context);
                            } else {
                              final magnetLink = createMagnetLink(
                                  torrent['hash'], widget.title);
                              _launchDownloadManager(magnetLink);
                            }
                          },
                        ),
                      ),
                  ]),
                const SizedBox(
                  height: 16,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    children: [
                      TextSpan(
                        text: reportNoteText, // Use the variable
                      ),
                      TextSpan(
                        text: reportLinkText, // Use the variable
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final bool? result = await showDialog(
                                context: context,
                                builder: (_) => const ReportConfirmDialog());
                            if (result ?? false) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ReportNav(
                                  contentId: id,
                                  contentType: type,
                                  contentTitle: title,
                                ),
                              ));
                            }
                          },
                      ),
                      TextSpan(
                        text: reportNotifyText, // Use the variable
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<String> trackers = [
    "udp://open.demonii.com:1337/announce",
    "udp://tracker.openbittorrent.com:80",
    "udp://tracker.coppersurfer.tk:6969",
    "udp://glotorrents.pw:6969/announce",
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://torrent.gresille.org:80/announce",
    "udp://p4p.arenabg.com:1337",
    "udp://tracker.leechers-paradise.org:6969",
    "udp://explodie.org:6969",
    "udp://tracker.tiny-vps.com:6969/announce",
    "udp://denis.stalker.upeer.me:6969/announce",
    "udp://tracker.internetwarriors.net:1337/announce",
    "udp://9.rarbg.to:2710/announce",
    "udp://tracker.cyberia.is:6969/announce",
    "udp://tracker.uw0.xyz:6969/announce",
    "udp://tracker.zer0day.to:1337/announce",
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://retracker.lanta-net.ru:2710/announce",
    "udp://tracker.port443.xyz:6969/announce",
    "udp://public.popcorn-tracker.org:6969/announce",
    "udp://tracker.moeking.me:6969/announce",
    "udp://bt.okmp3.ru:2710/announce",
    "udp://ipv4.tracker.harry.lu:80/announce",
    "udp://bt.xxx-tracker.com:2710/announce",
    "udp://tracker.filepit.to:6969/announce",
    "udp://tracker.swateam.org.uk:2710/announce",
    "udp://tracker.nibba.trade:1337/announce",
    "udp://tracker.flashtorrents.org:6969/announce",
    "udp://tracker.vanitycore.co:6969/announce",
    "udp://tracker1.itzmx.com:8080/announce",
    "udp://tracker3.itzmx.com:6961/announce",
    "udp://tracker4.itzmx.com:2710/announce",
    "udp://public.popcorn-tracker.org:6969/announce",
    "udp://tracker.dler.org:6969/announce",
    "udp://opentor.org:2710",
    "udp://public.popcorn-tracker.org:6969/announce",
    "udp://vibe.community:6969/announce",
    "udp://tracker.pirateparty.gr:6969/announce",
    "udp://tracker.sbsub.com:2710/announce",
    "udp://bt.aoeex.com:8000/announce",
    "udp://tracker.torrent.eu.org:451",
    "udp://tracker.dutchtracking.com:6969/announce",
    "udp://open.stealth.si:80/announce",
    "udp://tracker.vanitycore.co:6969/announce",
    "udp://explodie.org:6969/announce"
  ];
}
