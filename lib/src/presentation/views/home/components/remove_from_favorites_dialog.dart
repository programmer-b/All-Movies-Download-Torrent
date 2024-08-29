import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/strings.dart';
import '../../../state/favorites.dart';

class RemoveFromFavoritesDialog extends StatelessWidget {
   const RemoveFromFavoritesDialog({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(removeFromFavoritesTitle), // Use the variable
      content:  Text(removeFromFavoritesMessage), // Use the variable
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child:  Text(cancelText), // Use the variable
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<FavoritesProvider>()
                  .removeFavorite(item, getStringAsync("jwt"));
            },
            child:  Text(removeText)), // Use the variable
      ],
    );
  }
}
