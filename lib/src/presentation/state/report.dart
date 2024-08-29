import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/urls.dart';

class ReportProvider extends ChangeNotifier {
  bool _success = false;

  bool get success => _success;

  bool _error = false;

  bool get error => _error;

  bool _loading = false;

  bool get loading => _loading;

  init() {
    _success = false;
    _error = false;
    _loading = false;
    notifyListeners();
  }

  Future<void> report(
      {required String? contentId,
      required String? contentType,
      required String contentTitle,
      required String name,
      required String email,
      required String message}) async {
    try {
      init();
      _loading = true;

      final response = await http.post(
        Uri.parse(reportUrl),
        body: {
          'contentId': contentId,
          'contentType': contentType,
          'contentName': contentTitle,
          'name': name,
          'email': email,
          'message': message,
        },
      );
      if (response.statusCode == 200) {
        _success = true;
        notifyListeners();
      } else {
        _error = true;
        developer.log('Failed to load data', error: response.body);
        notifyListeners();
      }
    } catch (e) {
      _error = true;
      developer.log('Failed to load data', error: e);
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
