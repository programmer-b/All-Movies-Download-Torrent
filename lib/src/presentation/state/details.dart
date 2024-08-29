import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

import '../../utils/strings.dart';

class DetailsProvider extends ChangeNotifier {
  Map<String, dynamic> _details = {};

  Map<String, dynamic> get details => _details;

  void setDetails(Map<String, dynamic> details) {
    _details = details;
    notifyListeners();
  }

  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  bool _error = false;

  bool get error => _error;

  void setError(bool error) {
    _error = error;
    notifyListeners();
  }

  String _previousUrl = '';

  String get previousUrl => _previousUrl;

  void setPreviousUrl(String url) {
    _previousUrl = url;
    notifyListeners();
  }

  Future<void> getDetails(String url) async {
    final language = getStringAsync('language', defaultValue: 'en');
    try {
      setLoading(true);
      setError(false);
      setDetails({});
      setPreviousUrl(url);
      final result = await http.get(Uri.parse("$url?language=$language"),
          headers: {
            'Content-Type': 'application/json',
            'pass': 'give-me-json'
          });
      if (result.statusCode == 200) {
        setDetails(jsonDecode(result.body));
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      dev.log(e.toString());
      setError(true);
      toast(errorOccurred, bgColor: Colors.red);
    } finally {
      setLoading(false);
    }
  }

  Future<void> retry() async {
    await getDetails(previousUrl);
  }
}
