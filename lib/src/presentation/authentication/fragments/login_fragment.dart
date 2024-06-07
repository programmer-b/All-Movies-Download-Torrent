import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../utils/urls.dart';
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
          title: const Text('Login'),
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
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email or Username',
                      hintText: 'Enter your email or username',
                      prefixIcon: Icon(LineIcons.user),
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
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(LineIcons.lock),
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
                      child: const Text('Forgot Password?'),
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
                            //display snackbar and say login success
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login Successful'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      }),
                      child: const Text('Login'),
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
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child: const Text('Register'),
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
        ));
  }
}
