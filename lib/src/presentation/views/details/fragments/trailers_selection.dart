import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../state/configs.dart';
import 'trailer_play.dart';

class TrailersSelection extends StatefulWidget {
  const TrailersSelection({super.key, required this.trailers});

  final List<dynamic> trailers;

  @override
  State<TrailersSelection> createState() => _TrailersSelectionState();
}

class _TrailersSelectionState extends State<TrailersSelection> {
  @override
  void initState() {
    super.initState();
    createBannerAd();
  }

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
        title: const Text('Trailers Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final item = widget.trailers[index];
            return Card(
              child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(item['type']),
                  onTap: () => TrailerPlay(
                        youtubeKey: item["key"],
                      ).launch(context)),
            );
          },
          itemCount: widget.trailers.length,
        ),
      ),
    );
  }
}
