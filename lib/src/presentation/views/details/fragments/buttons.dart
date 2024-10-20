import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart';
import '../../../state/configs.dart';
import '../components/fetch_from_bucket.dart';
import '../components/loading_component.dart';
import 'ab_download.dart';
import 'seasons.dart';
import 'to_download_fragment.dart';
import 'trailers_selection.dart';

class Buttons extends StatefulWidget {
  const Buttons({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
    return Column(
      children: <Widget>[
        if (widget.details['type'] == 'movie')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () async {
                  if (configsProvider.showInterstitialBetweenDetailsAndDeep) {
                    createInterstitialAd();
                    showInterstitialAd();
                  }
                  final downloadLink = widget.details['download_link'] ?? '';
                  final specialDownloadLink =
                      widget.details['special_download_link'] ?? '';

                  if (downloadLink.isEmpty && specialDownloadLink.isEmpty) {
                    ToDownloadFragment(
                      title: widget.details['title_long'] ?? '',
                      fileName: "${widget.details['slug']}.mp4",
                      torrents: widget.details['torrents'],
                    ).launch(context);
                    return;
                  }

                  if (!mounted) return;
                  final bucketUrl = configsProvider.useBucket
                      ? await showDialog(
                          context: context,
                          builder: (_) {
                            return FetchFromBucket(
                                fileName: "${widget.details['slug']}.mp4");
                          })
                      : null;
                  if (!mounted) return;
                  if (bucketUrl != null) {
                    ToDownloadFragment(
                      dash: bucketUrl,
                      title: widget.details['title_long'] ?? '',
                      fileName: "${widget.details['slug']}.mp4",
                      torrents: widget.details['torrents'],
                    ).launch(context);
                    return;
                  }
                  final isSpecial =
                      downloadLink.toString().contains('waploaded') ||
                          specialDownloadLink.toString().contains('waploaded');

                  if (!mounted) return;
                  if (isSpecial) {
                    developer.log('Download link: $downloadLink');
                    developer.log('Special download link: $specialDownloadLink');
                    AbDownload(
                      url: specialDownloadLink,
                      title: widget.details['title_long'] ?? '',
                      fileName: "${widget.details['slug'] ?? ''}.mp4",
                      torrents: widget.details['torrents'],
                    ).launch(context);
                  } else {
                    LoadingComponent(
                      base: 'https://www.goojara.to',
                      isMovie: true,
                      homeUrl: downloadLink,
                      title: widget.details['title_long'] ?? '',
                      fileName: "${widget.details['slug'] ?? ''}.mp4",
                      torrents: widget.details['torrents'],
                    ).launch(context);
                  }
                },
                child: Text(downloadOptionsText)), // Use the variable
          ),
        if (widget.details['type'] == 'tv')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  if (!mounted) return;
                  SeasonsFragment(
                    seasons: widget.details['seasons'] ?? [],
                    title: widget.details['title_long'] ?? '',
                    slug: widget.details['slug'] ?? '',
                  ).launch(context);
                },
                child: Text(downloadOptionsText)), // Use the variable
          ),
        if (widget.details["videos"] != null)
          const SizedBox(height: 8), // Add space between buttons
        if (widget.details["videos"] != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  if (!mounted) return;
                  TrailersSelection(trailers: widget.details["videos"])
                      .launch(context);
                },
                child: Text(trailerSelectionText)), // Use the variable
          ),
      ],
    );
  }
}
