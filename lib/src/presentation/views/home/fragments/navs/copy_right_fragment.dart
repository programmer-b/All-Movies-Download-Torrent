import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utils/strings.dart';

class CopyRightFragment extends StatefulWidget {
  const CopyRightFragment({super.key, this.isPage = false});

  final bool isPage;

  @override
  State<CopyRightFragment> createState() => _CopyRightFragmentState();
}

class _CopyRightFragmentState extends State<CopyRightFragment> {
  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@films365.org',
      queryParameters: {
        'subject': 'DMCA Takedown Notice',
      },
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  bool _value = false;

  bool get value => _value;

  set value(bool newValue) {
    setState(() {
      _value = newValue;
    });
    setValue('notShowAgainCopyRight', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: !widget.isPage
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Checkbox(
                          side: const BorderSide(color: Colors.teal),
                          checkColor: Colors.white,
                          activeColor: Colors.teal,
                          hoverColor: Colors.teal,
                          value: value,
                          onChanged: (_) async {
                            value = !value;
                            if (value) {
                              await setValue('copyrightSeen', value);
                            } else {
                              await setValue('copyrightSeen', value);
                            }
                          }),
                      Text(
                        notShowAgainText, // Use the variable
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/home'),
                    child: Text(iAgreeText, // Use the variable
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : null,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: widget.isPage,
        leading: widget.isPage
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.teal),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        title: Text(copyRightPolicyTitle, // Use the variable
            style: const TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Divider(color: Theme.of(context).primaryColor),
          _CopyRightCohort(
            textSpan: TextSpan(
              children: [
                TextSpan(
                  text: copyRightText1, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText2, // Use the variable
              children: [
                TextSpan(
                  text: copyRightBoldText2, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: copyRightText3), // Use the variable
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              children: [
                TextSpan(
                  text: copyRightText4, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText5, // Use the variable
              children: [
                TextSpan(
                  text: copyRightBoldText5, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText6, // Use the variable
                ),
                TextSpan(
                  text: copyRightBoldText6, // Use the variable
                ),
                TextSpan(
                  text: copyRightBoldText7, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: copyRightText7), // Use the variable
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText8, // Use the variable
              children: [
                TextSpan(
                  text: copyRightBoldText8, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText9, // Use the variable
                ),
                TextSpan(
                    text: copyRightBoldText9, // Use the variable
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
                text: copyRightText10, // Use the variable
                children: [
                  TextSpan(
                    text: copyRightBoldText10, // Use the variable
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: copyRightText11, // Use the variable
                  ),
                  TextSpan(
                    text: copyRightBoldText11, // Use the variable
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ]),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText12, // Use the variable
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText13, // Use the variable
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText14, // Use the variable
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText15, // Use the variable
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText16, // Use the variable
              children: [
                TextSpan(
                  text: copyRightBoldText16, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText17, // Use the variable
                ),
                TextSpan(
                  text: copyRightBoldText17, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightEmailText, // Use the variable
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Open email
                      _launchEmail();
                    },
                ),
                TextSpan(
                  text: copyRightText18, // Use the variable
                )
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText19, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText20, // Use the variable
                ),
                TextSpan(
                  text: copyRightText21, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText22, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText23, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText24, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText25, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: copyRightText26, // Use the variable
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText27, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText28, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText29, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText30, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText31, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText32, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText33, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText34, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText35, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText36, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText37, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText38, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
            textSpan: TextSpan(
              text: copyRightText39, // Use the variable
              children: [
                TextSpan(
                  text: copyRightText40, // Use the variable
                ),
              ],
            ),
          ),
          _CopyRightCohort(
              textSpan: TextSpan(
            children: [
              TextSpan(
                style: const TextStyle(fontWeight: FontWeight.bold),
                text: copyRightText41, // Use the variable
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class _CopyRightCohort extends StatelessWidget {
  const _CopyRightCohort({required this.textSpan});

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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
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
