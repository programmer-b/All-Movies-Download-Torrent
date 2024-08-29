import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../../../utils/languages.dart';
import '../../../../../../state/configs.dart';
import '../../../../components/flag_component.dart';
import 'confirm_change_dialog.dart';

class LanguageOptions extends StatefulWidget {
  const LanguageOptions({super.key});

  @override
  State<LanguageOptions> createState() => _LanguageOptionsState();
}

class _LanguageOptionsState extends State<LanguageOptions> {
  void _onLanguageChange(String value) async {
    await 300.milliseconds.delay;
    if (mounted) {
      final configs = context.read<ConfigsProvider>();
      if (configs.language != value) {
        final results = await showDialog(
            context: context,
            builder: (context) => const ConfirmChangeDialog());
        if (results == true) {
          if (mounted) {
            configs.setLanguage(value);
            EasyLocalization.of(context)?.setLocale(Locale(value)).then((value) {
              setState(() {});
              RestartAppWidget.init(context);
            });

          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.watch<ConfigsProvider>();
    return DropdownButton<String>(
        value: configs.language,
        items: List.generate(languages.length, (index) {
          final language = languages[index];
          return DropdownMenuItem<String>(
            value: language['code'],
            child: Row(
              children: [
                FlagComponent(language['flag'] as String),
                const SizedBox(width: 8),
                Text(language['name'] as String),
              ],
            ),
          );
        }),
        onChanged: (value) => _onLanguageChange(value as String));
  }
}
