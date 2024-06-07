import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucy/src/presentation/home/home_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

import '../../../../state/home_state.dart';
import '../../../../utils/ads_manager.dart';

class DownloadsNav extends StatefulWidget {
  const DownloadsNav({super.key, this.pushedFromDownloads = false});

  final bool pushedFromDownloads;

  @override
  State<DownloadsNav> createState() => _DownloadsNavState();
}

class _DownloadsNavState extends State<DownloadsNav> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createBannerAd();
  }

  Map<String, dynamic> downloads = getJSONAsync('downloads', defaultValue: {});

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
          leading: BackButton(
            onPressed: widget.pushedFromDownloads == true
                ? () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false)
                : null,
          ),
          title: Text('Downloads'),
        ),
        body: downloads.isEmpty ||
                downloads["movies"].isEmpty && downloads["series"].isEmpty
            ? const Center(
                child: Text(
                'No Downloads yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (downloads["movies"].isNotEmpty)
                        Text("Movies",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      if (downloads["movies"].isNotEmpty)
                        for (var entry in downloads["movies"].entries)
                          Column(
                            children: [
                              Builder(builder: (context) {
                                var poster = entry.value["poster"];
                                var title = entry.value["title"];
                                var path = entry.value["path"];
                                return Card(
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => _VideoPlayer(
                                            path: path,
                                            title: title,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: Container(
                                      width: 50 * 2 / 3,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(poster),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(title),
                                    subtitle: Text("Movie"),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final bool? value = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this file?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, false);
                                                      },
                                                      child: const Text('No')),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, true);
                                                      },
                                                      child: const Text('Yes'))
                                                ],
                                              );
                                            });

                                        if (value == true) {
                                          setState(() {
                                            downloads["movies"]
                                                .remove(entry.key);
                                          });
                                          await setValue(
                                              'downloads', downloads);
                                          //delete the path from files
                                          await 500.milliseconds.delay;
                                          _deleteFile(path);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                            ],
                          ),
                      if (downloads["series"].isNotEmpty)
                        Text("Series",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      if (downloads["series"].isNotEmpty)
                        for (var entry in downloads["series"].entries)
                          Column(
                            children: [
                              Builder(builder: (context) {
                                var poster = entry.value["poster"];
                                var title = entry.value["title"];
                                return Card(
                                  child: ListTile(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => _SeriesPage(
                                            title: title,
                                            seriesKey: entry.key,
                                          ),
                                        ),
                                      ).then((_) {
                                        // This block runs when you come back from the _SeriesPage
                                        // Refresh downloads here
                                        setState(() {
                                          downloads = getJSONAsync('downloads',
                                              defaultValue: {});
                                        });
                                      });
                                    },
                                    leading: Container(
                                      width: 50 * 2 / 3,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(poster),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(title),
                                    subtitle: Text("Series"),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                            ],
                          ),
                    ],
                  ),
                ),
              ));
  }
}

class _SeriesPage extends StatefulWidget {
  const _SeriesPage({required this.title, required this.seriesKey});

  final String title;
  final String seriesKey;

  @override
  State<_SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<_SeriesPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createBannerAd();
  }

  final Map<String, dynamic> downloads =
      getJSONAsync('downloads', defaultValue: {});

  @override
  Widget build(BuildContext context) {
    bool allSeasonsEmpty = true;
    for (var series in downloads["series"].values) {
      if (series["seasons"].isNotEmpty) {
        allSeasonsEmpty = false;
        break;
      }
    }

    // If all seasons are empty, return "Oops, nothing found"
    if (allSeasonsEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Text(
            'Oops, nothing found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
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
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              for (var entry
                  in downloads["series"][widget.title]?["seasons"]?.entries ??
                      <MapEntry<String, dynamic>>[])
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    entry.value["title"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  for (var episode in entry.value["episodes"])
                    Column(
                      children: [
                        Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => _VideoPlayer(
                                    path: episode["path"],
                                    title: episode["title"],
                                  ),
                                ),
                              );
                            },
                            title: Text(episode["title"]),
                            subtitle: Text("episode"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final bool? value = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this file?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text('No')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Yes'))
                                        ],
                                      );
                                    });

                                if (value == true) {
                                  _deleteFile(episode["path"]);
                                  await 500.milliseconds.delay;
                                  setState(() {
                                    // Remove the episode
                                    downloads["series"][widget.seriesKey]
                                                ["seasons"]
                                            [entry.value["title"]]["episodes"]
                                        .removeWhere((element) =>
                                            element["title"] ==
                                            episode["title"]);

                                    // Check if the season has other episodes
                                    if (downloads["series"][widget.seriesKey]
                                                ["seasons"]
                                            [entry.value["title"]]["episodes"]
                                        .isEmpty) {
                                      // If not, remove the season
                                      downloads["series"][widget.seriesKey]
                                              ["seasons"]
                                          .remove(entry.value["title"]);

                                      // Check if the series has other seasons
                                      if (downloads["series"][widget.seriesKey]
                                              ["seasons"]
                                          .isEmpty) {
                                        // If not, remove the series
                                        downloads["series"]
                                            .remove(widget.seriesKey);
                                      }
                                    }
                                  });

                                  await setValue('downloads', downloads);

                                  // Delete the path from files
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                ])
            ],
          ),
        ),
      ),
    );
  }
}

_deleteFile(String filePath) {
  final file = File(filePath);

  if (file.existsSync()) {
    // Use this to avoid errors if the file doesn't exist
    file.deleteSync();
    print('File deleted successfully');
  } else {
    print('File not found');
  }
}

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer({required this.path, required this.title});

  final String path;
  final String title;

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    createBannerAd();
    _videoPlayerController = VideoPlayerController.file(File(widget.path));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16/9,
      autoPlay: true,
      looping: true,
      // Try playing around with some of these other options:
      showControls: true,
      allowedScreenSleep: false,
      // useCupertinoControls: true,

      cupertinoProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.blue,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.lightGreen,
      ),

      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.white24,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // // placeholder: Container(
      //   color: Colors.grey,
      // ),
      autoInitialize: true,
    );
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
      appBar: AppBar(title: Text(widget.title)),
      body: Chewie(
        controller: _chewieController,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
