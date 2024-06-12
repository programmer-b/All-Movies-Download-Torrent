import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucy/src/presentation/home/widgets/home_data_build.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../state/home_state.dart';
import '../../../utils/ads_manager.dart';
import '../../../utils/urls.dart';
import 'package:http/http.dart' as http;

import '../../details/details_screen.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;
  Future? _searchFuture;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  Future _onSearch(String query) async {
    try {
      var url = Uri.parse('$searchUrl?query=$query');
      if (kDebugMode) print(url);
      var response = await http.get(url);
      // if (kDebugMode) print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } on SocketException catch (e) {
      if (kDebugMode) print(e);
      throw Exception('No Internet connection');
    } catch (e) {
      if (kDebugMode) print(e);
      throw Exception('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final watcher = Provider.of<HomeState>(context);
    return Scaffold(
      //use app bar as the search bar
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _textEditingController,
              textInputAction: TextInputAction.search,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search your favorite movies and tv shows',
                border: InputBorder.none,
                suffixIcon: IconButton(
                    onPressed: () {
                      if (_textEditingController.text.isEmpty) {
                        Navigator.pop(
                            context); // Pop the screen if text field is empty
                      } else {
                        _textEditingController.clear(); // Clear the text field
                        _focusNode.requestFocus(); // Show the keyboard
                      }
                    },
                    icon: const Icon(Icons.clear)),
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchFuture = _onSearch(value);
                });
                FocusScope.of(context).unfocus(); // Hide the keyboard
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data;
            if (data['data'].isEmpty) {
              // Check if the data array is empty
              return const Center(
                  child: Text('No results found')); // Display a message
            }
            return ListView.builder(
              itemCount: data['data'].length,
              itemBuilder: (context, index) {
                var item = data['data'][index];
                var tmdbPoster = item['tmdbPoster'];
                var gojPoster = item['gojPoster'];
                var ytsPoster = item['ytsPoster'];
                var waploadedPoster = item['waploadedPoster'];
                var baseSmallImageUrl = watcher.baseSmallImageUrl;
                var tmdbFullPoster =
                    tmdbPoster == null ? null : '$baseSmallImageUrl$tmdbPoster';
                var posterHere =
                    tmdbFullPoster ?? gojPoster ?? ytsPoster ?? waploadedPoster;
                var title = item['titleLong'] ?? item['title'];
                var releaseDate = item['releaseDate'];
                var type = item['type'] == 'movie' ? 'Movie' : 'TV Show';
                var genres = item['genres'];
                var waploadedGenres = item['waploadedGenres'];
                var genresHere = genres ?? waploadedGenres;
                var id = item['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                  ),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          isThreeLine: true,
                          onTap: () {
                            if (adsVeryHigh) {
                              showInterstitialAd();
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    id: id,
                                  ),
                                ));
                          },
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                height: 50,
                                width: 50 * 2 / 3,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  image: watcher.baseSmallImageUrl == ""
                                      ? null
                                      : watcher.hideImagesForEmulators &&
                                              !isRealDevice
                                          ? null
                                          : DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  posterHere),
                                            ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              releaseDate == null
                                  ? Text(type,
                                      style: const TextStyle(fontSize: 12))
                                  : Text('$type | $releaseDate',
                                      style: const TextStyle(fontSize: 12)),
                              Text(
                                genresHere ?? '',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (shouldShowAd(index) && adsHigh && watcher.showNativeAds) NativeAdWidget()
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchFuture = _onSearch(_textEditingController.text);
                      });
                    },
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
