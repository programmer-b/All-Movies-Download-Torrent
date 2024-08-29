import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  AppOpenAd? _appOpenAd;
  bool isRealDevice = true;

  bool _isAppOpenAdReady = false;

  final String appOpenAdId = 'ca-app-pub-5988017258715205/1799461274';

  void initialize() {
    _loadAppOpenAd();
    DeviceInfoPlugin().androidInfo.then((value) {
      isRealDevice = value.isPhysicalDevice;
    });
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
          _setAppOpenAdListeners();
          if (isRealDevice) {
            showAppOpenAd();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAppOpenAdReady = false;
          _appOpenAd = null;
          developer.log('Failed to load App Open ad: $error');
          _loadAppOpenAd();
        },
      ),
    );
  }

  void _setAppOpenAdListeners() {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isAppOpenAdReady = false;
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        // _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        developer.log('Failed to show App Open ad: $error');
        _loadAppOpenAd();
      },
    );
  }

  void showAppOpenAd() {
    if (_isAppOpenAdReady && _appOpenAd != null) {
      _appOpenAd?.show();
    } else {
      developer.log('App Open ad is not ready yet.');
    }
  }
}
