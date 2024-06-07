import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../state/home_state.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  @override
  Widget build(BuildContext context) {

    return Consumer<HomeState>(
      builder: (context, provider, child) {
        if(provider.data != null) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (int i = 0; i < provider.data?["data"]["categories"].length; i++)
                _TheListTile(
                  name: provider.data?["data"]["categories"][i]["name"],
                  base: provider.data?["data"]["categories"][i]["base"],
                )
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(),);
      }
    );
  }
}

class _TheListTile extends StatelessWidget {
  const _TheListTile({required this.name, required this.base});

  final String name;
  final String base;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            title: Text(name),
            onTap: () => Navigator.pushNamed(context, '/browse', arguments: {
              "name": name,
              "base": base,
            }),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )));
  }
}