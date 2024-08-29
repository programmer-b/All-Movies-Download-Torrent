import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile(
      {super.key,
        required this.title,
        required this.onTap,
        required this.isSelected,
        required this.icon,
        this.trailing});

  final String title;
  final Function onTap;
  final bool isSelected;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      splashColor: Colors.teal.withOpacity(0.1),
      trailing: trailing,
      onTap: () {
        onTap();
      },
    );
  }
}