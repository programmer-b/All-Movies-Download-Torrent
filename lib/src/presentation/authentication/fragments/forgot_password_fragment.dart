import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/urls.dart';
import '../auth_state.dart';

class ForgotPasswordFragment extends StatefulWidget {
  const ForgotPasswordFragment({super.key});

  @override
  State<ForgotPasswordFragment> createState() => _ForgotPasswordFragmentState();
}

class _ForgotPasswordFragmentState extends State<ForgotPasswordFragment> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    final AuthProvider reader = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (watcher.validationError) {
                      if (watcher.validationErrors["errors"]?["input"] !=
                          null) {
                        return watcher.validationErrors["errors"]["input"];
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email or Username',
                    hintText: 'Enter your email username for verification',
                    prefixIcon: Icon(LineIcons.user),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => reader.submitCredentials(
                        credentials: {"input": _emailController.text.trim()},
                        endpoint: forgotPasswordUrl,
                        method: "PATCH",
                        context: context).then((response) {
                      if (_formKey.currentState!.validate()) {
                        if (response == "SUCCESS") {
                          Navigator.of(context)
                              .pushNamed("/verification", arguments: {
                            "isForgotPassword": true,
                          });
                        }
                      }
                    }),
                    child: const Text('Submit'),
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
