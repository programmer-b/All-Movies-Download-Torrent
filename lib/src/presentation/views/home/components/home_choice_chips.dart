import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart' as strings;
import '../../../state/configs.dart';
import '../../../state/home.dart';

class HomeChoiceChips extends StatefulWidget {
  const HomeChoiceChips({super.key});

  @override
  State<HomeChoiceChips> createState() => _HomeChoiceChipsState();
}

class _HomeChoiceChipsState extends State<HomeChoiceChips> {
  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeProvider>();
    final configs = context.watch<ConfigsProvider>();
    final chipData = [
      {'label': strings.all, 'type': 'all'},
      {'label': strings.movies, 'type': 'movies'},
      {'label': strings.tvShows, 'type': 'series'},
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chipData.map((Map<String, String> data) {
        return ChoiceChip(
          label: Text(data['label']!),
          selected: watcher.selectedCurrent == data['type'],
          onSelected: (value) {
            if (configs.showInterstitialBetweenCurrents) {
              createInterstitialAd();
              showInterstitialAd();
            }
            watcher.setType(data['type']!);
          },
        );
      }).toList(),
    );
  }
}
