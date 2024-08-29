import 'package:flutter/material.dart';

import '../../../../../utils/strings.dart';
import '../../home_screen.dart';

class AskToLogin extends StatelessWidget {
   const AskToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(loginRequiredTitle), // Use the variable
      content:  Text(loginRequiredMessage), // Use the variable
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child:  Text(cancelText), // Use the variable
        ),
        TextButton(
          onPressed: () async {
            //push to home after login
            Navigator.pushNamed(context, "/login").then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const HomeScreen()));
            });
          },
          child:  Text(loginText), // Use the variable
        ),
      ],
    );
  }
}
