import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

import '../../utils/strings.dart';
import '../../utils/urls.dart';

class FavoritesProvider extends ChangeNotifier {
  List<dynamic> _favorites = [];

  List<dynamic> get favorites => _favorites;

  Future<void> addFavorite(Map<String, dynamic> favorite, jwt) async {
    _favorites = [..._favorites, favorite];
    setValue("favorites", {"data": _favorites});
    final body = {
      "jwt": jwt,
      "data": favorite,
    };
    final result = await post(addFavoriteUrl, body);
    if (result != null) {
      toast(favoriteAdded, bgColor: Colors.green);
      exists = true;
    }
    notifyListeners();
  }

  Future<void> removeFavorite(Map<String, dynamic> favorite, jwt) async {
    _favorites =
        _favorites.where((element) => element["id"] != favorite["id"]).toList();
    setValue("favorites", {"data": _favorites});
    final body = {
      "jwt": jwt,
      "id": favorite["id"],
    };
    final result = await post(removeFavoriteUrl, body);
    if (result != null) {
      toast(favoriteRemoved, bgColor: Colors.green);
      exists = false;
    }
    notifyListeners();
  }

  Future<void> getFavorites(jwt) async {
    final body = {
      "jwt": jwt,
    };
    final result = await post(getFavoritesUrl, body);
    if (result != null) {
      _favorites = result["data"];
      setValue("favorites", {"data": _favorites});
      notifyListeners();
    }
  }

  Future<void> favoriteExists(Map<String, dynamic> favorite, jwt) async {
    if (!jwt.isNotEmpty) return;
    _exists = false;
    final body = {
      "jwt": jwt,
      "id": favorite["id"],
    };
    final result = await post(favoriteExistsUrl, body);
    if (result != null) {
      _exists = result["exists"];
      notifyListeners();
    }
  }

  bool _loading = false;

  bool get loading => _loading;

  bool _exists = false;

  bool get exists => _exists;

  set exists(bool value) {
    _exists = value;
    notifyListeners();
  }

  initialize() {
    _favorites = getJSONAsync("favorites", defaultValue: {"data": []})["data"];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> post(
      String url, Map<String, dynamic> body) async {
    try {
      _loading = true;
      notifyListeners();
      dev.log('BOdy: $body');
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final result = json.decode(response.body);
      dev.log("Post Result: $result");
      if (response.statusCode ~/ 100 == 2) {
        // toast(success, bgColor: Colors.green);
        return result;
      } else {
        toast(errorOccurred, bgColor: Colors.red);
      }
    } catch (e) {
      dev.log("Failed to post favorite", error: e);
      toast(errorOccurred);
    } finally {
      _loading = false;
      notifyListeners();
    }
    return null;
  }
}
