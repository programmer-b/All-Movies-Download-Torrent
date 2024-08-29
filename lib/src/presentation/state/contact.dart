import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class ContactProvider extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _success = false;

  bool get success => _success;

  void setSuccess(bool value) {
    _success = value;
    notifyListeners();
  }

  bool _error = false;

  bool get error => _error;

  void setError(bool value) {
    _error = value;
    notifyListeners();
  }

  void init() {
    setLoading(false);
    setSuccess(false);
    setError(false);
  }

  Future<void> submit(url, name, email, message) async {
    final language = getStringAsync("language", defaultValue: "en");
    try {
      init();
      setLoading(true);

      final response =
          await http.post(Uri.parse("$url?language=$language"), body: {
        'name': name,
        'email': email,
        'message': message,
      });
      if (response.statusCode == 200) {
        setSuccess(true);
      } else {
        setError(true);
      }
    } catch (e) {
      setError(true);
    } finally {
      setLoading(false);
    }
  }
}
