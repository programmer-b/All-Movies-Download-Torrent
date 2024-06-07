import 'package:flutter/material.dart';

import '../../../home_screen.dart';

class AskToLogin extends StatelessWidget {
  const AskToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login Required'),
      content: const Text('You need to login to access this feature'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            //push to home after login
            Navigator.pushNamed(context, "/login").then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
            });
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
