import 'package:flutter/material.dart';

import '../../../../utils/strings.dart';
import 'upgrade_dialog.dart';

class UpgradeButton extends StatelessWidget {
  const UpgradeButton({super.key, this.width = 150});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
          onPressed: () => showDialog(
              context: context, builder: (_) => const UpgradeDialog()),
          icon: const Icon(Icons.upgrade),
          label: Text(upgrade.toUpperCase())),
    );
  }
}
