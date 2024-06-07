import 'dart:developer' as dev;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucy/src/presentation/home/fragments/tabs/forum/forum_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' as utils;

import 'copyright_policy.dart';
import 'firebase_options.dart';
import 'src/presentation/authentication/auth_state.dart';
import 'src/presentation/authentication/fragments/forgot_password_fragment.dart';
import 'src/presentation/authentication/fragments/login_fragment.dart';
import 'src/presentation/authentication/fragments/register_fragment.dart';
import 'src/presentation/authentication/fragments/set_new_password_fragment.dart';
import 'src/presentation/authentication/fragments/verification_fragment.dart';
import 'src/presentation/details/download_screen.dart';
import 'src/presentation/details/person_screen.dart';
import 'src/presentation/details/seasons_screen.dart';
import 'src/presentation/details/torrent_screen.dart';
import 'src/presentation/details/trailer_screen.dart';
import 'src/presentation/home/data_state.dart';
import 'src/presentation/home/fragments/browse_display.dart';
import 'src/presentation/home/fragments/navs/about_us_nav.dart';
import 'src/presentation/home/fragments/navs/my_account_nav.dart';
import 'src/presentation/home/fragments/navs/my_list_nav.dart';
import 'src/presentation/home/fragments/search_fragment.dart';
import 'src/presentation/home/home_screen.dart';
import 'src/state/home_state.dart';
import 'src/utils/ads_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  await utils.initialize();
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // utils.setOrientationPortrait();

  final appOpenShowed = utils.getBoolAsync("appOpenShowed");
  if (!appOpenShowed) {
    await utils.setValue("appOpenShowed", true);
  } else {
    loadAppOpenAd();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future _determineSafety() async {
    var deviceInfo = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfo.androidInfo;
    var isPhysicalDevice = androidDeviceInfo.isPhysicalDevice;
    dev.log("Is physical device: $isPhysicalDevice");
    isRealDevice = isPhysicalDevice;
    // isRealDevice = true;
  }

  Future<void> _getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionCode = packageInfo.buildNumber;
    currentBuildNumber = versionCode;
    debugPrint('Version Code: $versionCode');
  }

  Future<void> _prepare() async {
    await _getVersionCode();
    await _determineSafety();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeState()..initialize()),
        ChangeNotifierProvider(create: (_) => DataState()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider())
      ],
      child: FutureBuilder(
          future: _prepare(),
          builder: (context, snapshot) {
            final provider = Provider.of<AuthProvider>(context);
            if (utils.getStringAsync("jwt").isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                provider.login();
              });
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return MaterialApp(
                routes: {
                  '/home': (context) => const HomeScreen(),
                  '/login': (context) => const LoginFragment(),
                  '/register': (context) => const RegisterFragment(),
                  '/verification': (context) => const VerificationFragment(),
                  '/set_new_password': (context) =>
                      const SetNewPasswordFragment(),
                  '/forgot_password': (context) =>
                      const ForgotPasswordFragment(),
                  '/browse': (context) => const BrowseReceiver(),
                  '/search': (context) => const SearchFragment(),
                  // '/details': (context) => const DetailsReceiver(),
                  '/video': (context) => const TrailerReceiver(),
                  '/person': (context) => const PersonReceiver(),
                  '/torrents': (context) => const TorrentReceiver(),
                  '/seasons': (context) => const SeasonsReceiver(),
                  '/download': (context) => const DownloadReceiver(),
                  '/my-list': (context) => const MyListNavFragment(),
                  '/my-account': (context) => const MyAccountNavFragment(),
                  '/about-us': (context) => const AboutUsNavFragment(),
                },
                title: 'AB OO1',
                theme: ThemeData(
                  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  brightness: Brightness.dark,
                  useMaterial3: true,
                ),
                home: Builder(
                  builder: (context) {
                    final copyrightSeen = utils.getBoolAsync("copyrightSeen");
                    return copyrightSeen
                        ? const HomeScreen()
                        : const CopyrightPolicyDialog();
                  }
                ),
              );
            }
            return MaterialApp(
                theme: ThemeData(
                  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  brightness: Brightness.dark,
                  useMaterial3: true,
                ),
                home: const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ));
          }),
    );
  }
}

bool isRealDevice = true;
String currentBuildNumber = '0';

AppOpenAd? myAppOpenAd;

loadAppOpenAd() {
  AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId, //Your ad Id from admob
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            myAppOpenAd = ad;
            myAppOpenAd!.show();
          },
          onAdFailedToLoad: (error) {}));
}
