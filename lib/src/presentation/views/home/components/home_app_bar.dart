import 'package:flutter/material.dart';

import '../../../../utils/strings.dart' as strings;
import '../fragments/forum/forum_tab.dart';
import '../fragments/search/search_fragment.dart';
import 'upgrade_dialog.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
   const HomeAppBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: TabBar(
        controller: tabController,
        tabs: [
          Tab(text: strings.trending),
           Tab(text: strings.popular),
           Tab(text: strings.latest),
           Tab(text: strings.browse),
        ],
      ),
      title:  Text(strings.home),
      actions: [
        Tooltip(
          message: strings.search,
          child: IconButton(
            icon:  const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) =>  const SearchFragment(),
              ),
            ),
          ),
        ),
        Tooltip(
          message: strings.forum,
          child: Stack(
            children: [
              IconButton(
                icon:  const Icon(Icons.forum),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>  const ForumTabFragment()));
                },
              ),
              Positioned(
                right: 11,
                top: 10,
                child: Container(
                  padding:  const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints:  const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: strings.upgrade,
          child: IconButton(
            icon:  const Icon(Icons.upgrade_outlined),
            onPressed: () => showDialog(
                context: context, builder: (_) =>  const UpgradeDialog()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
       const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
