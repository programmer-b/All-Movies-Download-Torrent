import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import 'firebase_analytics_service.dart';
import 'firebase_options.dart';
import 'platform_channel.dart';
import 'src/presentation/state/ads_manager.dart';
import 'src/presentation/state/configs.dart';
import 'src/presentation/state/contact.dart';
import 'src/presentation/state/data_state.dart';
import 'src/presentation/state/details.dart';
import 'src/presentation/state/favorites.dart';
import 'src/presentation/state/home.dart';
import 'src/presentation/state/report.dart';
import 'src/presentation/views/auth/auth_state.dart';
import 'src/presentation/views/auth/fragments/forgot_password_fragment.dart';
import 'src/presentation/views/auth/fragments/login_fragment.dart';
import 'src/presentation/views/auth/fragments/register_fragment.dart';
import 'src/presentation/views/auth/fragments/set_new_password_fragment.dart';
import 'src/presentation/views/auth/fragments/verification_fragment.dart';
import 'src/presentation/views/details/details.dart';
import 'src/presentation/views/home/fragments/forum/forum_tab.dart';
import 'src/presentation/views/home/fragments/navs/about_fragment.dart';
import 'src/presentation/views/home/fragments/navs/contact.dart';
import 'src/presentation/views/home/fragments/navs/copy_right_fragment.dart';
import 'src/presentation/views/home/fragments/navs/downloads_nav.dart';
import 'src/presentation/views/home/fragments/navs/faq.dart';
import 'src/presentation/views/home/fragments/navs/favorites.dart';
import 'src/presentation/views/home/fragments/navs/my_account.dart';
import 'src/presentation/views/home/fragments/navs/terms_of_service.dart';
import 'src/presentation/views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeServices();
  runApp(const Intermediary());
}

Future<void> _initializeServices() async {
  try {
    await MobileAds.instance.initialize();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    PlatformChannel.disableScreenshots();

    await EasyLocalization.ensureInitialized();

    await initialize();
  } catch (e) {
    developer.log('Initialization error: $e');
  }
}

class Intermediary extends StatefulWidget {
  const Intermediary({super.key});

  @override
  State<Intermediary> createState() => _IntermediaryState();
}

class _IntermediaryState extends State<Intermediary> {
  @override
  void initState() {
    super.initState();
    final AdsManager adsManager = AdsManager();
    adsManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..login()),
        ChangeNotifierProvider(create: (_) => ConfigsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => DataState()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: RestartAppWidget(
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('de'),
            Locale('pt'),
            Locale('ar'),
            Locale('zh'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          saveLocale: true,
          useOnlyLangCode: true,
          child: Builder(
            builder: (context) {
              final setLanguage = context.read<ConfigsProvider>().language;
              context.setLocale(Locale(setLanguage));
              return const MyApp();
            },
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsService = AnalyticsService();

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.deviceLocale,
      navigatorObservers: [analyticsService.getAnalyticsObserver()],
      routes: _buildRoutes(),
      title: 'All Movies Downloader',
      theme: _buildThemeData(),
      home: Builder(builder: (context) {
        final bool notShowAgainCopyRight = getBoolAsync('copyrightSeen');
        if (!notShowAgainCopyRight) {
          return const CopyRightFragment();
        }
        return const HomeScreen();
      }),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginFragment(),
      '/register': (context) => const RegisterFragment(),
      '/verification': (context) => const VerificationFragment(),
      '/set_new_password': (context) => const SetNewPasswordFragment(),
      '/forgot_password': (context) => const ForgotPasswordFragment(),
      '/home': (context) => const HomeScreen(),
      '/account': (context) => const MyAccount(),
      '/favorites': (context) => const Favorites(),
      '/details': (context) => const Details(),
      '/contact': (context) => const ContactFragment(),
      '/about': (context) => const AboutFragment(),
      '/copy-right': (context) => const CopyRightFragment(),
      '/terms': (context) => const TermsOfUseFragment(),
      '/faq': (context) => const FaqFragment(),
      '/downloads': (context) => const DownloadsNav(),
    };
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: createMaterialColor(const Color(0xFF008B8B)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF008B8B),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
