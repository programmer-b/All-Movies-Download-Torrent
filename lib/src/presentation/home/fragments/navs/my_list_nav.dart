import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucy/src/presentation/details/details_screen.dart';
import 'package:provider/provider.dart';

import '../../../../state/home_state.dart';
import '../../../../utils/urls.dart';
import '../../../authentication/auth_state.dart';
import 'package:http/http.dart' as http;

class MyListNavFragment extends StatefulWidget {
  const MyListNavFragment({super.key});

  @override
  State<MyListNavFragment> createState() => _MyListNavFragmentState();
}

class _MyListNavFragmentState extends State<MyListNavFragment> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("My List"),
        ),
        body: !authProvider.isAuthenticated
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You need to be logged in to view this page"),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () {}, child: const Text("Login"))
                  ],
                ),
              )
            : ChangeNotifierProvider(
                create: (context) => _Provider(),
                child: _MyListInit(jwt: authProvider.jwt)));
  }
}

class _MyListInit extends StatefulWidget {
  const _MyListInit({required this.jwt});

  final String jwt;

  @override
  State<_MyListInit> createState() => _MyListInitState();
}

class _MyListInitState extends State<_MyListInit> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = context.read<_Provider>();
      provider.init();
      provider._getMyList(widget.jwt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, _Provider provider, child) {
        if (provider.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (provider.error) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You have no items in your list"),
              ],
            ),
          );
        }
        if (provider.success) {
          return ListView.builder(
              itemCount: provider.myList.length,
              itemBuilder: (context, index) {
                final item = provider.myList[index];
                return Builder(builder: (context) {
                  final title = item["titleLong"] ?? item["title"];
                  final type = item["type"];
                  var poster = item["tmdbPoster"] ?? item["gojPoster"];
                  poster ??= "https://via.placeholder.com/150";
                  if (poster.startsWith("/")) {
                    poster = "$baseSmallImageUrl$poster";
                  }
                  poster.replaceAll("https//", "https://");
                  var id = item["id"];
                  var accessId = item["accessId"];
                  if (item.containsKey("isNew")) {
                    accessId = id;
                  }
                  return Card(
                    child: ListTile(
                      onTap: () {
                        if (adsHigh) {
                          // showInterstitialAd();
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                      accessId:
                                          accessId != null || accessId != ""
                                              ? accessId
                                              : null,
                                      id: id != null || id != ""
                                          ? id
                                          : null,
                                    )));
                      },
                      leading: Container(
                        width: 50 * 2 / 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(poster),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(title),
                      subtitle: Text(type),
                      trailing: PopupMenuButton<int>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 1,
                            child: Text("Remove"),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 1) {
                            provider.removeItem(widget.jwt, item["id"], item["accessId"]);
                          }
                        },
                      ),
                    ),
                  );
                });
              });
        }
        return const SizedBox();
      },
    );
  }
}

class _Provider extends ChangeNotifier {
  bool _success = false;

  bool get success => _success;

  void setSuccess(bool value) {
    _success = value;
    notifyListeners();
  }

  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _error = false;

  bool get error => _error;

  void setError(bool value) {
    _error = value;
    notifyListeners();
  }

  List<dynamic> _myList = [];

  List<dynamic> get myList => _myList;

  void setMyList(List<dynamic> value) {
    _myList = value;
    notifyListeners();
  }

  init() {
    setLoading(true);
    setError(false);
    setSuccess(false);
    setMyList([]);
  }

  Future<void> _getMyList(jwt) async {
    try {
      final response = await http.patch(Uri.parse(getDownloadListUrl), body: {
        "jwt": jwt,
      }).timeout(const Duration(seconds: 10));
      // dev.log("Response: ${response.body}");

      if (response.statusCode == 200) {
        setSuccess(true);
        final list = jsonDecode(response.body)["data"];
        //remove all objects whose key isNew != true
        final filteredList = list.where((element) => element["isNew"] == true);
        if (filteredList.toList().isEmpty) {
          setError(true);
        }
        setMyList(filteredList.toList());
      } else {
        setError(true);
      }
    } catch (e) {
      setError(true);
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeItem(jwt, id, accessId) async {
    //first remove the item from the list
    final list = _myList;
    dev.log("Removing item with id: $id");
    final index = list.indexWhere((element) => element["id"] == id || element["accessId"] == accessId);
    dev.log("Index: $index");
    list.removeAt(index);
    dev.log("Item removed from list");
    setMyList(list);
    dev.log("Sending request to remove item from server");
    try {
      final body = {
        "jwt": jwt,
        "ids": [id],
        "accessIds": [accessId],
        "data": {"isNew": true}
      };
      dev.log("Body: $body");
      Dio dio = Dio();
      final response = await dio.delete(removeUserDataUrl,
          data: jsonEncode(body),
          options: Options(headers: {"Content-Type": "application/json"}));
      if ((response.statusCode ?? 1) ~/ 100 == 2) {
        dev.log("Item removed successfully");
      } else {
        dev.log("Error: ${response.statusCode}");
        // setError(true);
      }
    } catch (e) {
      dev.log("Error: $e");
      // setError(true);
    } finally {
      // setLoading(false);
    }
  }
}
