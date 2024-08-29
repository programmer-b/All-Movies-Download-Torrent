import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/urls.dart';
import '../../../state/home.dart';
import 'data_card.dart';
import 'error_page.dart';
import 'loading_page.dart';

class BuilderComponent extends StatefulWidget {
  const BuilderComponent({super.key, required this.type, this.slug});

  final String type;
  final String? slug;

  @override
  State<BuilderComponent> createState() => _BuilderComponentState();
}

class _BuilderComponentState extends State<BuilderComponent> {
  late final bool isSlug = widget.slug != null;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    developer.log('BuilderComponent initialized');
    _controller = ScrollController();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  void _onScroll() async {
    final provider = context.read<HomeProvider>();
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      if (provider.data["data"].length < provider.data["total_results"]) {
        final path = isSlug
            ? browse(widget.type, provider.selectedCurrent, widget.slug!,
                provider.currentPage + 1)
            : category(widget.type, provider.selectedCurrent,
                provider.currentPage + 1);
        var more = await provider.getOnAsk(path);
        var data = provider.data;
        data["data"].addAll(more["data"]);
        provider.setData(data);
        provider.nextPage();
      }
    }
  }

  initialize() {
    final provider = context.read<HomeProvider>();
    final path = isSlug
        ? browse(widget.type, provider.selectedCurrent, widget.slug!, 1)
        : category(widget.type, provider.selectedCurrent, 1);
    provider.get(path);
    provider.resetPage();
  }

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeProvider>();
    return watcher.data.isEmpty
        ? const LoadingPage()
        : watcher.error
            ? const ErrorPage()
            : Scrollbar(
                controller: _controller,
                child: ListView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: watcher.data["data"].length,
                  itemBuilder: (context, index) {
                    final item = watcher.data["data"][index];
                    return Column(
                      children: [
                        DataCard(
                            whereId: "showInterstitialBetweenTopAndDetails",
                            item: item),
                        if (index == watcher.data["data"].length - 1 &&
                            watcher.data["data"].length <
                                watcher.data["total_results"])
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    );
                  },
                ),
              );
  }
}
