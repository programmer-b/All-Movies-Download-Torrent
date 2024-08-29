import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/strings.dart';
import '../../../auth/auth_state.dart';
import '../../components/not_logged_in.dart';
import '../../components/upgrade_button.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(myAccount)),
      body: !watcher.isAuthenticated
          ? const NotLoggedIn()
          : Builder(builder: (context) {
              final sub = JwtDecoder.decode(getStringAsync("jwt"))!["sub"];
              final String username = sub["username"];
              final String email = sub["email"];

              return Center(
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.account_circle,
                        size: 50, color: Colors.grey),
                    Text('@$username',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text(email,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    const SizedBox(height: 20),
                    const UpgradeButton(width: 200),
                    const SizedBox(height: 20),
                    _buildButton(context, Icons.logout, logout.toUpperCase(),
                        logoutConfirmationTitle, logoutConfirmationContent, () {
                      context.read<AuthProvider>().logout();
                    }),
                    const SizedBox(height: 20),
                    _buildButton(
                        context,
                        Icons.delete,
                        deleteAccount.toUpperCase(),
                        deleteAccountConfirmationTitle,
                        deleteAccountConfirmationContent, () {
                      context.read<AuthProvider>().deleteAccount();
                    }),
                  ],
                ),
              );
            }),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label,
      String title, String content, VoidCallback onConfirm) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(cancel)),
                  TextButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.of(context).pop();
                      },
                      child: Text(confirm)),
                ],
              );
            },
          );
        },
        label: Text(label),
      ),
    );
  }
}
