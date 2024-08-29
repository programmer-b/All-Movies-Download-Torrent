import 'package:flutter/material.dart';

import 'data_fragment.dart';

class BuildBrowseFragment extends StatefulWidget {
  const BuildBrowseFragment(
      {super.key, required this.browse, required this.type});

  final Map<String, dynamic> browse;
  final String type;

  @override
  State<BuildBrowseFragment> createState() => _BuildBrowseFragmentState();
}

class _BuildBrowseFragmentState extends State<BuildBrowseFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.browse['name']!),
      ),
      body: DataFragment(type: widget.type, slug: widget.browse['slug']),
    );
  }
}
