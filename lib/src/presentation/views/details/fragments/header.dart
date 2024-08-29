import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/strings.dart';
import '../../home/components/poster_component.dart';

class DetailsHeader extends StatefulWidget {
  const DetailsHeader({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  State<DetailsHeader> createState() => _HeaderState();
}

class _HeaderState extends State<DetailsHeader> {
  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final releaseDate = DateFormat.yMMMMd()
        .format(DateTime.parse(details['release_date'] ?? '2021-01-01'));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PosterComponent(
          imageUrl: details["poster_large"],
          width: 100,
          height: 150,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                details['title_long'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                details['genres'].replaceAll('"', ''),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                '$releaseDateText: $releaseDate', // Use the variable
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              if (details.containsKey('mpa_rating'))
                Text('$mpaRatingText: ${details['mpa_rating']}', // Use the variable
                    style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text(
                    '${details['vote_average']} (${details['vote_count']} votes)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
