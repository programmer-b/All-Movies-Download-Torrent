import 'package:flutter/material.dart';

import '../../../../utils/strings.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, "/login");
        },
        icon: const Icon(Icons.login),
        label: Text(loginText),
      ),
    );
  }
}
