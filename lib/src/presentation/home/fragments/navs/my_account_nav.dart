import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../authentication/auth_state.dart';

class MyAccountNavFragment extends StatefulWidget {
  const MyAccountNavFragment({super.key});

  @override
  State<MyAccountNavFragment> createState() => _MyAccountNavFragmentState();
}

class _MyAccountNavFragmentState extends State<MyAccountNavFragment> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Account"),
        ),
        body: !authProvider.isAuthenticated
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You need to be logged in to view this page"),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, "/login"), child: const Text("Login"))
            ],
          ),
        )
            : Builder(
            builder: (context) {
              final jwt = authProvider.jwt;
              final username = JwtDecoder.decode(jwt)?["sub"]["username"];
              final email = JwtDecoder.decode(jwt)?["sub"]["email"];
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(LineIcons.user),
                      title: const Text("Username", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      subtitle: Text(username, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(LineIcons.envelope),
                      title: const Text("Email", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      subtitle: Text(email, style: const TextStyle(fontSize: 18),),
                    ),
                  ),
                  //logout tile
                  Card(

                    child: ListTile(
                      // tileColor: Colors.redAccent,
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Are you sure you want to logout?'),
                              content: const Text('You will have to login again to access your account'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<AuthProvider>().logout();
                                    },
                                    child: const Text('Yes'))
                              ],
                            ));
                      },
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  //delete account tile
                  Card(
                    color: Colors.red.withOpacity(0.1),
                    child: ListTile(
                      // tileColor: Colors.redAccent,
                      leading: const Icon(LineIcons.trash),
                      title: const Text("Delete Account"),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Are you sure you want to delete your account?'),
                              content: const Text('This action cannot be undone'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<AuthProvider>().deleteAccount();
                                    },
                                    child: const Text('Yes'))
                              ],
                            ));
                      },
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ],
              );
            }
        ));
  }
}