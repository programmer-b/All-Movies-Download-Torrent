import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/strings.dart';

class UpgradeDialog extends StatelessWidget {
   const UpgradeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(upgradeTitleText), // Use the variable
      content:  Text(upgradeContentText), // Use the variable
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text(cancel), // Use the variable
        ),
        ElevatedButton(
          onPressed: () async {
            if (!await launchUrl(Uri.parse(
                "https://play.google.com/store/apps/details?id=com.dantech.all_movies_downloder_premium"))) {
              toast(couldNotLaunchUrlText, bgColor: Colors.red); // Use the variable
            }
          },
          child:  Text(upgradeButtonText), // Use the variable
        ),
      ],
    );
  }
}
