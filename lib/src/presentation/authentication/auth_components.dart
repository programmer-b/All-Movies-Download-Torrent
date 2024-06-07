import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'auth_state.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Continue with Google?'),
                  content: const Text(
                      'By continuing with Google, you agree to our terms and conditions'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Yes'))
                  ],
                )).then((value) =>
            value ? watcher.signInWithGoogle(context: this.context) : null),
        icon: const FaIcon(FontAwesomeIcons.google),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
