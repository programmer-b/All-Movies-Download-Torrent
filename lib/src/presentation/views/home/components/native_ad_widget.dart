import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../state/configs.dart';

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
            NativeTemplateStyle(templateType: TemplateType.medium),
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.landscape,
          adChoicesPlacement: AdChoicesPlacement.bottomRightCorner,
          videoOptions: VideoOptions(
            clickToExpandRequested: false,
            startMuted: true,
          ),
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
    final configsProvider = context.watch<ConfigsProvider>();

    if (_isAdLoaded && configsProvider.showNativeAds) {
      return Column(
        children: [
          8.height,
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320,
              minHeight: 250,
              maxWidth: 400,
              maxHeight: 250,
            ),
            child: AdWidget(ad: _nativeAd!),
          ),
          8.height,
        ],
      );
    }
    return const SizedBox(
      height: 16,
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
