import 'package:flutter/material.dart';

import '../data_fragment.dart';

class TrendingFragment extends StatefulWidget {
  const TrendingFragment({super.key});

  @override
  State<TrendingFragment> createState() => _TrendingFragmentState();
}

class _TrendingFragmentState extends State<TrendingFragment> {
  @override
  Widget build(BuildContext context) {
    return const DataFragment(
      type: 'trending',
    );
  }
}
