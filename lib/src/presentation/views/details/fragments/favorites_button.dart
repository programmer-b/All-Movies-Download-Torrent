import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../state/favorites.dart';
import '../../home/components/add_to_favorites_dialog.dart';
import '../../home/components/remove_from_favorites_dialog.dart';

class FavoritesButton extends StatefulWidget {
  const FavoritesButton({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<FavoritesButton> createState() => _FavoritesButtonState();
}

class _FavoritesButtonState extends State<FavoritesButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FavoritesProvider>()
          .favoriteExists(widget.item, getStringAsync("jwt"));
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return FloatingActionButton(
        onPressed: () async {
          if (favoritesProvider.loading) return;
          if (!favoritesProvider.exists) {
            await showDialog(
                context: context,
                builder: (_) => AddToFavoritesDialog(item: widget.item));
          } else {
            await showDialog(
                context: context,
                builder: (_) => RemoveFromFavoritesDialog(item: widget.item));
          }
        },
        child: favoritesProvider.loading
            ? const CircularProgressIndicator()
            : favoritesProvider.exists
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border));
  }
}
