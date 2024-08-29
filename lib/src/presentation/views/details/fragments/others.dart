import 'package:flutter/material.dart';
import '../../../../utils/strings.dart';

class Others extends StatelessWidget {
   const Others({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.containsKey('production_countries'))
          RichText(
            text: TextSpan(
              children: [
                 TextSpan(
                  text: '$productionCountriesText: ', // Use the variable
                ),
                TextSpan(
                  text: details['production_countries'],
                  style:  const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
         const SizedBox(height: 8),
        if (details.containsKey('production_companies'))
          RichText(
            text: TextSpan(
              children: [
                 TextSpan(
                  text: '$productionCompaniesText: ', // Use the variable
                ),
                TextSpan(
                  text: details['production_companies'],
                  style:  const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
         const SizedBox(height: 8),
        if (details.containsKey('spoken_languages'))
          RichText(
            text: TextSpan(
              children: [
                 TextSpan(
                  text: '$spokenLanguagesText: ', // Use the variable
                ),
                TextSpan(
                  text: details['spoken_languages'],
                  style:  const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
