import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

class FlagComponent extends StatelessWidget {
  const FlagComponent(this.flag, {super.key});

  final String flag;

  @override
  Widget build(BuildContext context) =>
      Flag.fromString(flag, height: 16, width: 16);
}
