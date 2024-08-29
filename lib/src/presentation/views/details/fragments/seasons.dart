import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../state/configs.dart';
import '../../../state/data_state.dart';
import '../components/fetch_from_bucket.dart';
import '../components/loading_component.dart';
import 'to_download_fragment.dart';

class SeasonsFragment extends StatefulWidget {
  const SeasonsFragment(
      {super.key,
      required this.slug,
      required this.seasons,
      required this.title});

  final String slug;
  final String title;
  final dynamic seasons;

  @override
  State<SeasonsFragment> createState() => _SeasonsFragmentState();
}

class _SeasonsFragmentState extends State<SeasonsFragment> {
  @override
  void initState() {
    super.initState();
    createBannerAd();
  }

  Widget seasons() => ListView.builder(
      itemBuilder: (context, index) {
        final configsProvider = context.watch<ConfigsProvider>();

        final episodes =
            widget.seasons["data"][index]["episodes"].reversed.toList();
        final String seasonNumber = widget.seasons["data"][index]["season"];
        final String seasonTitle =
            "Season ${widget.seasons["data"][index]["season"]}";

        return Card(
          child: ExpansionTile(
              leading: const FaIcon(FontAwesomeIcons.download),
              title: Text(seasonTitle),
              subtitle: Text(
                  "Episodes: ${widget.seasons["data"][index]["totalEpisodes"]}"),
              children: [
                for (var episode in episodes)
                  Builder(builder: (context) {
                    final season = episode['season'];
                    final String episodeNumber = episode['episode'];

                    final String episodeCohort =
                        "Episode ${episode['episode']}";

                    final String snAndEp =
                        "${"(S${season.toString().padLeft(2, '0')}E${episode['episode'].toString().padLeft(2, '0')}".replaceAll("Season", "").replaceAll(" ", "")})";
                    final String title = "${widget.title} $snAndEp";

                    final String fileName =
                        '${widget.slug}-sn-$seasonNumber-ep-$episodeNumber.mp4';

                    Future<void> goToDownload() async {
                      if (configsProvider
                          .showInterstitialBetweenDetailsAndDeep) {
                        createInterstitialAd();
                        showInterstitialAd();
                      }

                      final DataState dataState = context.read<DataState>();
                      dataState.currentSeasonTitle = seasonTitle;
                      dataState.currentEpisodeTitle = episodeCohort;
                      if (!mounted) return;
                      final bucketUrl = configsProvider.useBucket
                          ? await showDialog(
                              context: context,
                              builder: (_) {
                                return FetchFromBucket(fileName: fileName);
                              })
                          : null;
                      if (!mounted) return;
                      if (bucketUrl != null) {
                        ToDownloadFragment(
                          dash: bucketUrl,
                          title: title,
                          fileName: fileName,
                        ).launch(context);
                        return;
                      }
                      if (!mounted) return;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LoadingComponent(
                            base: 'https://www.goojara.to',
                            isMovie: false,
                            homeUrl: episode['href'] ?? "",
                            title: title,
                            fileName: fileName);
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
      itemCount: widget.seasons["data"].length);

  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
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
        appBar: AppBar(
          title: const Text("Seasons"),
        ),
        body: seasons());
  }
}
