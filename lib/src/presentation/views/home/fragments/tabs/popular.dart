import 'package:flutter/material.dart';

import '../data_fragment.dart';

class PopularFragment extends StatefulWidget {
  const PopularFragment({super.key});

  @override
  State<PopularFragment> createState() => _PopularFragmentState();
}

class _PopularFragmentState extends State<PopularFragment> {
  @override
  Widget build(BuildContext context) {
    return const DataFragment(type: 'popular');
  }
}
