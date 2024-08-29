import 'package:flutter/material.dart';
import '../../../../utils/strings.dart';
import 'login_button.dart';

class NotLoggedIn extends StatefulWidget {
   const NotLoggedIn({super.key});

  @override
  State<NotLoggedIn> createState() => _NotLoggedInState();
}

class _NotLoggedInState extends State<NotLoggedIn> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(notLoggedInText, style: const TextStyle(fontSize: 24)), // Use the variable
          Text(pleaseLogInText, style: const TextStyle(fontSize: 16)), // Use the variable
          const SizedBox(height: 20),
          const LoginButton(),
        ],
      ),
    );
  }
}
