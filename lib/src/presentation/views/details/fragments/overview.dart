import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../utils/strings.dart';

class Overview extends StatelessWidget {
  const Overview({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(overviewTitleText, style: Theme.of(context).textTheme.titleMedium), // Use the variable
        8.height,
        ReadMoreText(
          details['overview'],
          trimLines: 4,
          trimMode: TrimMode.Line,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
