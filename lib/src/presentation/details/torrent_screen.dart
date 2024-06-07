import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';
import 'to_download_screen.dart';

class TorrentReceiver extends StatelessWidget {
  const TorrentReceiver({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return _TorrentScreen(
        torrents: args["torrents"],
        type: args["type"],
        yts: args["yts"],
        title: args["title"]);
  }
}

class _TorrentScreen extends StatelessWidget {
  const _TorrentScreen(
      {required this.torrents,
        required this.type,
        this.yts,
        required this.title});

  final dynamic torrents;
  final String type;
  final dynamic yts;
  final String title;

  @override
  Widget build(BuildContext context) {
    dev.log("torrents ====\n\n" + torrents.toString());
    dev.log("torrents is empty or null ====\n\n" + torrents.isEmpty.toString());
    if (type == "movie") {
      return _MovieTorrents(
        torrents: torrents,
        title: title,
      );
    } else {
      return _ShowTorrents(yts: torrents);
    }
  }
}

class _MovieTorrents extends StatefulWidget {
  const _MovieTorrents({required this.torrents, required this.title});

  final dynamic torrents;
  final String title;

  @override
  State<_MovieTorrents> createState() => _MovieTorrentsState();
}

class _MovieTorrentsState extends State<_MovieTorrents> {
  late final String title = widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Torrents"),
      ),
      body: ListView.builder(
        itemCount: widget.torrents.length,
        itemBuilder: (context, index) {
          final type = widget.torrents[index]["type"];
          final quality = widget.torrents[index]["quality"];
          final seeds = widget.torrents[index]["seeds"];
          final peers = widget.torrents[index]["peers"];
          final size = widget.torrents[index]["size"];
          return Card(
            child: ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.download,
                size: 30,
              ),
              title: Text("$type - $quality"),
              subtitle: Text("Seeds: $seeds - Peers: $peers - Size: $size"),
              onTap: () {
                if (adsLow) {
                  showInterstitialAd();
                }
                ToDownloadScreen(
                  title: "$title $type - $quality",
                  dash: widget.torrents[index]["url"],
                  isTorrent: true,
                ).launch(context);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ShowTorrents extends StatefulWidget {
  const _ShowTorrents({this.yts});

  final dynamic yts;

  @override
  State<_ShowTorrents> createState() => _ShowTorrentsState();
}

class _ShowTorrentsState extends State<_ShowTorrents> {
  @override
  Widget build(BuildContext context) {
    dev.log("yts ====\n\n" + widget.yts.toString());

    final data = widget.yts["data"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Torrents"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < data.length; i++)
              Builder(builder: (context) {
                final episodes = data[i]['episodes'];
                int compareEpisodes(dynamic a, dynamic b) {
                  int episodeNumberA =
                  int.parse(a["title"].replaceAll(RegExp(r'[^0-9]'), ''));
                  int episodeNumberB =
                  int.parse(b["title"].replaceAll(RegExp(r'[^0-9]'), ''));

                  return episodeNumberA - episodeNumberB;
                }

                episodes.sort(compareEpisodes);
                return Card(
                  child: ExpansionTile(
                    title: Text('${data[i]['title']}'),
                    children: [
                      for (var j = 0; j < data[i]['episodes'].length; j++)
                        ExpansionTile(
                            title: Text(data[i]['episodes'][j]['details']
                            ['info']['title']),
                            children: [
                              for (var k = 0;
                              k <
                                  data[i]['episodes'][j]['details']
                                  ['torrents']
                                      .length;
                              k++)
                                Builder(builder: (context) {
                                  final link = data[i]['episodes'][j]['details']
                                  ['torrents'][k]['link'];
                                  final titleFromLink = link
                                      .split('/')
                                      .last
                                      .replaceAll(RegExp('.torrent'), '');
                                  return ListTile(
                                    title: Text(data[i]['episodes'][j]
                                    ['details']['torrents'][k]
                                    ['serveTitle']),
                                    subtitle: Text(data[i]['episodes'][j]
                                    ['details']['torrents'][k]['quality']),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        if (adsLow) {
                                          showInterstitialAd();
                                        }
                                        ToDownloadScreen(
                                          title: titleFromLink,
                                          dash: link,
                                          isTorrent: true,
                                        ).launch(context);
                                      },
                                      child: const Text('Download'),
                                    ),
                                  );
                                })
                            ])
                    ],
                  ),
                );
              })
          ],
        ),
      ),
    );
  }
}