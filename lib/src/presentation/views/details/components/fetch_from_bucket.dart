import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/urls.dart';
import '../../home/components/loading_page.dart';

class FetchFromBucket extends StatefulWidget {
  const FetchFromBucket({super.key, required this.fileName});

  final String fileName;

  @override
  State<FetchFromBucket> createState() => _FetchFromBucketState();
}

class _FetchFromBucketState extends State<FetchFromBucket> {
  late Future<void> _getDownloadLinkFuture;

  @override
  void initState() {
    super.initState();
    _getDownloadLinkFuture = _getDownloadLink();
  }

  Future<void> _getDownloadLink() async {
    try {
      final response = await http.post(
          Uri.parse("$downloadUrl?fi=${widget.fileName}&dl=true"),
          headers: {
            'pass': 'give-me-json',
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['url'];
        if (url.isNotEmpty) {
          if (mounted) {
            Navigator.of(context).pop(url);
          }
        } else {
          throw Exception('Failed to load data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // toast(errorOccurred);
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getDownloadLinkFuture,
        builder: (_, __) {
          return const LoadingPage();
        });
  }
}
