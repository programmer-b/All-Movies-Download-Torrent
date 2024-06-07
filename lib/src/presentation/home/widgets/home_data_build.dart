import 'package:flutter/material.dart';

import 'home_data_tile.dart';

class HomeDataBuild extends StatelessWidget {
  const HomeDataBuild({super.key, required this.data});

  final List<dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8), children: [
      for (int i = 0; i < data.length; i++) HomeDataTile(cohortData: data[i])
    ]);
  }
}
