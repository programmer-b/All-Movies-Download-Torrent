import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/urls.dart';
import '../../state/data_state.dart';
import '../../state/details.dart';
import '../home/components/error_page.dart';
import '../home/components/loading_page.dart';

import '../home/components/native_ad_widget.dart';
import 'fragments/buttons.dart';
import 'fragments/cast_and_crew.dart';
import 'fragments/favorites_button.dart';
import 'fragments/header.dart';
import 'fragments/others.dart';
import 'fragments/overview.dart';

class Details extends StatelessWidget {
  const Details({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return _BuildDetails(item: args);
  }
}

class _BuildDetails extends StatefulWidget {
  const _BuildDetails({required this.item});

  final Map<String, dynamic> item;

  @override
  State<_BuildDetails> createState() => _BuildDetailsState();
}

class _BuildDetailsState extends State<_BuildDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<DetailsProvider>()
        .getDetails(detailsUrl(widget.item['id'])));
  }

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<DetailsProvider>();

    return Scaffold(
      appBar: AppBar(
          // actions: [
          //   if (watcher.details.isNotEmpty)
          //     Tooltip(
          //       message: 'DMCA Report',
          //       child: IconButton(
          //           icon: const Icon(Icons.flag_outlined),
          //           onPressed: () async {
          //             final bool? result = await showDialog(
          //                 context: context,
          //                 builder: (context) => const ReportConfirmDialog());
          //             if (result ?? false) {
          //               Navigator.of(context).push(MaterialPageRoute(
          //                   builder: (_) => ReportNav(
          //                         contentId: widget.item['id'] ?? '',
          //                         contentType: type,
          //                         contentTitle: title,
          //                       )));
          //             }
          //           }),
          //     )
          // ],
          ),
      body: watcher.loading || watcher.details.isEmpty
          ? const LoadingPage()
          : watcher.error
              ? const ErrorPage()
              : const DetailsPage(),
      floatingActionButton: FavoritesButton(item: widget.item),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<DetailsProvider>();

    type = watcher.details['type'] ?? '';
    title = watcher.details['title_long'] ?? '';
    id = watcher.details['id'] ?? '';

    final dataState = context.watch<DataState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataState.currentIsSeries = type == 'tv';
      dataState.currentIsMovie = type == 'movie';

      dataState.currentPoster = watcher.details["poster_medium"];

      if (type == "tv") {
        dataState.currentSeriesTitle = title;
      } else {
        dataState.currentMovieTitle = title;
      }
    });

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            DetailsHeader(details: watcher.details),
            const SizedBox(height: 16),
            Buttons(details: watcher.details),
            const NativeAdWidget(),
            Overview(details: watcher.details),
            const SizedBox(height: 16),
            CastAndCrew(details: watcher.details),
            const SizedBox(height: 16),
            Others(details: watcher.details),
          ],
        ),
      ),
    );
  }
}

var type = '';
var title = '';
var id = '';
