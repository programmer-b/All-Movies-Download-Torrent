import 'package:flutter/material.dart';

import '../../../../../../../utils/strings.dart';

class ConfirmChangeDialog extends StatelessWidget {
   const ConfirmChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(confirmChangeTitle),
      content:  Text(confirmChangeContent),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child:  Text(no),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child:  Text(yes),
        ),
      ],
    );
  }
}