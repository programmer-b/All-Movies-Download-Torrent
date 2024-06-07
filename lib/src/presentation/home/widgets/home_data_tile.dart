import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../state/home_state.dart';

import '../../../utils/ads_manager.dart';
import '../../details/details_screen.dart';

class HomeDataTile extends StatelessWidget {
  const HomeDataTile({super.key, required this.cohortData});

  final Map<String, dynamic> cohortData;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeState>(context);
    final baseSmallImageUrl = provider.baseSmallImageUrl;
    final poster = cohortData['poster'];
    final fullTMdbPoster = !poster.startsWith('http')
        ? '$baseSmallImageUrl$poster'
        : poster.replaceAll('https//', 'https://');
    final gojPoster = cohortData['gojPoster'].replaceAll('https//', 'https://');
    final posterHere = poster == null ? gojPoster : fullTMdbPoster;

    return Card(
      child: ListTile(
        onTap: () {
          if (adsHigh) {
            showInterstitialAd();
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                        accessId: cohortData['id'],
                      )));
        },
        leading: Container(
            width: 50 * 2 / 3,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
              image: baseSmallImageUrl == ""
                  ? null
                  : provider.hideImagesForEmulators && !isRealDevice
                      ? null
                      : DecorationImage(
                          image: CachedNetworkImageProvider(posterHere),
                          fit: BoxFit.cover,
                        ),
            )),
        title: Text(cohortData['titleLong'] ?? cohortData['title']),
        subtitle: cohortData['releaseDate'] == null
            ? Text(cohortData['genres'] ?? "Unknown")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cohortData['releaseDate'] ?? "Unknown"),
                  Text(cohortData['genres'] ?? "Unknown"),
                ],
              ),
      ),
    );
  }
}
