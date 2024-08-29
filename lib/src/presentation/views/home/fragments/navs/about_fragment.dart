import 'package:flutter/material.dart';

import '../../../../../utils/strings.dart';

class AboutFragment extends StatefulWidget {
   const AboutFragment({super.key});

  @override
  State<AboutFragment> createState() => _AboutFragmentState();
}

class _AboutFragmentState extends State<AboutFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(aboutTitleText), // Use the variable
      ),
      body: Padding(
        padding:  const EdgeInsets.all(8.0),
        child: ListView(
          physics:  const BouncingScrollPhysics(),
          children:  <Widget>[
            _AboutCohort(text: aboutCohort1), // Use the variable
            _AboutCohort(text: aboutCohort2), // Use the variable
            _AboutCohort(text: aboutCohort3), // Use the variable
            _AboutCohort(text: aboutCohort4), // Use the variable
            _AboutCohort(text: aboutCohort5), // Use the variable
            _AboutCohort(text: aboutCohort6), // Use the variable
            _AboutCohort(text: aboutCohort7), // Use the variable
          ],
        ),
      ),
    );
  }
}

class _AboutCohort extends StatelessWidget {
   const _AboutCohort({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Icon(
                Icons.circle,
                size: 6,
              ),
            ),
             const SizedBox(width: 8),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
         const SizedBox(height: 4),
      ],
    );
  }
}
