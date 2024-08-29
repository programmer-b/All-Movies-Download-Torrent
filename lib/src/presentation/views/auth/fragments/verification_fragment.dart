import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/strings.dart';
import '../../../../utils/urls.dart';
import '../auth_state.dart';

class VerificationFragment extends StatefulWidget {
   const VerificationFragment({super.key});

  @override
  State<VerificationFragment> createState() => _VerificationFragmentState();
}

class _VerificationFragmentState extends State<VerificationFragment> {
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> resendOTP() async {
    final jwt = getStringAsync("jwt");
    final uid = JwtDecoder.decode(jwt)?["sub"]["uid"];
    await http.post(Uri.parse(resendOTPUrl), body: {"uid": uid});
    toast("A new verification code has been sent to your email address");
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    final reader = context.read<AuthProvider>();
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final bool isForgotPassword = arguments["isForgotPassword"] ?? false;
    return Scaffold(
      appBar: AppBar(
        title:  Text(verificationTitle), // Use the variable
        leading: BackButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title:  Text(goBackDialogTitle),
                      // Use the variable
                      content:  Text(goBackDialogContent),
                      // Use the variable
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:  Text(noButtonText)),
                        // Use the variable
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child:  Text(yesButtonText)),
                        // Use the variable
                      ],
                    ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding:  const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                 Text(
                  verificationMessage, // Use the variable
                  style: const TextStyle(fontSize: 16),
                ),
                 const SizedBox(height: 10),
                TextFormField(
                  validator: (value) {
                    if (watcher.validationError) {
                      if (watcher.validationErrors["errors"]?["otp"] != null) {
                        return watcher.validationErrors["errors"]["otp"];
                      }
                    }
                    return null;
                  },
                  controller: _verificationCodeController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  decoration:  InputDecoration(
                      labelText: verificationCodeLabel, // Use the variable
                      hintText: verificationCodeHint, // Use the variable
                      errorMaxLines: 3),
                ),
                 const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resendOTP,
                    child:  Text(resendCodeText), // Use the variable
                  ),
                ),
                 const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final String jwt = getStringAsync('jwt');
                      reader.submitCredentials(
                          credentials: {
                            "jwt": jwt,
                            "otp": _verificationCodeController.text.trim()
                          },
                          endpoint: verifyUrl,
                          method: "POST",
                          context: context).then((response) {
                        if (_formKey.currentState!.validate()) {
                          if (response == "SUCCESS") {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(verificationSuccessMessage),
                                // Use the variable
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            if (isForgotPassword) {
                              Navigator.pushNamed(context, "/set_new_password");
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/home", (route) => false);
                            }
                          }
                        }
                      });
                    },
                    child:  Text(verifyButtonText), // Use the variable
                  ),
                ),
                if (!isForgotPassword)  const SizedBox(height: 10),
                if (!isForgotPassword)  Text(orText), // Use the variable
                if (!isForgotPassword)  const SizedBox(height: 10),
                if (!isForgotPassword)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title:  Text(skipVerificationDialogTitle),
                                // Use the variable
                                content:
                                     Text(skipVerificationDialogContent),
                                // Use the variable
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child:  Text(noButtonText)),
                                  // Use the variable
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, "/home", (route) => false);
                                      },
                                      child:  Text(yesButtonText))
                                  // Use the variable
                                ],
                              )),
                      child:  Text(
                          skipVerificationButtonText), // Use the variable
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
