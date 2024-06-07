import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../utils/urls.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    _jwt = getStringAsync("jwt");
    notifyListeners();
  }

  void logout() async {
    _isAuthenticated = false;
    await setValue("jwt", "");
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    jwt = "";
    toast("You have been logged out.");
    notifyListeners();
  }

  void deleteAccount() async {
    final jwt = getStringAsync("jwt");
    final uid = JwtDecoder.decode(jwt)?["sub"]["uid"];
    final username = JwtDecoder.decode(jwt)?["sub"]["username"];
    final email = JwtDecoder.decode(jwt)?["sub"]["email"];
    final response = await http.delete(Uri.parse(deleteUserUrl), body: {
      "jwt": jwt,
      "username": username,
      "email": email,
    });
    final result = json.decode(response.body);
    dev.log("Delete Account Result: $result");
    if (response.statusCode ~/ 100 == 2) {
      logout();
      toast("Your account has been deleted.");
    } else {
      toast(result["message"]);
    }
  }

  String _jwt = "";

  String get jwt => _jwt;

  set jwt(String value) {
    _jwt = value;
    notifyListeners();
  }

  bool _loginPassObscure = true;

  bool get loginPassObscure => _loginPassObscure;

  void toggleLoginPassObscure() {
    _loginPassObscure = !_loginPassObscure;
    notifyListeners();
  }

  bool _registerPassObscure = true;

  bool get registerPassObscure => _registerPassObscure;
  bool _registerConfirmPassObscure = true;

  bool get registerConfirmPassObscure => _registerConfirmPassObscure;

  void toggleRegisterPassObscure() {
    _registerPassObscure = !_registerPassObscure;
    notifyListeners();
  }

  void toggleRegisterConfirmPassObscure() {
    _registerConfirmPassObscure = !_registerConfirmPassObscure;
    notifyListeners();
  }

  bool _setNewPassObscure = true;
  bool _setNewConfirmPassObscure = true;

  bool get setNewPassObscure => _setNewPassObscure;

  bool get setNewConfirmPassObscure => _setNewConfirmPassObscure;

  void toggleSetNewPassObscure() {
    _setNewPassObscure = !_setNewPassObscure;
    notifyListeners();
  }

  void toggleSetNewConfirmPassObscure() {
    _setNewConfirmPassObscure = !_setNewConfirmPassObscure;
    notifyListeners();
  }

  bool _resetOldPassObscure = true;

  bool get resetOldPassObscure => _resetOldPassObscure;

  bool _resetNewPassObscure = true;

  bool get resetNewPassObscure => _resetNewPassObscure;

  bool _resetConfirmPassObscure = true;

  bool get resetConfirmPassObscure => _resetConfirmPassObscure;

  void toggleResetOldPassObscure() {
    _resetOldPassObscure = !_resetOldPassObscure;
    notifyListeners();
  }

  void toggleResetNewPassObscure() {
    _resetNewPassObscure = !_resetNewPassObscure;
    notifyListeners();
  }

  void toggleResetConfirmPassObscure() {
    _resetConfirmPassObscure = !_resetConfirmPassObscure;
    notifyListeners();
  }

  Map<String, dynamic> _validationErrors = {};

  Map<String, dynamic> get validationErrors => _validationErrors;

  void setValidationErrors(Map<String, dynamic> value) {
    _validationErrors = value;
    notifyListeners();
  }

  Map<String, dynamic> _result = {};

  Map<String, dynamic> get result => _result;

  void setResult(Map<String, dynamic> value) {
    _result = value;
    notifyListeners();
  }

  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _error = false;

  bool get error => _error;

  bool _validationError = false;

  bool get validationError => _validationError;

  void setValidationError(bool value) {
    _validationError = value;
    notifyListeners();
  }

  void setError(bool value) {
    _error = value;
    notifyListeners();
  }

  bool _success = false;

  bool get success => _success;

  void setSuccess(bool value) {
    _success = value;
    notifyListeners();
  }

  void init() {
    _loading = false;
    _error = false;
    _success = false;
    _validationError = false;
    _validationErrors = {};
    _result = {};
    notifyListeners();
  }

  Future<Map<String, dynamic>> _call(
      {required String endpoint,
      required String method,
      Map<String, dynamic>? body}) async {
    init();
    setLoading(true);
    try {
      final Uri uri = Uri.parse(endpoint);
      final request = http.Request(method, uri);
      if (body != null) {
        request.body = json.encode(body);
        request.headers['Content-Type'] = 'application/json';
      }
      final response = await http.Client().send(request);
      final results = await response.stream.bytesToString();
      final result = json.decode(results);
      dev.log("Result: $result");
      final statusCode = response.statusCode;
      if (statusCode >= 500) {
        setError(true);
        return result;
      }
      if (statusCode ~/ 100 != 2) {
        setValidationErrors(result);
        setValidationError(true);
        return result;
      }
      setSuccess(true);
      setResult(result);
      return result;
    } catch (e) {
      setError(true);
      return {};
    } finally {
      setLoading(false);
    }
  }

  Future<String?> submitCredentials(
      {required Map<String, dynamic> credentials,
      required String endpoint,
      required String method,
      required BuildContext context}) async {
    _call(endpoint: endpoint, method: method, body: credentials);
    bool dialogClosed = false;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final provider = Provider.of<AuthProvider>(context);
          if (provider.error) {
            return AlertDialog(
              title: const Text("Oops! 😢"),
              content: const Text("An error occurred. Please try again later."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"))
              ],
            );
          } else if (provider.validationError || provider.success) {
            dev.log("Validation Error: $validationError");
            if (!dialogClosed) {
              dialogClosed = true;
              WidgetsBinding.instance
                  .addPostFrameCallback((timeStamp) => Navigator.pop(context));
            }
          }
          return AlertDialog(
              content: FutureBuilder<Object>(
                  future: null,
                  builder: (context, snapshot) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 25),
                        Text("Please wait..."),
                      ],
                    );
                  }));
        });
    if (success) {
      final token = result["token"];
      if (token != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await setValue("jwt", token);
          login();
        });
        return "SUCCESS";
      }
      return "SUCCESS";
    }
    return null;
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    final googleSignIn = GoogleSignIn();
    googleSignIn.signIn().then((googleUser) {
      if (googleUser == null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Error"),
                  content:
                      const Text("An error occurred. Please try again later."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK"))
                  ],
                )).then((value) => null);
      } else {
        googleUser.authentication.then((googleAuth) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((userCredential) {
            dev.log("User: $userCredential");
            final isNewUser = userCredential.additionalUserInfo?.isNewUser;
            final email = userCredential.user?.email;
            final username = userCredential.user?.displayName;
            final genPassword = email.toString().split("").reversed.join();
            final uid = userCredential.user?.uid;
            final body = isNewUser == true
                ? {
                    "email": email,
                    "username": username,
                    "password": genPassword,
                    "confirm_password": genPassword,
                    "isGoogle": "true",
                    'googleUid': uid,
                  }
                : {
                    "input": email,
                    "password": genPassword,
                    "isGoogle": "true",
                    'googleUid': uid
                  };
            final endPoint = isNewUser == true ? registerUrl : loginUrl;
            submitCredentials(
                    credentials: body,
                    endpoint: endPoint,
                    method: "POST",
                    context: context)
                .then((response) {
              if (response == "SUCCESS") {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/home", (route) => false,
                    arguments: {"host": "firebase"});
              } else {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "An error occurred. Please try again later."),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"))
                          ],
                        )).then((value) => null);
              }
            });
          });
        });
      }
    });
  }
}
