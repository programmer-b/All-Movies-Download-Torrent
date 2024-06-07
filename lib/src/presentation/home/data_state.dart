import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../utils/urls.dart';

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

  _subLoad({bool? loading}) {
    _subLoading = loading ?? !_subLoading;
    notifyListeners();
  }

  Future<void> subCall(
      {required String method,
      required String url,
      Map<String, dynamic>? body,
      String? table,
      Map<String, dynamic>? params}) async {
    initSub();

    try {
      _subLoad(loading: true);
      dev.log('Making request with url: ${Uri.parse(
        url,
      ).replace(queryParameters: params).toString()}');
      final ApiResponse response =
          await makeCustomHttpRequest(url: url, method: method, body: body);
      dev.log("Response status is: ${response.status}");
      _subStatus = response.status;
      if (response.status ~/ 100 != 2) {
        if (!subSuccess) {
          dev.log("Setting error to true");
          _subError = true;
          _subErrors = {
            "title": "Server error.",
            "message": response.data['error']
          };
        }
      } else {
        _subSuccess = true;
        if (kDebugMode) {
          // dev.log("Response data is: ${response.data}");
        }
        _subData = response.data;
      }
      _subLoad(loading: false);
      notifyListeners();
    } on SocketException {
      if (!subSuccess) {
        dev.log("Error is: SocketException");
        _subError = true;
        _subConnectionError = true;
        _subErrors = {
          "title": "Connection Problem",
          "message": "Please check your internet connection and try again."
        };
        _subLoad(loading: false);
      }
      notifyListeners();
    } catch (e) {
      dev.log("Error is: $e");
      if (!subSuccess) {
        _subError = true;
        _subErrors = {"title": "Server Error", "message": "Please try again."};
        _subLoad(loading: false);
      }
      notifyListeners();
    }
  }

  Future<bool> isAddedToDownloadList(
      {required int? id,
      required String type,
      required String jwt,
      required int? accessId}) async {
    try {
      final ApiResponse response = await makeCustomHttpRequest(
          url: getDataExistsUrl,
          method: "PATCH",
          body: {
            "jwt": jwt,
            "id": id,
            "accessId": accessId,
            "type": type,
          });
      dev.log("DOWNLOAD LIST COMPONENT   ${response.data}");
      if (response.status ~/ 100 != 2) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      dev.log("Error is: $e");
      return false;
    }
  }

  Future<bool> addToDownloadList(
      {required int? id,
      required String type,
      required String jwt,
      required int? accessId}) async {
    try {
      dev.log(addDataUrl);
      final Map<String, dynamic> body = {
        "jwt": jwt,
        "data": {"id": id, "type": type, "isNew": true, "accessId": accessId,  "isV5": true}
      };
      dev.log('Body ==> \n$body');
      final ApiResponse response = await makeCustomHttpRequest(
          url: addDataUrl, method: "POST", body: body);
      // dev.log("DOWNLOAD LIST COMPONENT   ${response.data}");
      if (response.status ~/ 100 != 2) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      dev.log("Error is: $e");
      return false;
    }
  }

  Future<bool> removeFromDownloadList(
      {required List<int> ids,
      required List<int> accessIds,
      required String jwt}) async {
    try {
      final ApiResponse response = await makeCustomHttpRequest(
          url: removeUserDataUrl,
          method: "DELETE",
          body: {
            "jwt": jwt,
            "ids": ids,
            "accessIds": accessIds,
            "data": {
              "isNew": true,
              "isV5": true
            }
          });
      // dev.log("DOWNLOAD LIST COMPONENT   ${response.data}");
      if (response.status ~/ 100 != 2) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      dev.log("Error is: $e");
      return false;
    }
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
