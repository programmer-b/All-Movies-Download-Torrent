import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CopyrightPolicyDialog extends StatefulWidget {
  const CopyrightPolicyDialog({super.key});

  @override
  State<CopyrightPolicyDialog> createState() => _CopyrightPolicyDialogState();
}

class _CopyrightPolicyDialogState extends State<CopyrightPolicyDialog> {
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        brightness: Brightness.light,
      ),
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Column(
            children: [
              Divider(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(value: _isChecked, onChanged: (value) async {
                    setState(() {
                      _isChecked = value!;
                    });
                    if(_isChecked){
                      await setValue("copyrightSeen", true);
                    } else {
                      await setValue("copyrightSeen", false);
                    }
                  }),

                  Text(
                    'Not show again',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: const Text(
                        "I Agree",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        appBar: AppBar(
            title: Text(
              'Copyright Policy',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary),
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: '1. Purpose of the App: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'All Movies Downloader is a search engine designed to provide information sourced from various torrent sites. We do not host any torrents or actual files for download. Our app serves as a platform for indexing and retrieving information available on other torrent sites, similar to the function of search engines like Google.\n\n',
                      ),
                      TextSpan(
                        text: '2. Disclaimer of Responsibility: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'We want to emphasize that we are not a torrent tracker, and we have no direct relationship with any torrent site. Users of our app are responsible for the content they choose to upload or access. All files are hosted on users\' computers, not on our app. Therefore, we cannot be held liable for any user-created/uploaded content or for any torrent files indexed from other sites.\n\n',
                      ),
                      TextSpan(
                        text: '3. Copyrighted Material: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'We do not create, modify, distribute, or manage any copyrighted files. If you believe that your copyrighted material has been linked to by our app without authorization, please follow the procedure outlined in our Copyright Infringement Claim section below.\n\n',
                      ),
                      TextSpan(
                        text: '4. Warranty Disclaimer: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'All information and services provided by All Movies Downloader are offered on an "as is" basis, without warranty of any kind. We disclaim all representations and warranties, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not guarantee the accuracy, completeness, or error-free nature of the information accessible via our app.\n\n',
                      ),
                      TextSpan(
                        text: '5. Limitation of Liability: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'In no event shall All Movies Downloader be liable for any consequential, indirect, incidental, special, or punitive damages arising from your use of our app or the information, services, products, and materials contained therein, even if we have been advised of the possibility of such damages.\n\n',
                      ),
                      TextSpan(
                        text: '6. Copyright Infringement Claim: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'If you believe that your copyrighted material has been infringed upon by our app, you must submit a notice to us containing specific information as outlined below. Please send your infringement notice to admin@films365.org.\n\n',
                      ),
                      TextSpan(
                        text: '7. Content Responsibility: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'We are not responsible for the content available in our app or the content users choose to access or utilize. If you encounter any content that violates DMCA policies, please contact us at admin@films365.org, and we will promptly investigate and take appropriate action, including content removal if necessary.\n\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}