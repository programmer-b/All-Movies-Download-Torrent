import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart';
import '../../../state/configs.dart';
import '../../home/components/error_page.dart';
import '../../home/components/loading_page.dart';
import '../../home/components/poster_component.dart';

class PersonInfo extends StatefulWidget {
  const PersonInfo({super.key, required this.id, required this.character});

  final int id;
  final String character;

  @override
  State<PersonInfo> createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
  late Future<Map<String, dynamic>> futureCastInfo;

  @override
  void initState() {
    super.initState();
    futureCastInfo = fetchCastInfo();
    createBannerAd();
  }

  Future<Map<String, dynamic>> fetchCastInfo() async {
    try {
      var url = Uri.parse(
          'https://api.themoviedb.org/3/person/${widget.id}?api_key=727c59ab265fc8dfe32a7786b0cb2a96&language=${getStringAsync("language", defaultValue: "en")}');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        dev.log("Error status code: ${response.statusCode}");
        throw Exception(failedToLoadDataText); // Use the variable
      }
    } on SocketException catch (e) {
      if (kDebugMode) print(e);
      throw Exception(noInternetConnectionText); // Use the variable
    } catch (e) {
      if (kDebugMode) print(e);
      throw Exception(somethingWentWrongText); // Use the variable
    }
  }

  Future<void> _retry() async {
    setState(() {
      futureCastInfo = fetchCastInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
    return Scaffold(
      bottomNavigationBar: configsProvider.showBannerAds
          ? bannerAd != null
              ? Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AdWidget(ad: bannerAd!),
                )
              : null
          : null,
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureCastInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else if (snapshot.hasError) {
            return ErrorPage(
              retry: _retry,
            );
          } else {
            var data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterComponent(
                          imageUrl:
                              "https://www.themoviedb.org/t/p/w185${data['profile_path']}",
                          width: 100,
                          height: 150),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.containsKey('name') &&
                                data['name'] != null)
                              Text('${data['name']}',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            if (widget.character.isNotEmpty) 8.height,
                            if (widget.character.isNotEmpty)
                              Text('$characterText: ${widget.character}',
                                  // Use the variable
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            if (data.containsKey('birthday') &&
                                data['birthday'] != null)
                              8.height,
                            if (data.containsKey('birthday') &&
                                data['birthday'] != null)
                              Text('$birthdayText: ${data['birthday']}',
                                  // Use the variable
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            if (data.containsKey('place_of_birth') &&
                                data['place_of_birth'] != null)
                              8.height,
                            if (data.containsKey('place_of_birth') &&
                                data['place_of_birth'] != null)
                              Text(
                                  '$placeOfBirthText: ${data['place_of_birth']}',
                                  // Use the variable
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            if (data.containsKey('deathday') &&
                                data['deathday'] != null)
                              8.height,
                            if (data.containsKey('deathday') &&
                                data['deathday'] != null)
                              Text('$deathdayText: ${data['deathday']}',
                                  // Use the variable
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (data.containsKey('biography') &&
                      data['biography'] != null &&
                      data['biography'].isNotEmpty)
                    Text(biographyTitleText, // Use the variable
                        style: Theme.of(context).textTheme.titleMedium),
                  if (data.containsKey('biography') &&
                      data['biography'] != null &&
                      data['biography'].isNotEmpty)
                    Text(data['biography'],
                        style: Theme.of(context).textTheme.bodyMedium),
                  if (data.containsKey("also_known_as") &&
                      data["also_known_as"] != null &&
                      data["also_known_as"].isNotEmpty)
                    16.height,
                  if (data.containsKey("also_known_as") &&
                      data["also_known_as"] != null &&
                      data["also_known_as"].isNotEmpty)
                    Text(alsoKnownAsTitleText, // Use the variable
                        style: Theme.of(context).textTheme.titleMedium),
                  if (data.containsKey("also_known_as") &&
                      data["also_known_as"] != null &&
                      data["also_known_as"].isNotEmpty)
                    Text(
                        data["also_known_as"]
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
