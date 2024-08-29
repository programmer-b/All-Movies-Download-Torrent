import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/strings.dart';
import '../../../../utils/urls.dart';
import '../auth_state.dart';

class LoginFragment extends StatefulWidget {
   const LoginFragment({super.key});

  @override
  State<LoginFragment> createState() => _LoginFragmentState();
}

class _LoginFragmentState extends State<LoginFragment> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    final reader = context.read<AuthProvider>();
    return Scaffold(
        appBar: AppBar(
          title:  Text(loginTitle), // Use the variable
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding:  const EdgeInsets.all(8.0),
              child: Column(
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
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration:  InputDecoration(
                      errorMaxLines: 2,
                      labelText: emailOrUsernameLabel, // Use the variable
                      hintText: emailOrUsernameHint,   // Use the variable
                      prefixIcon: const Icon(LineIcons.user),
                    ),
                  ),
                   const SizedBox(height: 10),
                  TextFormField(
                    validator: (value) {
                      if (watcher.validationError) {
                        if (watcher.validationErrors["errors"]?["password"] !=
                            null) {
                          return watcher.validationErrors["errors"]["password"];
                        }
                      }
                      return null;
                    },
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: watcher.loginPassObscure,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      labelText: passwordLabel, // Use the variable
                      hintText: passwordHint,   // Use the variable
                      prefixIcon:  const Icon(LineIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(watcher.loginPassObscure
                            ? LineIcons.eye
                            : LineIcons.eye_slash),
                        onPressed: () {
                          watcher.toggleLoginPassObscure();
                        },
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/forgot_password'),
                      child:  Text(forgotPasswordText), // Use the variable
                    ),
                  ),
                   const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => reader.submitCredentials(
                          credentials: {
                            "input": _emailController.text.trim(),
                            "password": _passwordController.text.trim()
                          },
                          endpoint: loginUrl,
                          method: "POST",
                          context: context).then((response) {
                        if (_formKey.currentState!.validate()) {
                          if (response == "SUCCESS") {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(loginSuccessMessage), // Use the variable
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      }),
                      child:  Text(loginButtonText), // Use the variable
                    ),
                  ),
                   const SizedBox(height: 5),
                  Text(
                    orText, // Use the variable
                    style: TextStyle(
                      color: context.textTheme.bodyLarge!.color,
                    ),
                  ),
                   const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                       Text(dontHaveAccountText), // Use the variable
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child:  Text(registerText), // Use the variable
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
