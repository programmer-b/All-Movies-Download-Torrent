import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state/home_state.dart';
import '../../widgets/home_data_build.dart';

class TvsTab extends StatefulWidget {
  const TvsTab({super.key});

  @override
  State<TvsTab> createState() => _TvsTabState();
}

class _TvsTabState extends State<TvsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<HomeState>(
      builder: (context, provider, child) {
        if(provider.data != null) {
          return  HomeDataBuild(data: provider.data?["data"]["tvs"]);
        }
        return const Center(child: CircularProgressIndicator(),);
      },
    ));
  }
}
