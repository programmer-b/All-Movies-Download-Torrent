import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart';
import '../../../state/configs.dart';
import '../../home/components/poster_component.dart';
import 'person_info.dart';

class CastAndCrew extends StatefulWidget {
  const CastAndCrew({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  State<CastAndCrew> createState() => _CastAndCrewState();
}

class _CastAndCrewState extends State<CastAndCrew> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  final List<Map<String, dynamic>> _castAndCrew = [];
  bool _isEmpty = false;

  void initialize() {
    final cast = widget.details['cast'];
    final crew = widget.details['crew'];
    if (cast.isEmpty && crew.isEmpty) {
      _isEmpty = true;
    } else {
      for (var i = 0; i < cast.length; i++) {
        _castAndCrew.add(cast[i]);
      }
      for (var i = 0; i < crew.length; i++) {
        _castAndCrew.add(crew[i]);
      }
      _isEmpty = _castAndCrew.isEmpty;
    }
    dev.log('castAndCrew Length: ${_castAndCrew.length}');
  }

  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(castAndCrewTitle,
            style: Theme.of(context).textTheme.titleMedium), // Use the variable
        8.height,
        _isEmpty
            ? Text(noCastAndCrewAvailableText, // Use the variable
                style: Theme.of(context).textTheme.bodyMedium)
            : SizedBox(
                height: 180, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _castAndCrew.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (configsProvider
                            .showInterstitialBetweenDetailsAndDeep) {
                          createInterstitialAd();
                          showInterstitialAd();
                        }

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PersonInfo(
                                id: _castAndCrew[index]['id'],
                                character: _castAndCrew[index]['character'] ??
                                    _castAndCrew[index]['job'])));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            PosterComponent(
                                imageUrl:
                                    "https://www.themoviedb.org/t/p/w185${_castAndCrew[index]['profile_path']}",
                                width: 63,
                                height: 100),
                            8.height,
                            SizedBox(
                              width: 63,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _castAndCrew[index]['name'],
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  4.height,
                                  Text(
                                    _castAndCrew[index]['character'] ??
                                        _castAndCrew[index]['job'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
