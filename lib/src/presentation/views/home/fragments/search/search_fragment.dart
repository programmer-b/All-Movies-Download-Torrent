import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/strings.dart';
import '../../../../../utils/urls.dart' as urls;
import '../../../../state/home.dart';
import 'build_search.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      context.read<HomeProvider>().clearPostData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(search),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (query) => query.isNotEmpty
                  ? context.read<HomeProvider>().post(urls.search, {'query': query})
                  : toast('Please enter a search query'),
              decoration: InputDecoration(
                  filled: true,
                  hintText: '$search ...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: IconButton(
                      onPressed: () => _controller.text.isNotEmpty
                          ? {_controller.clear(), _focusNode.requestFocus()}
                          : _focusNode.unfocus(),
                      icon: const Icon(Icons.clear))),
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: BuildSearchFragment(),
          ),
        ],
      ),
    );
  }
}