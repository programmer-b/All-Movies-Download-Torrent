import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../auth/auth_state.dart';
import '../../../components/login_button.dart';
import '../../../components/upgrade_button.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<AuthProvider>();
    return DrawerHeader(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (watcher.isAuthenticated)
            Builder(builder: (context) {
              final sub = JwtDecoder.decode(getStringAsync("jwt"))!["sub"];
              final String username = sub["username"];
              // final String email = sub["email"];
              return Column(children: [
                const Icon(
                  Icons.account_circle,
                  size: 50,
                  color: Colors.grey,
                ),
                Text(
                  '@$username',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ]);
            }),
          if (!watcher.isAuthenticated) const LoginButton(),
          10.height,
          const UpgradeButton()
        ],
      ),
    );
  }
}
