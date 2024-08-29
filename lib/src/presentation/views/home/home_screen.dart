import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/ads_helper.dart';
import '../../state/configs.dart';
import 'components/home_app_bar.dart';

import 'fragments/navs/drawer/drawer.dart';

import 'fragments/tabs/browse.dart';
import 'fragments/tabs/latest.dart';
import 'fragments/tabs/popular.dart';
import 'fragments/tabs/trending.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    // updateConsent();
    tabController = TabController(length: 4, vsync: this);
    //listen to tab changes
    createInterstitialAd();
    tabController.addListener(() {
      final configsProvider = context.read<ConfigsProvider>();

      if (tabController.indexIsChanging) {
        if (configsProvider.showInterstitialBetweenTypes) {
          showInterstitialAd();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigsProvider>();
    dev.log(
        "Current version code: ${configProvider.currentVersionCode} | Newest version code: ${configProvider.newestVersionCode}");
    try {
      if (int.parse(configProvider.currentVersionCode) <
          int.parse(configProvider.newestVersionCode)) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'This version is outdated. Please update to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse(configProvider.updateUrl))) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Could not launch the URL: Please try again'),
                      ));
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      } else {
        return _Home(tabController: tabController);
      }
    } catch (e) {
      dev.log("Error: $e");
      return _Home(tabController: tabController);
    }
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(tabController: tabController),
      drawer: const DrawerNavigation(),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          TrendingFragment(),
          PopularFragment(),
          LatestFragment(),
          BrowseFragment(),
        ],
      ),
    );
  }
}

// void updateConsent() async {
//   // Make sure to continue with the latest consent info.
//   var info = await UserMessagingPlatform.instance.requestConsentInfoUpdate();
//   dev.log(
//       '\n====================== Updating Consent Form =============================\n');
//   // info = await UserMessagingPlatform.instance.showConsentForm();
//   // Show the consent form if consent is required.
//   if (info.consentStatus == ConsentStatus.required) {
//     // `showConsentForm` returns the latest consent info, after the consent from has been closed.
//     info = await UserMessagingPlatform.instance.showConsentForm();
//   }
// }
