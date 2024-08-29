import 'package:flutter/material.dart';

import '../data_fragment.dart';

class LatestFragment extends StatefulWidget {
  const LatestFragment({super.key});

  @override
  State<LatestFragment> createState() => _LatestFragmentState();
}

class _LatestFragmentState extends State<LatestFragment> {
  @override
  Widget build(BuildContext context) {
    return const DataFragment(
      type: 'latest',
    );
  }
}
