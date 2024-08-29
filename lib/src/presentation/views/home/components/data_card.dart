import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart' as strings;
import '../../../state/configs.dart';
import 'data_card_popup_menu.dart';
import 'poster_component.dart';

class DataCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Widget? trailing;
  final String? whereId;

  const DataCard({
    super.key,
    required this.item,
    this.trailing,
    this.whereId,
  });

  @override
  Widget build(BuildContext context) {
    final String title = item['title_long'] ?? '';
    final String imageUrl = item['poster_medium'] ?? '';
    final String type = item['type'] ?? '';
    final String releaseDate = item['release_date'] ?? '';
    final String genres = item['genres'] ?? '';
    final typeThis = type == 'movie' ? strings.movie : strings.tvShow;
    final typeAndDate = '$typeThis - $releaseDate';

    final configs = context.watch<ConfigsProvider>();

    return Card(
      child: ListTile(
        onTap: () {
          switch (whereId) {
            case "showInterstitialBetweenSearchAndDetails":
              if (configs.showInterstitialBetweenSearchAndDetails) {
                createInterstitialAd();
                showInterstitialAd();
              }
              break;
            case "showInterstitialBetweenTopAndDetails":
              if (configs.showInterstitialBetweenTopAndDetails) {
                createInterstitialAd();
                showInterstitialAd();
              }
              break;
            case "showInterstitialBetweenFavoritesAndDetails":
              if (configs.showInterstitialBetweenFavoritesAndDetails) {
                createInterstitialAd();
                showInterstitialAd();
              }
              break;
          }
          Navigator.of(context).pushNamed('/details', arguments: item);
        },
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: PosterComponent(imageUrl: imageUrl),
        ),
        title: Text(
          title.isNotEmpty ? title : strings.unknownTitle,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              typeAndDate.isNotEmpty ? typeAndDate : strings.unknownTypeDate,
              style: const TextStyle(fontSize: 13.0, color: Colors.grey),
            ),
            const SizedBox(height: 4.0),
            Text(
              (genres.isNotEmpty ? genres : strings.unknownGenres)
                  .replaceAll("\"", ""),
              style: const TextStyle(fontSize: 13.0, color: Colors.grey),
            ),
          ],
        ),
        trailing: trailing ??
            DataCardPopupMenu(
              item: item,
            ),
      ),
    );
  }
}
