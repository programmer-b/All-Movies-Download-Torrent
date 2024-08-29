import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../utils/strings.dart';
import '../../../../utils/urls.dart';
import '../auth_state.dart';

class SetNewPasswordFragment extends StatefulWidget {
   const SetNewPasswordFragment({super.key});

  @override
  State<SetNewPasswordFragment> createState() => _SetNewPasswordFragmentState();
}

class _SetNewPasswordFragmentState extends State<SetNewPasswordFragment> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthProvider watcher = context.watch<AuthProvider>();
    final AuthProvider reader = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title:  Text(setNewPasswordTitle), // Use the variable
        leading: BackButton(onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title:  Text(goBackDialogTitle), // Use the variable
                content:  Text(goBackDialogContent), // Use the variable
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:  Text(noButtonText)), // Use the variable
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child:  Text(yesButtonText)), // Use the variable
                ],
              ));
        }),
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
                      if (watcher.validationErrors["error"]?["new_password"] !=
                          null) {
                        return watcher.validationErrors["error"]
                        ["new_password"];
                      }
                    }
                    return null;
                  },
                  obscureText: watcher.setNewPassObscure,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: newPasswordLabel, // Use the variable
                      hintText: newPasswordHint,   // Use the variable
                      prefixIcon:  const Icon(Icons.lock),
                      suffixIcon: watcher.setNewPassObscure
                          ? IconButton(
                        onPressed: () {
                          reader.toggleSetNewPassObscure();
                        },
                        icon:  const Icon(Icons.visibility),
                      )
                          : IconButton(
                        onPressed: () {
                          reader.toggleSetNewPassObscure();
                        },
                        icon:  const Icon(Icons.visibility_off),
                      )),
                ),
                TextFormField(
                  validator: (value) {
                    if (watcher.validationError) {
                      if (watcher.validationErrors["error"]
                      ?["confirm_new_password"] !=
                          null) {
                        return watcher.validationErrors["error"]
                        ["confirm_new_password"];
                      }
                    }
                    return null;
                  },
                  obscureText: watcher.setNewConfirmPassObscure,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: confirmNewPasswordLabel, // Use the variable
                    hintText: confirmNewPasswordHint,   // Use the variable
                    prefixIcon:  const Icon(Icons.lock),
                    suffixIcon: watcher.setNewConfirmPassObscure
                        ? IconButton(
                      onPressed: () {
                        reader.toggleSetNewConfirmPassObscure();
                      },
                      icon:  const Icon(Icons.visibility),
                    )
                        : IconButton(
                      onPressed: () {
                        reader.toggleSetNewConfirmPassObscure();
                      },
                      icon:  const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                 const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final String jwt = getStringAsync('jwt');
                      final uid = JwtDecoder.decode(jwt)?["sub"]["uid"];
                      final body = {
                        "new_password": _passwordController.text.trim(),
                        "confirm_new_password":
                        _confirmPasswordController.text.trim(),
                        "uid": uid
                      };
                      reader
                          .submitCredentials(
                          credentials: body,
                          endpoint: setNewPasswordUrl,
                          method: "POST",
                          context: context)
                          .then((response) {
                        if (_formKey.currentState!.validate()) {
                          if (response == "SUCCESS") {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(setNewPasswordSuccessMessage), // Use the variable
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/home", (route) => false);
                          }
                        }
                      });
                    },
                    child:  Text(setNewPasswordButtonText), // Use the variable
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
