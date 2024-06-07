import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';

class PersonReceiver extends StatelessWidget {
  const PersonReceiver({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final args = ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;
            return _PersonScreen(
                personId: args["personId"],
                character: args["character"] ?? args["job"]);
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

class _PersonScreen extends StatefulWidget {
  const _PersonScreen({this.personId, this.character});

  final dynamic personId;
  final dynamic character;

  @override
  State<_PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<_PersonScreen> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    createBannerAd();
    data = _data();
  }

  Future<Map<String, dynamic>> _data() async {
    try {
      var url = Uri.parse(
          'https://api.themoviedb.org/3/person/${widget.personId}?api_key=727c59ab265fc8dfe32a7786b0cb2a96&language=en-US');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        dev.log("Error status code: ${response.statusCode}");
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

  Future<void> retry() async {
    setState(() {
      data = _data();
    });
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
      appBar: AppBar(),
      body: FutureBuilder(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.error.toString()),
                    20.height,
                    ElevatedButton(
                      onPressed: retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              final data = snapshot.data as Map<String, dynamic>;
              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  const Divider(),
                  Row(
                    children: [
                      Container(
                        width: 200 * 2 / 3,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                'https://image.tmdb.org/t/p/w500${data['profile_path']}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      20.width,
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data["name"] != null && data["name"] != "")
                                Text(data['name'],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              if (widget.character != null &&
                                  widget.character != "")
                                10.height,
                              if (widget.character != null &&
                                  widget.character != "")
                                Text('as ${widget.character}',
                                    style: const TextStyle(color: Colors.grey)),
                              if (data["popularity"] != null &&
                                  data["popularity"] != "")
                                10.height,
                              if (data["popularity"] != null &&
                                  data["popularity"] != "")
                                Text('Popularity: ${data['popularity']}',
                                    style: const TextStyle(color: Colors.grey)),
                              if (data["birthday"] != null &&
                                  data["birthday"] != "")
                                10.height,
                              if (data["birthday"] != null &&
                                  data["birthday"] != "")
                                Text('Birthday: ${data['birthday']}',
                                    style: const TextStyle(color: Colors.grey)),
                              if (data["place_of_birth"] != null &&
                                  data["place_of_birth"] != "")
                                10.height,
                              if (data["place_of_birth"] != null &&
                                  data["place_of_birth"] != "")
                                Text(
                                  'Place of Birth: ${data['place_of_birth']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              if (data["deathday"] != null &&
                                  data["deathday"] != "")
                                10.height,
                              if (data["deathday"] != null &&
                                  data["deathday"] != "")
                                Text('Deathday: ${data['deathday']}',
                                    style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (data["biography"] != null && data["biography"] != "")
                    10.height,
                  if (data["biography"] != null && data["biography"] != "")
                    const Divider(),
                  if (data["biography"] != null && data["biography"] != "")
                    const SizedBox(height: 10),
                  if (data["biography"] != null && data["biography"] != "")
                    const Text('Biography',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  if (data["biography"] != null && data["biography"] != "")
                    const SizedBox(height: 10),
                  if (data["biography"] != null && data["biography"] != "")
                    Text(data['biography']),
                  const SizedBox(height: 10),
                ],
              );
            }
            return Container();
          }),
    );
  }
}