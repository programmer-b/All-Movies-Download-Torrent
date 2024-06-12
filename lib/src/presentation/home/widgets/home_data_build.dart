import 'dart:developer' as dev;
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../state/home_state.dart';
import '../../../utils/ads_manager.dart';
import 'home_data_tile.dart';

class HomeDataBuild extends StatefulWidget {
  const HomeDataBuild({super.key, required this.data});

  final List<dynamic> data;

  @override
  State<HomeDataBuild> createState() => _HomeDataBuildState();
}

class _HomeDataBuildState extends State<HomeDataBuild> {
  @override
  Widget build(BuildContext context) {
    final reader = context.read<HomeState>();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (int i = 0; i < widget.data.length; i++)
          Column(
            children: [
              HomeDataTile(cohortData: widget.data[i]),
              if (shouldShowAd(i)  &&
                  adsHigh && reader.showNativeAds) // Added condition to avoid showing ad at the start
                NativeAdWidget(),
            ],
          )
      ],
    );
  }
}

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  void _loadNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdHelper.nativeAdvancedAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            dev.log('NativeAd loaded.');
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            dev.log('NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small),
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.landscape,
        ))
      ..load();
  }

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      return Column(
        children: [
          8.height,
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320,
              minHeight: 100,
              maxWidth: 400,
              maxHeight: 100,
            ),
            child: AdWidget(ad: _nativeAd!),
          ),
          8.height,
        ],
      );
    }
    return const SizedBox();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}

bool shouldShowAd(i) {
  if (i == 4) return true;
  if ((i - 4) % 8 == 0) return true;
  return false;
}
