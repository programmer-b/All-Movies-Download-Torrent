import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/home.dart';
import '../components/builder_component.dart';
import '../components/home_choice_chips.dart';

class DataFragment extends StatefulWidget {
  const DataFragment({super.key, required this.type, this.slug});

  final String type;
  final String? slug;

  @override
  State<DataFragment> createState() => _DataFragmentState();
}

class _DataFragmentState extends State<DataFragment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeChoiceChips(),
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                return BuilderComponent(
                  key: ValueKey(homeProvider.selectedCurrent),
                  type: widget.type,
                  slug: widget.slug,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
