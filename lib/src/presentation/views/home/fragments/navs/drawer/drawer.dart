import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../copy_right_fragment.dart';
import 'components/drawer_tile.dart';
import 'components/language_options.dart';
import 'header.dart';
import '../../../../../../utils/strings.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({super.key});

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  Widget _buildDrawerTile(String title, IconData icon,
      {bool isSelected = false,
      Widget? trailing,
      VoidCallback? onTap,
      bool dismissDrawer = false}) {
    return DrawerTile(
      title: title,
      icon: icon,
      isSelected: isSelected,
      trailing: trailing,
      onTap: onTap ??
          () {
            if (dismissDrawer) {
              Navigator.pop(context);
            }
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          const Header(),
          _buildDrawerTile(home, Icons.home,
              isSelected: true, dismissDrawer: true),
          _buildDrawerTile(myAccount, Icons.account_circle_outlined, onTap: () {
            Navigator.pushNamed(context, '/account');
          }),
          _buildDrawerTile(favorites, Icons.favorite_outline, onTap: () {
            Navigator.pushNamed(context, '/favorites');
          }),
          _buildDrawerTile(language, Icons.language_outlined,
              trailing: const LanguageOptions(), onTap: () {}),
          // _buildDrawerTile(report, Icons.report_outlined, onTap: () {
          //   Navigator.of(context).push(
          //       MaterialPageRoute(builder: (context) => const ReportNav()));
          // }),
          if(getJSONAsync("downloads", defaultValue: {}).isNotEmpty)
            _buildDrawerTile(downloads, Icons.download_outlined, onTap: () {
              Navigator.pushNamed(context, '/downloads');
            }),
          _buildDrawerTile(about, Icons.info_outline, onTap: () {
            Navigator.pushNamed(context, '/about');
          }),
          _buildDrawerTile(contactUs, Icons.contact_support_outlined,
              onTap: () {
            Navigator.pushNamed(context, '/contact');
          }),
          _buildDrawerTile(copyrightPolicy, Icons.copyright_outlined,
              onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CopyRightFragment(
                      isPage: true,
                    )));
          }),
          _buildDrawerTile(termsOfService, Icons.description_outlined,
              onTap: () {
            Navigator.pushNamed(context, '/terms');
          }),
          _buildDrawerTile(privacyPolicy, Icons.privacy_tip_outlined,
              onTap: () async {
            if (!await launchUrl(Uri.parse(
                "https://www.freeprivacypolicy.com/live/82a9344d-a32d-408e-99b5-4f851e840ded"))) {
              throw 'Could not launch url';
            }
          }),
          _buildDrawerTile(faq, Icons.question_answer_outlined, onTap: () {
            Navigator.pushNamed(context, '/faq');
          }),
        ],
      ),
    );
  }
}
