import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class HomeProvider extends ChangeNotifier {
  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  bool _error = false;

  bool get error => _error;

  setData(Map<String, dynamic> data) {
    _data = data;
    notifyListeners();
  }

  String _previousUrl = '';

  String get previousUrl => _previousUrl;

  Future<void> get(url) async {
    final language = getStringAsync('language', defaultValue: 'en');
    try {
      _data = {};
      _error = false;
      _previousUrl = url;
      notifyListeners();
      if (getJSONAsync("$url-$language", defaultValue: {}).isNotEmpty) {
        developer.log('Data already loaded', name: 'HomeProvider');
        _data = getJSONAsync("$url-$language", defaultValue: {});
        notifyListeners();
      }
      var response = await http.get(Uri.parse("$url?language=$language"), headers: {
        'pass': 'give-me-json',
      });
      if (response.statusCode == 200) {
        _data = jsonDecode(response.body);
        await setValue("$url-$language", _data);
        notifyListeners();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      developer.log('Error: $e');
      _error = true;
    }
  }

  Future<void> retry() async {
    if (_previousUrl.isNotEmpty) {
      await get(_previousUrl);
    }
  }

  List<dynamic> _postData = [];

  List<dynamic> get postData => _postData;

  void clearPostData() {
    _postData = [];
    _postError = false;
    _postLoading = false;

    notifyListeners();
  }

  bool _postLoading = false;

  bool get postLoading => _postLoading;

  bool _postError = false;

  bool get postError => _postError;

  String _previousPostUrl = '';

  String get previousPostUrl => _previousPostUrl;

  Future<void> post(url, Map<String, dynamic> body) async {
    final language = getStringAsync('language', defaultValue: 'en');
    try {
      _postData = [];
      _postLoading = true;
      _previousPostUrl = url;
      _postError = false;
      notifyListeners();
      var response = await http.post(Uri.parse("$url?language=$language"),
          headers: {
            'pass': 'give-me-json',
          },
          body: body);
      if (response.statusCode == 200) {
        _postData = jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      developer.log('Error: $e');
      _postError = true;
    } finally {
      _postLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryPost() async {
    if (_previousPostUrl.isNotEmpty) {
      await post(_previousPostUrl, {});
    }
  }

  Future<Map<String, dynamic>> getOnAsk(url) async {
    final language = getStringAsync('language', defaultValue: 'en');
    try {
      var response = await http.get(Uri.parse("$url?language=$language"), headers: {
        'pass': 'give-me-json',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      developer.log('Error: $e');
      return {"data": []};
    }
  }

  Future<void> loadMoreData(String type) async {}

  int _currentPage = 1;

  int get currentPage => _currentPage;

  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  void resetPage() {
    _currentPage = 1;
    notifyListeners();
  }

  bool get canGoBack => _currentPage > 1;

  bool get canGoForward => _currentPage < _data['total_pages'];

  String _selectedCurrent = 'all';

  String get selectedCurrent => _selectedCurrent;

  void setType(String type) {
    _selectedCurrent = type;
    notifyListeners();
  }
}
