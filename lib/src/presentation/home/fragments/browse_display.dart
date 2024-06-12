import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../state/home_state.dart';
import '../../../utils/ads_manager.dart';
import '../../../utils/urls.dart';
import '../../details/details_screen.dart';
import '../widgets/home_data_build.dart';

class BrowseReceiver extends StatefulWidget {
  const BrowseReceiver({super.key});

  @override
  State<BrowseReceiver> createState() => _BrowseReceiverState();
}

class _BrowseReceiverState extends State<BrowseReceiver>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: 500.milliseconds.delay,
        builder: (context, snapshot) {
          if (snapshot.hasData ||
              snapshot.connectionState == ConnectionState.done) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return Scaffold(
              appBar: AppBar(
                title: Text(args['name']),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      text: 'Movies',
                    ),
                    Tab(
                      text: 'TVs',
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _BrowseDisplayFragment(
                    type: 'movie',
                    base: args['base'],
                  ),
                  _BrowseDisplayFragment(
                    type: 'tv',
                    base: args['base'],
                  ),
                ],
              ),
            );
          }
          return const Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        });
  }
}

class _BrowseDisplayFragment extends StatefulWidget {
  const _BrowseDisplayFragment({required this.type, required this.base});

  final String type;
  final String base;

  @override
  State<_BrowseDisplayFragment> createState() => _BrowseDisplayFragmentState();
}

class _BrowseDisplayFragmentState extends State<_BrowseDisplayFragment> {
  late String type = widget.type;
  late String base = widget.base;
  late ScrollController _scrollController;
  int _currentPage = 1;
  double _previousScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .read<BrowserProvider>()
          .getBrowseData(base: base, type: type, page: 1);
      //set no more data to false
      context.read<BrowserProvider>().noMoreData = false;
      //set dataLengths to empty
      context.read<BrowserProvider>()._dataLengths.clear();
    });
  }

  _scrollListener() {
    if (_scrollController.position.pixels > _previousScrollPosition &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent / 2) {
      //check if no more data first
      if (!context.read<BrowserProvider>().noMoreData) {
        if (kDebugMode) print('Getting more data');
        _currentPage++;
        context
            .read<BrowserProvider>()
            .getBrowseData(base: base, type: type, page: _currentPage);
      } else {
        if (kDebugMode) print('No more data');
      }
    }
    _previousScrollPosition = _scrollController.position.pixels;
  }

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<HomeState>();
    return Consumer(builder: (context, BrowserProvider provider, child) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (provider.error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.errorData['title'],
                  style: Theme.of(context).textTheme.titleMedium),
              Text(provider.errorData['message']),
              ElevatedButton(
                  onPressed: () {
                    provider.errorData['retry'](
                        base: base, type: type, page: _currentPage);
                  },
                  child: const Text('Retry'))
            ],
          ),
        );
      } else {
        return Scrollbar(
          controller: _scrollController,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              itemCount: provider.data.length,
              itemBuilder: (context, index) {
                var poster = provider.data[index]['poster'];
                if (poster.toString().contains('http')) {
                  poster = poster;
                  if (kDebugMode) print("Image is $poster");
                } else {
                  if (poster == null) {
                    poster = provider.data[index]['gojPoster'].toString()
                        .replaceAll('https//', 'https://');
                  } else {
                    poster = '${watcher.baseSmallImageUrl}$poster';
                  }
                }
                var title = provider.data[index]['titleLong'] ??
                    provider.data[index]['title'];
                var releaseDate = provider.data[index]['releaseDate'] ?? '';
                var genres = provider.data[index]['genres'] ?? '';
                var id = provider.data[index]['id'];
                final reader = context.read<HomeState>();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                  ),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                            isThreeLine: true,
                            onTap: () {
                              if (adsHigh) {
                                showInterstitialAd();
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      accessId: id,
                                    ),
                                  ));
                            },
                            leading: Container(
                              height: 50,
                              width: 50 * 2 / 3,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                                image: watcher.baseSmallImageUrl == ""
                                    ? null
                                    : DecorationImage(
                                        colorFilter:
                                            watcher.hideImagesForEmulators &&
                                                    !isRealDevice
                                                ? ColorFilter.mode(
                                                    Colors.grey.withOpacity(0.9),
                                                    BlendMode.srcOver)
                                                : null,
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          poster ??
                                              "https://via.placeholder.com/150",
                                        )),
                              ),
                            ),
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(releaseDate),
                                Text(genres),
                              ],
                            )),
                      ),
                      if (shouldShowAd(index)  &&
                          adsHigh && reader.showNativeAds) // Added condition to avoid showing ad at the start
                        NativeAdWidget(),
                    ],
                  ),
                );
              }),
        );
      }
    });
  }
}

class BrowserProvider extends ChangeNotifier {
  List<dynamic> _data = [];

  List<dynamic> get data => _data;

  final List _dataLengths = [];

  set data(List<dynamic> value) {
    _data = value;
    //check if data.length already exists in dataLengths
    if (_dataLengths.contains(value.length)) {
      if (kDebugMode) print('==== \n\nNo more data declared true\n\n ====');
      noMoreData = true;
    } else {
      _dataLengths.add(value.length);
    }
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _error = false;

  bool get error => _error;

  bool _noMoreData = false;

  bool get noMoreData => _noMoreData;

  set noMoreData(bool value) {
    _noMoreData = value;
    notifyListeners();
  }

  Map<String, dynamic> _errorData = {};

  Map<String, dynamic> get errorData => _errorData;

  Future getBrowseData(
      {required final String base, String? type, int? page}) async {
    _errorData = {};
    _error = false;
    if (page == 1) isLoading = true;
    try {
      var url = type == null
          ? Uri.parse('$browseUrl?base=$base&page=$page')
          : Uri.parse('$browseUrl?base=$base&type=$type&page=$page');
      if (kDebugMode) print('Getting browse data from url $url');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        data = json.decode(response.body)['data'];
      } else {
        if (kDebugMode) print('Response status code is ${response.statusCode}');
        _error = true;
        _errorData = {
          'title': 'Failed to load data',
          'message': 'Please try again',
          'retry': getBrowseData
        };
        notifyListeners();
      }
    } on SocketException {
      _error = true;
      _errorData = {
        'title': 'No Internet Connection',
        'message': 'Please check your internet connection and try again',
        'retry': getBrowseData
      };
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error: ==> $e');
      _error = true;
      _errorData = {
        'title': 'Something went wrong',
        'message': 'Please try again',
        'retry': getBrowseData
      };
      notifyListeners();
    }
    isLoading = false;
  }
}
