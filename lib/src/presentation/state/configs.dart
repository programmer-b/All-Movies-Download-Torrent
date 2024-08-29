import 'dart:convert';
import 'dart:developer' as dev;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

import '../../utils/urls.dart';

class ConfigsProvider extends ChangeNotifier {
  String _language = "en";
  bool _isRealDevice = true;
  bool _hideImagesForNewbies = false;
  bool _useBucket = true;
  String _currentVersionCode = "0";
  String _newestVersionCode = "0";
  String _updateUrl = "";
  bool _showNativeAds = true;
  bool _showBannerAds = true;
  bool _showInterstitialBetweenTopAndDetails = true;
  bool _showInterstitialBetweenDetailsAndDeep = true;
  bool _showInterstitialBetweenCurrents = true;
  bool _showInterstitialBetweenTypes = true;
  bool _showInterstitialBetweenSearchAndDetails = false;
  bool _showInterstitialBetweenFavoritesAndDetails = false;

  String get language => _language;

  bool get isRealDevice => _isRealDevice;

  bool get hideImagesForNewbies => _hideImagesForNewbies;

  bool get useBucket => _useBucket;

  String get currentVersionCode => _currentVersionCode;

  String get newestVersionCode => _newestVersionCode;

  String get updateUrl => _updateUrl;

  bool get showNativeAds => _showNativeAds;

  bool get showBannerAds => _showBannerAds;

  bool get showInterstitialBetweenTopAndDetails =>
      _showInterstitialBetweenTopAndDetails && isRealDevice;

  bool get showInterstitialBetweenDetailsAndDeep =>
      _showInterstitialBetweenDetailsAndDeep;

  bool get showInterstitialBetweenCurrents =>
      _showInterstitialBetweenCurrents && isRealDevice;

  bool get showInterstitialBetweenTypes =>
      _showInterstitialBetweenTypes && isRealDevice;

  bool get showInterstitialBetweenSearchAndDetails =>
      _showInterstitialBetweenSearchAndDetails;

  bool get showInterstitialBetweenFavoritesAndDetails =>
      _showInterstitialBetweenFavoritesAndDetails;

  final int count = getIntAsync('count', defaultValue: 0);

  void initialize() async {
    setValue("count", count + 1);

    dev.log("\n\n ====== Count is: $count =======\n\n");

    _language = getStringAsync("language", defaultValue: "en");
    _isRealDevice = (await DeviceInfoPlugin().androidInfo).isPhysicalDevice;
    _currentVersionCode =
        (await PackageInfo.fromPlatform()).buildNumber.toString();

    final Map<String, dynamic>? configs = await _callConfigs();

    if (configs != null) {
      dev.log("Configs: $configs");

      _useBucket = configs["useBucket"] == 'true';
      _newestVersionCode = configs["newestVersionCode"];
      _updateUrl = configs["updateUrl"];
      _hideImagesForNewbies = configs["hideImagesForNewbies"] == 'true';
      _showNativeAds = configs["showNativeAds"] == 'true';
      _showBannerAds = configs["showBannerAds"] == 'true';
      _showInterstitialBetweenTopAndDetails =
          configs["showInterstitialBetweenTopAndDetails"] == 'true';
      _showInterstitialBetweenDetailsAndDeep =
          configs["showInterstitialBetweenDetailsAndDeep"] == 'true';
      _showInterstitialBetweenCurrents =
          configs["showInterstitialBetweenCurrents"] == 'true';
      _showInterstitialBetweenTypes =
          configs["showInterstitialBetweenTypes"] == 'true';
      _showInterstitialBetweenSearchAndDetails =
          configs["showInterstitialBetweenSearchAndDetails"] == 'true';
      _showInterstitialBetweenFavoritesAndDetails =
          configs["showInterstitialBetweenFavoritesAndDetails"] == 'true';

      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>? _callConfigs() {
    try {
      return http.get(
          Uri.parse(
            configsUrl,
          ),
          headers: {
            'Content-Type': 'application/json',
            'pass': 'give-me-json'
          }).then((response) {
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return null;
        }
      });
    } catch (e) {
      return null;
    }
  }

  void setLanguage(String value) {
    _language = value;
    setValue("language", value);
    notifyListeners();
  }

  bool get isOldUser => getBoolAsync("appOpenShowed", defaultValue: false);

  bool get hideImages => _hideImagesForNewbies && !isOldUser && count < 3;
}
