import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucy/src/presentation/details/ab_download.dart';
import 'package:lucy/src/presentation/details/not_found_screen.dart';
import 'package:lucy/src/state/home_state.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../utils/ads_manager.dart';
import '../home/data_state.dart';
import 'download_screen.dart';
import 'loading_component.dart';

// import 'download_screen.dart';

class SeasonsReceiver extends StatelessWidget {
  const SeasonsReceiver({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return _SeasonsScreen(
      hiboSeasons: args["hiboSeasons"],
      waploadedSeasons: args["waploadedSeasons"],
      base: args['base'],
      title: args["title"],
      master: args['master'],
    );
  }
}

class _SeasonsScreen extends StatefulWidget {
  const _SeasonsScreen(
      {required this.base,
      required this.title,
      required this.master,
      this.hiboSeasons,
      this.waploadedSeasons});

  final String base;
  final String title;
  final String master;
  final dynamic hiboSeasons;
  final dynamic waploadedSeasons;

  @override
  State<_SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends State<_SeasonsScreen>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Server 1', icon: Icon(Icons.tv)),
    const Tab(text: 'Server 2', icon: Icon(Icons.tv)),
  ];
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  Widget _hiboSeasons({required HomeState provider}) => ListView.builder(
      itemBuilder: (context, index) {
        final episodes =
            widget.hiboSeasons[index]["episodes"].reversed.toList();
        final String seasonTitle =
            "Season ${widget.hiboSeasons[index]["season"]}";

        return Card(
          child: ExpansionTile(
              leading: const FaIcon(FontAwesomeIcons.download),
              title: Text(seasonTitle),
              subtitle: Text(
                  "Episodes: ${widget.hiboSeasons[index]["totalEpisodes"]}"),
              children: [
                for (var episode in episodes)
                  Builder(builder: (context) {
                    final String episodeCohort =
                        "Episode ${episode['episode']}";
                    final season = episode['season'];
                    final String snAndEp =
                        "${"(S${season.toString().padLeft(2, '0')}E${episode['episode'].toString().padLeft(2, '0')}".replaceAll("Season", "").replaceAll(" ", "")})";
                    final String title = "${widget.title} $snAndEp";

                    goToDownload() {
                      if (adsLow) {
                        showInterstitialAd();
                      }
                      final DataState dataState = context.read<DataState>();
                      dataState.currentSeasonTitle = seasonTitle;
                      dataState.currentEpisodeTitle = episodeCohort;

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        // if (widget.master == 'goojara' ||
                        //     (episode['available'] ?? false) == false) {
                        if (provider.hibo_master == 'wootly') {
                          if (episode['available'] == false) {
                            return LoadingComponent(
                                base: widget.base,
                                isMovie: false,
                                homeUrl: episode['href'] ?? "",
                                title: title);
                          } else if (episode['link'] != null ||
                              episode['link'] != "") {
                            {
                              return DownloadScreen(
                                  title: title,
                                  gojUrl: episode['link'],
                                  tolerance: 15000);
                            }
                          } else {
                            return NotFoundScreen();
                          }
                        }
                        return LoadingComponent(
                            base: widget.base,
                            isMovie: false,
                            homeUrl: episode['href'] ?? "",
                            title: title);
                      }));
                    }

                    return Column(
                      children: [
                        const Divider(),
                        ListTile(
                            onTap: () => goToDownload(),
                            isThreeLine: true,
                            leading: Text(
                              '${episode['episode']}',
                              style: TextStyle(
                                //natural color of button
                                color: Colors.purple.shade100,
                                fontSize: 20,
                              ),
                            ),
                            title: Text(episode["title"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${episode['date']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                ReadMoreText(
                                  episode["overview"],
                                  trimLines: 2,
                                  trimMode: TrimMode.Line,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () => goToDownload(),
                              icon: const Icon(Icons.download),
                            )),
                      ],
                    );
                  })
              ]),
        );
      },
      itemCount: widget.hiboSeasons.length);

  Widget _waploadedSeasons({required HomeState provider}) => ListView.builder(
        itemCount: widget.waploadedSeasons.length,
        itemBuilder: (context, index) {
          final String seasonTitle = widget.waploadedSeasons[index]["title"];
          return Card(
            child: ExpansionTile(
              leading: const FaIcon(FontAwesomeIcons.download),
              title: Text(seasonTitle),
              subtitle: Text(
                  "Episodes: ${widget.waploadedSeasons[index]?["episodes"].length ?? 0}"),
              children: [
                for (var episode in widget.waploadedSeasons[index]["episodes"])
                  Builder(builder: (context) {
                    final String episodeCohort = episode["title"];
                    goToDownload() {
                      if (adsLow) {
                        showInterstitialAd();
                      }
                      final DataState dataState = context.read<DataState>();
                      dataState.currentSeasonTitle = seasonTitle;
                      dataState.currentEpisodeTitle = episodeCohort;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        var episodeLink =
                            "${provider.waploaded_download_link_base}${episode["downloadLink"]}";
                        dev.log("episode link is $episodeLink");
                        return AbDownload(
                            url: episodeLink, title: episode["title"]);
                      }));
                    }

                    return ListTile(
                      onTap: () => goToDownload(),
                      title: Text(episode["title"]),
                      subtitle: ReadMoreText(
                        episode["description"],
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                      ),
                      trailing: IconButton(
                        onPressed: () => goToDownload(),
                        icon: const Icon(Icons.download),
                      ),
                    );
                  })
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    // dev.log("seasons ====\n\n" + widget.seasons.toString());
    final provider = context.watch<HomeState>();
    return Scaffold(
        appBar: AppBar(
            title: const Text("Seasons"),
            bottom: widget.master == 'waploaded'
                ? widget.hiboSeasons == null || widget.hiboSeasons.isEmpty
                    ? null
                    : TabBar(
                        controller: _tabController,
                        tabs: myTabs,
                      )
                : null),
        body: widget.master == 'waploaded'
            ? widget.hiboSeasons == null || widget.hiboSeasons.isEmpty
                ? _waploadedSeasons(provider: provider)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _hiboSeasons(provider: provider),
                      _waploadedSeasons(provider: provider),
                    ],
                  )
            : _hiboSeasons(provider: provider));
  }
}
