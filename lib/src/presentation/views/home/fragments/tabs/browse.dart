import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state/home.dart';
import '../../../../../utils/strings.dart' as strings;
import '../../components/error_page.dart';
import '../../components/loading_page.dart';
import '../build_browse.dart';

class BrowseFragment extends StatefulWidget {
  const BrowseFragment({super.key});

  @override
  State<BrowseFragment> createState() => _BrowseFragmentState();
}

class _BrowseFragmentState extends State<BrowseFragment> {
  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeProvider>();
    if (watcher.data.isEmpty) {
      return const LoadingPage();
    } else if (watcher.error) {
      return const ErrorPage();
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildSection(strings.genres, watcher.data["genres"], "genres"),
            const SizedBox(height: 16),
            _buildSection(strings.years, watcher.data["years"], "years"),
          ],
        ),
      );
    }
  }

  Widget _buildSection(String title, List<dynamic> items, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(items.length, (index) {
            return GestureDetector(
              onTap: () => _onChipClicked(items[index], type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  // color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(items[index]["name"]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _onChipClicked(Map<String, dynamic> item, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildBrowseFragment(
          browse: item,
          type: type,
        ),
      ),
    );
  }
}
