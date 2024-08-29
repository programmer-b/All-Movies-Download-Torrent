import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../state/favorites.dart';
import '../../auth/auth_state.dart';

class AddToFavoritesDialog extends StatefulWidget {
  const AddToFavoritesDialog({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<AddToFavoritesDialog> createState() => _AddToFavoritesDialogState();
}

class _AddToFavoritesDialogState extends State<AddToFavoritesDialog> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return !authProvider.isAuthenticated
        ? AlertDialog(
            title: const Text('Not logged in'),
            content: const Text('You need to be logged in to add to favorites'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Login')),
            ],
          )
        : _FavoriteDialogBuilder(item: widget.item);
  }
}

class _FavoriteDialogBuilder extends StatefulWidget {
  const _FavoriteDialogBuilder({required this.item});

  final Map<String, dynamic> item;

  @override
  State<_FavoriteDialogBuilder> createState() => _FavoriteDialogBuilderState();
}

class _FavoriteDialogBuilderState extends State<_FavoriteDialogBuilder> {
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
    return AlertDialog(
        title: favoritesProvider.loading
            ? const Text('Checking...')
            : favoritesProvider.exists
                ? const Text('')
                : const Text('Add to favorites'),
        content: favoritesProvider.loading
            ? const LinearProgressIndicator()
            : favoritesProvider.exists
                ? const Text('Already in favorites')
                : const Text(
                    'Are you sure you want to add this to your favorites?'),
        actions: !favoritesProvider.loading
            ? [
                if (!favoritesProvider.exists)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (favoritesProvider.exists) {
                      Navigator.of(context).pop();
                    } else {
                      context
                          .read<FavoritesProvider>()
                          .addFavorite(widget.item, getStringAsync("jwt"));
                      Navigator.of(context).pop();
                    }
                  },
                  child: favoritesProvider.exists
                      ? const Text('Ok')
                      : const Text('Yes'),
                ),
              ]
            : []);
  }
}
