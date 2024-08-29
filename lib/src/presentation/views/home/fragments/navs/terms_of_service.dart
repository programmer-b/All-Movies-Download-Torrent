import 'package:flutter/material.dart';

import '../../../../../utils/strings.dart';

class TermsOfUseFragment extends StatefulWidget {
   const TermsOfUseFragment({super.key});

  @override
  State<TermsOfUseFragment> createState() => _TermsOfUseFragmentState();
}

class _TermsOfUseFragmentState extends State<TermsOfUseFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon:  const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title:
             Text(termsOfUseTitle, style: const TextStyle(color: Colors.teal)),
        // Use the variable
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding:  const EdgeInsets.all(16),
        children: [
          Divider(color: Theme.of(context).primaryColor),
          _TermsOfUseCohort(
            textSpan: TextSpan(
              children: [
                TextSpan(
                  text: welcomeText, // Use the variable
                  style:  const TextStyle(fontWeight: FontWeight.bold),
                ),
                 TextSpan(
                  text: welcomeMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: useOfAppText, // Use the variable
              children: [
                TextSpan(
                  text: useOfAppMessage, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: contentOwnershipText, // Use the variable
              children: [
                TextSpan(
                  text: contentOwnershipMessage1, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: copyrightPolicyText, // Use the variable
              children: [
                TextSpan(
                  text: copyrightPolicyMessage, // Use the variable
                ),
                TextSpan(
                  text: adminEmail, // Use the variable
                  style: const TextStyle(color: Colors.blue),
                ),
                TextSpan(
                  text: contactResponseMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: userResponsibilitiesText, // Use the variable
              children: [
                TextSpan(
                  text: userResponsibilitiesMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: limitationOfLiabilityText, // Use the variable
              children: [
                TextSpan(
                  text: limitationOfLiabilityMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: modificationOfTermsText, // Use the variable
              children: [
                TextSpan(
                  text: modificationOfTermsMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              text: governingLawText, // Use the variable
              children: [
                TextSpan(
                  text: governingLawMessage, // Use the variable
                ),
              ],
            ),
          ),
           _TermsOfUseCohort(
            textSpan: TextSpan(
              children: [
                TextSpan(
                  text: bindingAgreementText, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsOfUseCohort extends StatelessWidget {
   const _TermsOfUseCohort({required this.textSpan});

  final TextSpan textSpan;

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
                size: 5,
                color: Colors.black,
              ),
            ),
             const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style:  const TextStyle(fontSize: 16, color: Colors.black),
                  children: textSpan.children,
                  text: textSpan.text,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
         const SizedBox(height: 4),
      ],
    );
  }
}