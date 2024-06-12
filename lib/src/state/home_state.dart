import 'dart:developer' as dev;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' as utils;

import '../../main.dart' as main;

class HomeState extends ChangeNotifier {
  Map<String, dynamic>? _data;

  Map<String, dynamic>? get data => _data;

  Future<void> storeData(Map<String, dynamic> data) async {
    await utils.setValue('data', data);
    _data = data;
    notifyListeners();
  }

  Future<void> fetchData() async {
    var data = utils.getJSONAsync('data');
    if (data.isNotEmpty) {
      _data = data;
      notifyListeners();
    }
  }

  bool _maintenanceMode = false;

  bool get maintenanceMode => _maintenanceMode;

  void setMaintenanceMode(bool value) {
    _maintenanceMode = value;
    notifyListeners();
  }

  String _host = "upstream";

  String get host => _host;

  void setHost(String value) {
    _host = value;
    notifyListeners();
  }

  String _ads = "high";

  String get ads => _ads;

  bool _hideImagesForEmulators = false;

  bool get hideImagesForEmulators => _hideImagesForEmulators;

  void setHideImagesForEmulators(bool value) {
    _hideImagesForEmulators = value;
    notifyListeners();
  }

  String _currentBuildNumber = "0";

  String get currentBuildNumber => _currentBuildNumber;

  String _updateUrl = "";

  String get updateUrl => _updateUrl;

  String _baseExtraSmallImageUrl = "";

  String get baseExtraSmallImageUrl => _baseExtraSmallImageUrl;

  String _baseSmallImageUrl = "";

  String get baseSmallImageUrl => _baseSmallImageUrl;

  String _baseMediumImageUrl = "";

  String get baseMediumImageUrl => _baseMediumImageUrl;

  String _baseLargeImageUrl = "";

  String get baseLargeImageUrl => _baseLargeImageUrl;

  String _baseExtraLargeImageUrl = "";

  String get baseExtraLargeImageUrl => _baseExtraLargeImageUrl;

  String _baseOriginalImageUrl = "";

  String get baseOriginalImageUrl => _baseOriginalImageUrl;

  String _movie_master = "";

  String get movie_master => _movie_master;

  String _hibo_master = "";

  String get hibo_master => _hibo_master;

  bool _include_waploaded = false;

  bool get include_waploaded => _include_waploaded;

  String _waploaded_download_link_base = "";

  String get waploaded_download_link_base => _waploaded_download_link_base;

  bool _showNativeAds = false;

  bool get showNativeAds => _showNativeAds;

  void setUpdateUrl(String value) {
    dev.log("Update URL: $value");
    _updateUrl = value;
    notifyListeners();
  }

  void setBaseExtraSmallImageUrl(String value) {
    dev.log("Base Extra Small Image URL: $value");
    _baseExtraSmallImageUrl = value;
    notifyListeners();
  }

  void setBaseSmallImageUrl(String value) {
    dev.log("Base Small Image URL: $value");
    _baseSmallImageUrl = value;
    notifyListeners();
  }

  void setBaseMediumImageUrl(String value) {
    dev.log("Base Medium Image URL: $value");
    _baseMediumImageUrl = value;
    notifyListeners();
  }

  void setBaseLargeImageUrl(String value) {
    dev.log("Base Large Image URL: $value");
    _baseLargeImageUrl = value;
    notifyListeners();
  }

  void setBaseExtraLargeImageUrl(String value) {
    dev.log("Base Extra Large Image URL: $value");
    _baseExtraLargeImageUrl = value;
    notifyListeners();
  }

  void setBaseOriginalImageUrl(String value) {
    dev.log("Base Original Image URL: $value");
    _baseOriginalImageUrl = value;
    notifyListeners();
  }

  void setCurrentBuildNumber(String value) {
    dev.log("Current Build Number: $value");
    _currentBuildNumber = value;
    notifyListeners();
  }

  void setMovieMaster(String value) {
    dev.log("Movie Master: $value");
    _movie_master = value;
    notifyListeners();
  }

  void setHiboMaster(String value) {
    dev.log("Hibo Master: $value");
    _hibo_master = value;
    notifyListeners();
  }

  void setIncludeWaploaded(bool value) {
    dev.log("Include Waploaded: $value");
    _include_waploaded = value;
    notifyListeners();
  }

  void setShowNativeAds(bool value) {
    dev.log("Show Native Ads: $value");
    _showNativeAds = value;
    notifyListeners();
  }

  void setWaploadedDownloadLinkBase(String value) {
    dev.log("Waploaded Download Link Base: $value");
    _waploaded_download_link_base = value;
    notifyListeners();
  }

  void setAds(String value) {
    _ads = value;
    if (!main.isRealDevice) {
      value = "low";
    }
    // value = "none";
    switch (value) {
      case "very_high":
        adsVeryHigh = true;
        adsHigh = true;
        adsMedium = true;
        adsLow = true;
        adsNone = false;
        break;
      case "high":
        adsVeryHigh = false;
        adsHigh = true;
        adsMedium = true;
        adsLow = true;
        adsNone = false;
        break;
      case "medium":
        adsVeryHigh = false;
        adsHigh = false;
        adsMedium = true;
        adsLow = true;
        adsNone = false;
        break;
      case "low":
        adsVeryHigh = false;
        adsHigh = false;
        adsMedium = false;
        adsLow = true;
        adsNone = false;
        break;
      case "none":
        adsVeryHigh = false;
        adsHigh = false;
        adsMedium = false;
        adsLow = false;
        adsNone = true;
        break;
    }
    //print the results of every ad type
    dev.log("adsVeryHigh: $adsVeryHigh");
    dev.log("adsHigh: $adsHigh");
    dev.log("adsMedium: $adsMedium");
    dev.log("adsLow: $adsLow");
    dev.log("adsNone: $adsNone");
    notifyListeners();
  }

  bool _ready = false;

  bool get ready => _ready;

  bool _hideContentForEmulators = false;

  bool get hideContentForEmulators => _hideContentForEmulators;

  void setHideContentForEmulators(bool value) {
    _hideContentForEmulators = value;
    notifyListeners();
  }

  void setReady(bool value) {
    _ready = value;
    notifyListeners();
  }

  DatabaseEvent? _firebaseDataIn;

  DatabaseEvent? get firebaseData => _firebaseDataIn;

  final DatabaseReference _configsRef =
      FirebaseDatabase.instance.ref("configs");

  DatabaseReference getRef(String path) => _configsRef.child(path);

  Future<void> initialize() async {
    dev.log("Initializing HomeState");
    try {
      final configs = {
        "ads": setAds,
        "hideContentForEmulators": (value) =>
            setHideContentForEmulators(value == "true"),
        "hideImagesForEmulators": (value) =>
            setHideImagesForEmulators(value == "true"),
        "host": setHost,
        "maintenance": (value) => setMaintenanceMode(value == "true"),
        "updateUrl": setUpdateUrl,
        "baseExtraSmallImageUrl": setBaseExtraSmallImageUrl,
        "baseSmallImageUrl": setBaseSmallImageUrl,
        "baseMediumImageUrl": setBaseMediumImageUrl,
        "baseLargeImageUrl": setBaseLargeImageUrl,
        "baseExtraLargeImageUrl": setBaseExtraLargeImageUrl,
        "baseOriginalImageUrl": setBaseOriginalImageUrl,
        "currentBuildNumber": setCurrentBuildNumber,
        "movie_master": setMovieMaster,
        "hibo_master": setHiboMaster,
        "include_waploaded": (value) => setIncludeWaploaded(value == "true"),
        "waploaded_download_link_base": setWaploadedDownloadLinkBase,
        "showNativeAdsIn": (value) => setShowNativeAds(value == "true"),
      };

      configs.forEach((key, valueSetter) {
        getRef(key).onValue.listen((event) {
          valueSetter(event.snapshot.value.toString());
        });
      });

      FirebaseDatabase.instance.ref("home").onValue.listen((event) {
        setReady(true);
        _firebaseDataIn = event;
      });
    } catch (e) {
      dev.log(e.toString());
    }
    fetchData();
  }
}

bool adsVeryHigh = false;
bool adsHigh = false;
bool adsMedium = false;
bool adsLow = false;
bool adsNone = false;
