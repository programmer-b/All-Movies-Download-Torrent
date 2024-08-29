import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/ads_helper.dart';
import '../../../../utils/strings.dart';
import '../../../state/configs.dart';
import '../fragments/navs/report.dart';
import 'add_to_favorites_dialog.dart';
import 'report_confirm_dialog.dart';

enum Options { details, addFavorite, report }

class DataCardPopupMenu extends StatefulWidget {
   const DataCardPopupMenu({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<DataCardPopupMenu> createState() => _DataCardPopupMenuState();
}

class _DataCardPopupMenuState extends State<DataCardPopupMenu> {
  @override
  Widget build(BuildContext context) {
    final configs = context.watch<ConfigsProvider>();
    return PopupMenuButton<Options>(
      onSelected: (Options result) async {
        switch (result) {
          case Options.details:
            if (configs.showInterstitialBetweenTopAndDetails) {
              createInterstitialAd();
              showInterstitialAd();
            }
            developer.log('Details');
            Navigator.of(context).pushNamed('/details', arguments: widget.item);
            break;
          case Options.addFavorite:
            developer.log('Add to favorites');
            showDialog(
                context: context,
                builder: (_) => AddToFavoritesDialog(item: widget.item));
            break;
          case Options.report:
            developer.log('Report');
            final bool? result = await showDialog(
                context: context, builder: (_) =>  const ReportConfirmDialog());
            if (result ?? false) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportNav(
                        contentId: widget.item['id'] ?? '',
                        contentType: widget.item['type'],
                        contentTitle: widget.item['title_long'],
                      )));
            }
            break;
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<Options>>[
         PopupMenuItem<Options>(
          value: Options.details,
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Text(details),
            ],
          ),
        ),
         PopupMenuItem<Options>(
          value: Options.addFavorite,
          child: Row(
            children: [
              const Icon(Icons.favorite_outline),
              const SizedBox(width: 8),
              Text(addFavorite),
            ],
          ),
        ),
        //  PopupMenuItem<Options>(
        //   value: Options.report,
        //   child: Row(
        //     children: [
        //       const Icon(Icons.flag_outlined),
        //       const SizedBox(width: 8),
        //       Text(report),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
