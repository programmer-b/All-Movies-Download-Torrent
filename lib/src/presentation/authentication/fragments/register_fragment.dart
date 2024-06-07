import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/urls.dart';
import '../auth_components.dart';
import '../auth_state.dart';

class RegisterFragment extends StatefulWidget {
  const RegisterFragment({super.key});

  @override
  State<RegisterFragment> createState() => _RegisterFragmentState();
}

class _RegisterFragmentState extends State<RegisterFragment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    final reader = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
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
                      if (watcher.validationErrors["errors"]?["username"] !=
                          null) {
                        return watcher.validationErrors["errors"]["username"];
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icon(LineIcons.user),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (watcher.validationError) {
                      if (watcher.validationErrors["errors"]?["email"] !=
                          null) {
                        return watcher.validationErrors["errors"]["email"];
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
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
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  obscureText: watcher.registerPassObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(LineIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(watcher.registerPassObscure
                          ? LineIcons.eye
                          : LineIcons.eye_slash),
                      onPressed: () {
                        watcher.toggleRegisterPassObscure();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  validator: (value) {
                    if (watcher.validationError) {
                      if (watcher.validationErrors["errors"]
                              ?["confirm_password"] !=
                          null) {
                        return watcher.validationErrors["errors"]
                            ["confirm_password"];
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _confirmPasswordController,
                  obscureText: watcher.registerConfirmPassObscure,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(LineIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(watcher.registerConfirmPassObscure
                          ? LineIcons.eye
                          : LineIcons.eye_slash),
                      onPressed: () {
                        watcher.toggleRegisterConfirmPassObscure();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Register"),
                              content: const Text(
                                  "By clicking register you agree to our terms and conditions."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text("No")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Yes"))
                              ],
                            )).then((value) => value == true
                        ? reader.submitCredentials(
                            credentials: {
                                "username": _usernameController.text.trim(),
                                "email": _emailController.text.trim(),
                                "password": _passwordController.text.trim(),
                                "confirm_password":
                                    _confirmPasswordController.text.trim()
                              },
                            endpoint: registerUrl,
                            method: "POST",
                            context: context).then((response) {
                            if (_formKey.currentState!.validate()) {
                              if (response == "SUCCESS") {
                                //display snackbar and say login success
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Register Successful'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                dev.log(
                                    "Register Successful: now pushing to verification");
                                Navigator.of(context)
                                    .pushNamed("/verification", arguments: {
                                      "isForgotPassword": false,
                                });
                              }
                            }
                          })
                        : null),
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'OR',
                  style: TextStyle(
                    color: context.textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                // const SizedBox(height: 5),
                // Text(
                //   'OR',
                //   style: TextStyle(
                //     color: context.textTheme.bodyLarge!.color,
                //   ),
                // ),
                // const SizedBox(height: 5),
                // GoogleButton(
                //   context: context,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
