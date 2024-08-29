import 'package:flutter/material.dart';

import '../../../../utils/strings.dart';

class ReportConfirmDialog extends StatelessWidget {
   const ReportConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(reportTitleText), // Use the variable
      content:  Text(reportContentMessage), // Use the variable
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child:  Text(cancel), // Use the variable
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child:  Text(reportText), // Use the variable
        ),
      ],
    );
  }
}
