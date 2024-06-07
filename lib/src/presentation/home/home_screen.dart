import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' as utils;
import 'package:url_launcher/url_launcher.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import '../../../main.dart';
import '../../state/home_state.dart';
import '../../utils/ads_manager.dart';
import '../../utils/urls.dart';
import 'fragments/drawer_fragment.dart';
import 'fragments/tabs/browse_tab.dart';
import 'fragments/tabs/forum/forum_tab.dart';
import 'fragments/tabs/movies_tab.dart';
import 'fragments/tabs/tvs_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool isDownloadsTabAvailable = false;

  @override
  void initState() {
    super.initState();
    createInterstitialAd();
    updateConsent();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (adsMedium) {
          showInterstitialAd();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //get data
      if (!isDataFetched) {
        isDataFetched = true;
        // Add this line
        _getData(context);
      }
    });
  }

  Future<void> _getData(context) async {
    isDataFetched = true;
    try {
      debugPrint('Initializing data from server  =======');
      final http.Response response =
          await http.get(Uri.parse('$v5Base/data/moviesandtvs'));
      if (response.statusCode == 200) {
        Provider.of<HomeState>(context, listen: false)
            .storeData(json.decode(response.body));
      } else {
        throw const HttpException('Failed to load data');
      }
    } on SocketException catch (e) {
      debugPrint('\n======= Network Error =====\n');
      debugPrint('Error: $e');
      utils.toast('Network Error',
          textColor: Colors.red, length: utils.Toast.LENGTH_LONG);
    } on FormatException catch (e) {
      debugPrint('\n======= JSON Format Error =====\n');
      debugPrint('Error: $e');
      utils.toast('Invalid JSON format',
          textColor: Colors.red, length: utils.Toast.LENGTH_LONG);
    } catch (e) {
      debugPrint('\n======= Unexpected Error =====\n');
      debugPrint('Error: $e');
      utils.toast('An unexpected error occurred',
          textColor: Colors.red, length: utils.Toast.LENGTH_LONG);
    }
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, provider, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (int.parse(provider.currentBuildNumber) >
            int.parse(currentBuildNumber)) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Update Available'),
                content: const Text(
                    'A new version of the app is available. Please update to the latest version.'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('Update'),
                      onPressed: () => _launchUrl(provider.updateUrl)),
                ],
              );
            },
          );
        }
      });
      return Scaffold(
        appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/search");
                  },
                  icon: const Icon(Icons.search)),
              ElevatedButton(
                  onPressed: () => showPremium(context: context),
                  child: const Text('UPGRADE',
                      style: TextStyle(color: Colors.white))),
              const SizedBox(width: 5)
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Icon(Icons.movie),
                  text: 'Movies',
                ),
                Tab(
                  icon: Icon(Icons.tv),
                  text: 'Series',
                ),
                // discover tab
                Tab(
                  icon: Icon(Icons.explore),
                  text: 'Browse',
                ),
                //forum tab
                Tab(
                  icon: Icon(Icons.forum),
                  text: 'Forum',
                )
              ],
            )),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Center(
              child: MoviesTab(),
            ),
            Center(
              child: TvsTab(),
            ),
            Center(
              child: BrowseTab(),
            ),
            Center(
              child: ForumTabFragment(),
            )
          ],
        ),
        drawer: const DrawerFragment(),
      );
    });
  }
}

bool isDataFetched = false; // Add this line

void updateConsent() async {
  // Make sure to continue with the latest consent info.
  var info = await UserMessagingPlatform.instance.requestConsentInfoUpdate();
  dev.log(
      '\n====================== Updating Consent Form =============================\n');
  // info = await UserMessagingPlatform.instance.showConsentForm();
  // Show the consent form if consent is required.
  if (info.consentStatus == ConsentStatus.required) {
    // `showConsentForm` returns the latest consent info, after the consent from has been closed.
    info = await UserMessagingPlatform.instance.showConsentForm();
  }
}
