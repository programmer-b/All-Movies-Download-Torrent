import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/strings.dart' as strings;
import '../../../state/details.dart';
import '../../../state/home.dart';

class ErrorPage extends StatelessWidget {
   const ErrorPage(
      {super.key, this.isPost = false, this.isDetails = false, this.retry});

  final bool isPost;
  final bool isDetails;
  final void Function()? retry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(strings.error,
                style: const TextStyle(fontSize: 24.0), textAlign: TextAlign.center),
             const SizedBox(height: 16),
            ElevatedButton(
              onPressed: retry ??
                  () => isPost
                      ? context.read<HomeProvider>().retryPost()
                      : isDetails
                          ? context.read<HomeProvider>().retry()
                          : context.read<DetailsProvider>().retry(),
              child:  Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
