import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state/home.dart';
import '../../components/data_card.dart';
import '../../components/error_page.dart';
import '../../components/loading_page.dart';

class BuildSearchFragment extends StatefulWidget {
  const BuildSearchFragment({super.key});

  @override
  State<BuildSearchFragment> createState() => _BuildSearchFragmentState();
}

class _BuildSearchFragmentState extends State<BuildSearchFragment> {
  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeProvider>();
    return watcher.postLoading
        ? const LoadingPage()
        : watcher.postError
            ? const ErrorPage(
                isPost: true,
              )
            : ListView.builder(
                itemBuilder: (_, index) {
                  final item = watcher.postData[index];
                  return DataCard(
                    whereId: "showInterstitialBetweenSearchAndDetails",
                    item: item,
                  );
                },
                itemCount: watcher.postData.length,
              );
  }
}
