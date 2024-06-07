import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../utils/urls.dart';
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
        title: const Text('Verification'),
        leading: BackButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Are you sure you want to go back?'),
                      content: const Text(
                          'You will have to start the registration process again with a new email address'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Yes'))
                      ],
                    ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                const Text(
                  'A verification code has been sent to your email address. Please enter the code below to verify your account.',
                  style: TextStyle(fontSize: 16),
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
                  decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter the verification code',
                      errorMaxLines: 3),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resendOTP,
                    child: const Text('Resend Code'),
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
                            //display snackbar and say login success
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification Successful'),
                                duration: Duration(seconds: 3),
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
                    child: const Text('Verify'),
                  ),
                ),
                if (!isForgotPassword) const SizedBox(height: 10),
                if (!isForgotPassword) const Text('OR'),
                if (!isForgotPassword) const SizedBox(height: 10),
                if (!isForgotPassword)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Skip Verification'),
                                content: const Text(
                                    'Are you sure you want to skip the verification process?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, "/home", (route) => false);
                                      },
                                      child: const Text('Yes'))
                                ],
                              )),
                      child: const Text('Skip Verification'),
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
