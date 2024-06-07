import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state/home_state.dart';
import '../../widgets/home_data_build.dart';


class MoviesTab extends StatefulWidget {
  const MoviesTab({super.key});

  @override
  State<MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends State<MoviesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<HomeState>(
      builder: (context, provider, child) {
        if(provider.data != null) {
          return  HomeDataBuild(data: provider.data?["data"]["movies"]);
        }
        return const Center(child: CircularProgressIndicator(),);
      },
    ));
  }
}
