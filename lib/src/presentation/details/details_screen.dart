import 'dart:convert';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucy/src/presentation/details/ab_download.dart';
import 'package:nb_utils/nb_utils.dart' as utils;
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';
import '../../utils/urls.dart';
// import '../authentication/auth_state.dart';
import '../home/data_state.dart';
import 'download_screen.dart';
import 'loading_component.dart';
import 'not_found_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, this.id, this.accessId});

  final int? id;
  final int? accessId;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final int? id = widget.id;
  late final int? accessId = widget.accessId;

  late Future<Map<String, dynamic>> fetchData;

  @override
  initState() {
    super.initState();
    fetchData = _fetchData();
    createBannerAd();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      var url = '$detailsUrl?id=$id&accessId=$accessId';
      dev.log("Concerned url ===== $url");
      var data =
          await http.get(Uri.parse('$detailsUrl?id=$id&accessId=$accessId'));
      if (data.statusCode == 200) {
        dev.log("ID: $id, Access ID: $accessId");
        // dev.log(data.body);
        return jsonDecode(data.body);
      }
      throw Exception('Failed to load data');
    } catch (e) {
      dev.log("error ==== $e \n\n =====");
      utils.toast('Network error',
          textColor: Colors.red, length: utils.Toast.LENGTH_LONG);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: adsLow
          ? bannerAd != null
          ? Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 12),
        child: AdWidget(ad: bannerAd!),
      )
          : null
          : null,
      // floatingActionButton: _AddToDownloadListButton(
      //   accessId: accessId,
      //   id: id,
      //   type: "movie",
      //   isLoggedIn: context.watch<AuthProvider>().isAuthenticated,
      //   jwt: context.watch<AuthProvider>().jwt,
      // ),
      appBar: AppBar(),
      body: FutureBuilder(
        future: fetchData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong 😢'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              _HeaderPart(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              _DownloadButtons(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _Description(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _CastAndCrew(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _Videos(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              if (snapshot.data?["data"]["hiboRelatedMovies"] != null)
                const Divider(),
              if (snapshot.data?["data"]["hiboRelatedMovies"] != null)
                const SizedBox(height: 10),
              if (snapshot.data?["data"]["hiboRelatedMovies"] != null)
                _SimilarContent(data: snapshot.data?["data"]!),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _OtherDetails(dataIn: snapshot.data?["data"]!),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderPart extends StatelessWidget {
  const _HeaderPart({required this.data});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeState>();
    final dataState = context.watch<DataState>();
    var tmdb = jsonDecode(data['tmdb'] ?? "{}");
    var tmdbPoster = data['tmdbPoster'];
    var ytsPoster = data['ytsPoster'];
    var gojPoster = data['gojPoster'];
    var waploadedPoster = data['waploadedPoster'];
    var baseLargeImageUrl = watcher.baseLargeImageUrl;
    var fullTmdbPoster =
        tmdbPoster != null ? baseLargeImageUrl + tmdbPoster : null;
    var posterHere =
        fullTmdbPoster ?? ytsPoster ?? gojPoster ?? waploadedPoster;
    var genres = data["genres"] ?? data['waploaded_genres'] ?? "";
    var title = data['title'] ?? data['titleLong'] ?? data['name'] ?? "";
    var type = data['type'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataState.currentIsSeries = type == 'tv';
      dataState.currentIsMovie = type == 'movie';

      dataState.currentPoster = posterHere;

      if (type == "tv") {
        dataState.currentSeriesTitle = title;
      } else {
        dataState.currentMovieTitle = title;
      }
    });

    return Row(
      children: [
        Container(
          width: context.width() * 0.35 * (2 / 3),
          height: context.width() * 0.35,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
              image: watcher.hideImagesForEmulators && !isRealDevice
                  ? null
                  : DecorationImage(
                      image: CachedNetworkImageProvider(posterHere),
                      fit: BoxFit.cover)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                height: context.width() * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(genres),
                    if (tmdb?['release_date'] != null ||
                        data['releaseDate'] != null)
                      const SizedBox(height: 8),
                    if (tmdb?['release_date'] != null ||
                        data['releaseDate'] != null)
                      if (title.length < 56)
                        Text(
                          tmdb?['release_date'] ?? data['releaseDate'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                    if (tmdb?["runtime"] != null)
                      if (title.length < 25 && genres.length < 35)
                        const SizedBox(height: 8),
                    if (tmdb?["runtime"] != null)
                      if (title.length < 25 && genres.length < 35)
                        Text(
                          "${tmdb?['runtime']} minutes",
                          style: const TextStyle(color: Colors.grey),
                        ),
                    if (tmdb?["vote_average"] != null)
                      if (title.length < 41 && genres.length < 46)
                        const SizedBox(height: 8),
                    if (tmdb?["vote_average"] != null)
                      if (title.length < 41 && genres.length < 46)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "IMDb: ${tmdb?['vote_average']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _DownloadButtons extends StatelessWidget {
  const _DownloadButtons({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    var torrents = jsonDecode(data['torrents'] ?? "{}");
    var hiboLink = data['hiboLink'];
    var hiboGoojaraLink = data['hiboGoojaraLink'];
    var hiboWootlyLink = data['hiboLink'];
    var waploadedDownloadLink = data['waploadedDownloadLink'];
    var hiboSeasons = data['hiboSeasons'];
    var waploadedSeasons = jsonDecode(data['waploadedSeasons'] ?? "{}");
    var type = data['type'];
    // dev.log("torrents ====\n\n" + torrents.toString());
    final watcher = context.watch<HomeState>();
    return Column(
      children: [
        if (torrents.isNotEmpty)
          SizedBox(
              width: context.width(),
              child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                        context,
                        "/torrents",
                        arguments: {
                          "torrents": torrents,
                          "type": data["type"],
                          // "yts": yts,
                          "title": data["title"] ?? data["titleLong"],
                        },
                      ),
                  child: const Text("Download Via Torrent",
                      style: TextStyle(color: Colors.white)))),
        if (torrents.isNotEmpty) const SizedBox(height: 10),
        if (hiboLink != null ||
            hiboGoojaraLink != null ||
            waploadedDownloadLink != null ||
            hiboSeasons != null ||
            waploadedSeasons != null)
          SizedBox(
              width: context.width(),
              child: ElevatedButton(
                  onPressed: () {
                    if (adsLow && type == "movie") {
                      showInterstitialAd();
                    }

                    if (type == 'tv') {
                      Navigator.pushNamed(
                        context,
                        "/seasons",
                        arguments: {
                          "hiboSeasons": hiboSeasons?["data"] ?? [],
                          "waploadedSeasons": waploadedSeasons,
                          "base": data["base"],
                          "title": data["title"],
                          "master": waploadedSeasons != null &&
                                  waploadedSeasons.isNotEmpty
                              ? "waploaded"
                              : "hibo",
                        },
                      );
                    } else {
                      if (watcher.movie_master == 'waploaded') {
                        if (waploadedDownloadLink != null) {
                          AbDownload(
                                  url:
                                      "${watcher.waploaded_download_link_base}$waploadedDownloadLink",
                                  title: data["title"])
                              .launch(context);
                        } else if (hiboGoojaraLink != null) {
                          LoadingComponent(
                            isMovie: type == 'movie',
                            homeUrl: hiboGoojaraLink,
                            title: data['title'],
                            base: data['base'],
                          ).launch(context);
                        } else {
                          const NotFoundScreen().launch(context);
                        }
                      } else if (watcher.movie_master == 'wootly') {
                        if (hiboWootlyLink != null) {
                          DownloadScreen(
                                  gojUrl: hiboWootlyLink,
                                  tolerance: 15000,
                                  title: data["title"] ?? data["titleLong"])
                              .launch(context);
                        } else if (hiboGoojaraLink != null) {
                          LoadingComponent(
                            isMovie: type == 'movie',
                            homeUrl: hiboGoojaraLink,
                            title: data['title'],
                            base: data['base'],
                          ).launch(context);
                        } else {
                          const NotFoundScreen().launch(context);
                        }
                      } else if (watcher.movie_master == 'goojara') {
                        if (hiboGoojaraLink != null) {
                          LoadingComponent(
                            isMovie: type == 'movie',
                            homeUrl: hiboGoojaraLink,
                            title: data['title'],
                            base: data['base'],
                          ).launch(context);
                        } else {
                          const NotFoundScreen().launch(context);
                        }
                      } else {
                        const NotFoundScreen().launch(context);
                      }
                    }
                  },
                  child: Text(
                      torrents.isEmpty && type == "tv"
                          ? "Download Series"
                          : torrents.isEmpty
                              ? "Download Movie"
                              : "Download Via Direct",
                      style: const TextStyle(color: Colors.white)))),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ReadMoreText(
          data["description"] ??
              data["waploaded_description"] ??
              "No description available",
          trimLines: 4,
        ),
      ],
    );
  }
}

class _CastAndCrew extends StatelessWidget {
  const _CastAndCrew({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeState>();
    var tmdb = jsonDecode(data['tmdb'] ?? "{}");
    final cast = tmdb["credits"]?["cast"] ?? [];
    final crew = tmdb?["credits"]?["crew"] ?? [];
    final castAndCrew = [...cast, ...crew];
    final goojaraCast = data["hiboCast"] ?? [];
    var baseSmallImageUrl = watcher.baseSmallImageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cast and Crew",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (castAndCrew.isNotEmpty)
          HorizontalList(
              itemCount: castAndCrew.length,
              itemBuilder: (context, index) {
                final person = castAndCrew[index];
                return InkWell(
                  onTap: () {
                    if(adsLow){
                      showInterstitialAd();
                    }
                    Navigator.pushNamed(context, "/person", arguments: {
                      "personId": person["id"],
                      "character": person["character"],
                      "job": person["job"]
                    });
                  },
                  child: SizedBox(
                    width: context.width() * 0.28 * (2 / 3),
                    child: Column(
                      children: [
                        Container(
                          width: context.width() * 0.28 * (2 / 3),
                          height: context.width() * 0.28,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                              image: watcher.hideImagesForEmulators &&
                                      !isRealDevice
                                  ? null
                                  : DecorationImage(
                                      image: CachedNetworkImageProvider(person[
                                                  "profile_path"] !=
                                              null
                                          ? "$baseSmallImageUrl${person["profile_path"]}"
                                          : "https://via.placeholder.com/150"),
                                      fit: BoxFit.cover)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          person["name"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(person["character"] ?? person["job"],
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              })
        else if (goojaraCast.isNotEmpty)
          Text(goojaraCast.join(", "))
        else
          const Text("No cast and crew available")
      ],
    );
  }
}

class _Videos extends StatelessWidget {
  const _Videos({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    var tmdb = jsonDecode(data['tmdb'] ?? "{}");
    final results = tmdb["videos"]?["results"] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Videos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (results.isNotEmpty)
          Column(
            children: [
              for (int i = 0; i < results.length; i++)
                Builder(builder: (context) {
                  final video = results[i];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/video",
                            arguments: {"youtubeKey": video["key"]});
                      },
                      title: Text(video["name"]),
                      subtitle: Text(video["type"]),
                      trailing: const Icon(Icons.play_arrow),
                    ),
                  );
                }),
            ],
          )
        else
          const Text("No videos available")
      ],
    );
  }
}

class _SimilarContent extends StatelessWidget {
  const _SimilarContent({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    var relatedMovies = data["hiboRelatedMovies"] ?? [];
    var homeState = context.watch<HomeState>();
    var baseSmallImageUrl = homeState.baseSmallImageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Similar Content",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (data["hiboRelatedMovies"].isNotEmpty)
          Column(
            children: [
              for (int i = 0; i < relatedMovies.length; i++)
                Builder(builder: (context) {
                  final movie = relatedMovies[i];
                  return Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            accessId: movie["id"],
                          ),
                        ),
                      ),
                      title: Text(movie?["titleLong"] ?? movie?["title"] ?? ""),
                      subtitle: Text(movie["year"] ?? "unknown"),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 4),
                          Container(
                            width: 50 * (2 / 3),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                // colorFilter: ColorFilter.mode(
                                //     Colors.grey.withOpacity(0.8),
                                //     BlendMode.srcOver),
                                image: CachedNetworkImageProvider(
                                    "$baseSmallImageUrl${movie["image"]}"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          )
        else
          const Text("No similar content available")
      ],
    );
  }
}

class _OtherDetails extends StatelessWidget {
  const _OtherDetails({required this.dataIn});

  final Map<String, dynamic> dataIn;

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var tmdb = jsonDecode(dataIn['tmdb'] ?? "{}");
    tmdb = tmdb.isEmpty ? null : tmdb;
    var data = {
      "tmdb": tmdb,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Other Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (data["tmdb"]?["production_companies"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Production Companies"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["production_companies"]
                    .map((v) => v["name"])
                    .toList()
                    .join(", "),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["production_countries"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Production Countries"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["production_countries"]
                    .map((v) => v["name"])
                    .toList()
                    .join(", "),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["spoken_languages"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Spoken Languages"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["spoken_languages"]
                    .map((v) => v["name"])
                    .toList()
                    .join(", "),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["status"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Status"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["status"],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["tagline"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Tagline"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["tagline"],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["homepage"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Homepage"),
              const SizedBox(height: 5),
              Text(
                "${data["tmdb"]["homepage"]}",
                style: const TextStyle(color: Colors.blue),
              ).onTap(
                  () => _launchUrl(Uri.parse("${data["tmdb"]["homepage"]}"))),
            ],
          ),
        if (data["tmdb"]?["first_air_date"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("First Air Date"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["first_air_date"],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["first_episode_to_air"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("First Episode To Air"),
              const SizedBox(height: 5),
              Text(
                data["tmdb"]["first_episode_to_air"],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["last_episode_to_air"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Last Episode To Air"),
              const SizedBox(height: 5),
              Text(
                "name: ${data["tmdb"]["last_episode_to_air"]["name"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "air date: ${data["tmdb"]["last_episode_to_air"]["air_date"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "episode number: ${data["tmdb"]["last_episode_to_air"]["episode_number"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "season number: ${data["tmdb"]["last_episode_to_air"]["season_number"]}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["next_episode_to_air"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Next Episode To Air"),
              const SizedBox(height: 5),
              Text(
                "name: ${data["tmdb"]["next_episode_to_air"]["name"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "air date: ${data["tmdb"]["next_episode_to_air"]["air_date"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "episode number: ${data["tmdb"]["next_episode_to_air"]["episode_number"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "season number: ${data["tmdb"]["next_episode_to_air"]["season_number"]}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["number_of_episodes"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Number Of Episodes"),
              const SizedBox(height: 5),
              Text(
                "${data["tmdb"]["number_of_episodes"]} episodes",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        if (data["tmdb"]?["number_of_seasons"] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Number Of Seasons"),
              const SizedBox(height: 5),
              Text(
                "${data["tmdb"]["number_of_seasons"]} seasons",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }
}
//
// class _AddToDownloadListButton extends StatefulWidget {
//   const _AddToDownloadListButton(
//       {required this.id,
//       required this.type,
//       required this.isLoggedIn,
//       required this.jwt,
//       required this.accessId});
//
//   final int? id;
//   final String type;
//   final bool isLoggedIn;
//   final String jwt;
//   final int? accessId;
//
//   @override
//   State<_AddToDownloadListButton> createState() =>
//       _AddToDownloadListButtonState();
// }
//
// class _AddToDownloadListButtonState extends State<_AddToDownloadListButton> {
//   late int? id;
//   late String type;
//   late bool _isLoggedIn;
//   late String? jwt;
//   late int? accessId;
//
//   @override
//   void initState() {
//     super.initState();
//     id = widget.id;
//     accessId = widget.accessId;
//     type = widget.type;
//     _isLoggedIn = widget.isLoggedIn;
//     jwt = widget.jwt;
//     _init();
//   }
//
//   Future _init() async {
//     await Future.delayed(Duration.zero);
//     await _checkIfAddedToDownloadList(isLoggedIn: _isLoggedIn, jwt: jwt ?? '');
//   }
//
//   bool _isAddedToDownloadList = false;
//
//   bool get isAddedToDownloadList => _isAddedToDownloadList;
//
//   bool _loading = false;
//
//   bool get loading => _loading;
//
//   _load({bool? value}) {
//     if (mounted) {
//       setState(() {
//         if (kDebugMode) print('setting loading to ${!_loading}');
//         _loading = value ?? !_loading;
//       });
//     }
//   }
//
//   Future<void> _checkIfAddedToDownloadList(
//       {required bool isLoggedIn, required String jwt}) async {
//     _load(value: true);
//     if (isLoggedIn) {
//       final bool isAdded = await context
//           .read<DataState>()
//           .isAddedToDownloadList(
//               id: id, type: type, jwt: jwt, accessId: accessId);
//       if (isAdded) {
//         if (mounted) {
//           setState(() {
//             _isAddedToDownloadList = true;
//           });
//         }
//         _load(value: false);
//       }
//     }
//     _load(value: false);
//   }
//
//   Future<bool> _addToDownloadList(
//       {required BuildContext context,
//       required bool isLoggedIn,
//       required String jwt}) async {
//     _load(value: true);
//     if (isLoggedIn) {
//       final bool isAdded = await context
//           .read<DataState>()
//           .addToDownloadList(id: id, type: type, jwt: jwt, accessId: accessId);
//       if (isAdded) {
//         if (mounted) {
//           setState(() {
//             _isAddedToDownloadList = true;
//           });
//         }
//         _load(value: false);
//         return true;
//       }
//       _load(value: false);
//       return false;
//     } else {
//       Fluttertoast.showToast(msg: "Please login to add to your list");
//       _load(value: false);
//       //display a dialog to ask a user to login
//       showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: const Text("Login"),
//                 content: const Text("Please login to add to your list"),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         Navigator.pushNamed(context, "/login");
//                       },
//                       child: const Text("Login"))
//                 ],
//               ));
//       return false;
//     }
//   }
//
//   Future<bool> _removeFromDownloadList(isLoggedIn, jwt) async {
//     _load();
//     List<int> ids, accessIds;
//     if (id != null)
//       ids = [id!];
//     else
//       ids = [];
//     if (accessId != null)
//       accessIds = [accessId!];
//     else
//       accessIds = [];
//     if (isLoggedIn) {
//       final bool isRemoved = await context
//           .read<DataState>()
//           .removeFromDownloadList(ids: ids, jwt: jwt, accessIds: accessIds);
//       if (isRemoved) {
//         setState(() {
//           _isAddedToDownloadList = false;
//         });
//         _load(value: false);
//         return true;
//       }
//       _load(value: false);
//       return false;
//     } else {
//       Fluttertoast.showToast(msg: "Please login to add to your list");
//       return false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         if (isAddedToDownloadList) {
//           _removeFromDownloadList(_isLoggedIn, jwt ?? '');
//         } else {
//           _addToDownloadList(
//               context: context, isLoggedIn: _isLoggedIn, jwt: jwt ?? '');
//         }
//       },
//       child: loading
//           ? const CircularProgressIndicator()
//           : isAddedToDownloadList
//               ? const Icon(Icons.check)
//               : const Icon(Icons.add),
//     );
//   }
// }
