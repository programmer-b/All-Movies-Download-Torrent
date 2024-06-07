import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../authentication/auth_state.dart';
import 'navs/downloads_nav.dart';

class DrawerFragment extends StatefulWidget {
  const DrawerFragment({super.key});

  @override
  State<DrawerFragment> createState() => _DrawerFragmentState();
}

class _DrawerFragmentState extends State<DrawerFragment> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return SizedBox(
        width: context.width() * 0.5,
        height: context.height(),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const _DrawerHeader(),
              _listTile(
                isSelected: true,
                icon: Icons.home_filled,
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _listTile(
                icon: LineIcons.user,
                title: 'My Account',
                onTap: () {
                  Navigator.pushNamed(context, "/my-account");
                },
              ),
              // _listTile(
              //   icon: Icons.list_alt_outlined,
              //   title: 'My List',
              //   onTap: () {
              //     Navigator.pushNamed(context, "/my-list");
              //   },
              // ),
              _listTile(
                  icon: Icons.download_for_offline,
                  title: "Downloads",
                  onTap: () => DownloadsNav().launch(context)),
              if (authProvider.isAuthenticated)
                _listTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                  "Are you sure you want to logout?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("No")),
                                TextButton(
                                    onPressed: () {
                                      authProvider.logout();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Yes"))
                              ],
                            ));
                  },
                ),
              _listTile(
                  icon: Icons.info_outline,
                  title: "About Us",
                  onTap: () => Navigator.pushNamed(context, '/about-us')),
              _listTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () async {
                  //launch url
                  if (!await launchUrl(Uri.parse(
                      "https://www.freeprivacypolicy.com/live/82a9344d-a32d-408e-99b5-4f851e840ded"))) {
                    if (mounted) {
                      toast("Could not launch url");
                    }
                  }
                },
              ),
              _listTile(
                  icon: Icons.star,
                  title: "Rate Us",
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Rate Us"),
                            content: const Text("Rate us on Play Store"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No")),
                              TextButton(
                                  onPressed: () async {
                                    try {
                                      if (!await launchUrl(Uri.parse(
                                          "https://play.google.com/store/apps/details?id=com.dantech.all_movies_downloader_new&hl=en&gl=US"))) {
                                        toast("Could not launch url");
                                      }
                                    } on Exception catch (e) {
                                      toast(
                                        "$e",
                                        gravity: ToastGravity.TOP,
                                      );
                                    }
                                  },
                                  child: const Text("Yes"))
                            ],
                          );
                        });
                  }),
              _listTile(
                icon: Icons.share,
                title: "Share App",
                onTap: () async => await Share.share(
                    "https://play.google.com/store/apps/details?id=com.dantech.all_movies_downloader_new&hl=en&gl=US"),
              )
            ],
          ),
        ));
  }

  Widget _listTile(
      {required IconData icon,
      required String title,
      required void Function() onTap,
      bool isSelected = false}) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.grey.withOpacity(0.2),
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return DrawerHeader(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (authProvider.isAuthenticated)
            Builder(builder: (context) {
              final String username =
                  JwtDecoder.decode(getStringAsync("jwt"))!["sub"]["username"];
              return Column(children: [
                const Icon(
                  LineIcons.user,
                  size: 50,
                ),
                Text(
                  username,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ]);
            }),
          if (!authProvider.isAuthenticated)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
            ),
          10.height,
          ElevatedButton(
              onPressed: () => showPremium(context: context),
              child: const Text("UPGRADE",
                  style: TextStyle(
                    color: Colors.white,
                  )))
        ],
      ),
    );
  }
}

void showPremium({required BuildContext context}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upgrade to Premium"),
          content: const Text("Download our premium app that has no ADS"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            TextButton(
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(
                      "https://play.google.com/store/apps/details?id=com.dantech.all_movies_downloder_premium&hl=en&gl=US"))) {
                    toast("Could not launch url");
                  }
                },
                child: const Text("Yes"))
          ],
        );
      });
}
