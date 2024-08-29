import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DataState extends ChangeNotifier {
  String? _currentPoster;

  String? get currentPoster => _currentPoster;

  set currentPoster(String? value) {
    _currentPoster = value;
    notifyListeners();
  }

  String? _currentMovieTitle;

  String? get currentMovieTitle => _currentMovieTitle;

  set currentMovieTitle(String? value) {
    _currentMovieTitle = value;
    notifyListeners();
  }

  String? _currentSeriesTitle;

  String? get currentSeriesTitle => _currentSeriesTitle;

  set currentSeriesTitle(String? value) {
    _currentSeriesTitle = value;
    notifyListeners();
  }

  String? _currentSeasonTitle;

  String? get currentSeasonTitle => _currentSeasonTitle;

  set currentSeasonTitle(String? value) {
    _currentSeasonTitle = value;
    notifyListeners();
  }

  String? _currentEpisodeTitle;

  String? get currentEpisodeTitle => _currentEpisodeTitle;

  set currentEpisodeTitle(String? value) {
    _currentEpisodeTitle = value;
    notifyListeners();
  }

  bool _currentIsMovie = false;

  bool get currentIsMovie => _currentIsMovie;

  set currentIsMovie(bool value) {
    _currentIsMovie = value;
    notifyListeners();
  }

  bool _currentIsSeries = false;

  bool get currentIsSeries => _currentIsSeries;

  set currentIsSeries(bool value) {
    _currentIsSeries = value;
    notifyListeners();
  }

  Map<String, dynamic> _subData = {};

  Map<String, dynamic> get subData => _subData;

  bool _subSuccess = false;

  bool get subSuccess => _subSuccess;

  bool _subLoading = false;

  bool get subLoading => _subLoading;

  bool _subError = false;

  bool get subError => _subError;

  bool _subConnectionError = false;

  bool get subConnectionError => _subConnectionError;

  Map<String, dynamic> _subErrors = {};

  Map<String, dynamic> get subErrors => _subErrors;

  int? _subStatus;

  int? get subStatus => _subStatus;

  void initSub() {
    dev.log('Init has been called()');
    _subSuccess = false;
    _subError = false;
    _subConnectionError = false;
    _subData = {};
    _subErrors = {};
    _subLoading = false;
    _subStatus = null;
    notifyListeners();
  }

}

class ApiResponse<T> {
  final T data;
  final int status;

  ApiResponse({
    required this.data,
    required this.status,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data,
      "status": status,
    };
  }
}

Future<ApiResponse> makeCustomHttpRequest(
    {String method = "GET",
      required String url,
      Map<String, dynamic>? body}) async {
  final uri = Uri.parse(url);
  final request = http.Request(method, uri);
  request.headers.addAll({
    'Content-Type': 'application/json',
  });

  if (body != null) {
    request.body = json.encode(body);
  }
  final response = await http.Client().send(request);
  final results = await response.stream.bytesToString();

  // log("Results are $results");

  final apiResponse = ApiResponse<Map<String, dynamic>>(
      data: json.decode(results), status: response.statusCode);
  if (kDebugMode) print("Api response: $apiResponse");
  return ApiResponse.fromJson(apiResponse.toJson());
}