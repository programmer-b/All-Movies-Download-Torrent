import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/strings.dart';
import '../../../../state/favorites.dart';
import '../../../auth/auth_state.dart';
import '../../components/data_card.dart';
import '../../components/loading_page.dart';
import '../../components/not_logged_in.dart';
import '../../components/remove_from_favorites_dialog.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    final watcher = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(favorites),
      ),
      body: !watcher.isAuthenticated
          ? const NotLoggedIn()
          : const _BuildFavorites(),
    );
  }
}

class _BuildFavorites extends StatefulWidget {
  const _BuildFavorites();

  @override
  State<_BuildFavorites> createState() => _BuildFavoritesState();
}

class _BuildFavoritesState extends State<_BuildFavorites> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<FavoritesProvider>().getFavorites(getStringAsync("jwt")));
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    return favoritesProvider.loading
        ? const LoadingPage()
        : favoritesProvider.favorites.isEmpty
            ? const Center(
                child: Text('No favorites yet'),
              )
            : Builder(builder: (context) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, index) {
                    final item = favoritesProvider.favorites[index];
                    return DataCard(
                      whereId: "showInterstitialBetweenFavoritesAndDetails",
                      item: item,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return RemoveFromFavoritesDialog(item: item);
                              });
                        },
                      ),
                    );
                  },
                  itemCount: favoritesProvider.favorites.length,
                );
              });
  }
}
