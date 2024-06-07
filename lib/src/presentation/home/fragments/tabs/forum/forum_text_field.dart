import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../authentication/auth_state.dart';
import 'ask_to_login.dart';

class ForumTextField extends StatefulWidget {
  const ForumTextField(
      {super.key,
      required this.call,
      required this.hintText,
      required this.showKeyBoardImmediately});

  final void Function(String text) call;
  final String hintText;
  final bool showKeyBoardImmediately;

  @override
  State<ForumTextField> createState() => _ForumTextFieldState();
}

class _ForumTextFieldState extends State<ForumTextField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    if (widget.showKeyBoardImmediately) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onTap: () {
                if (!isLoggedIn) {
                  //hide the keyboard
                  _focusNode.unfocus();
                  showDialog(
                    context: context,
                    builder: (context) => const AskToLogin(),
                  );
                }
              },
              focusNode: _focusNode,
              controller: _textEditingController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_textEditingController.text.isNotEmpty) {
              //determine if any words inside the whole text has vulgars
              final words = _textEditingController.text.split(" ");
              for (var word in words) {
                if (vulgars.contains(word.toLowerCase())) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Vulgar words detected'),
                          content: const Text(
                              'Please be polite and respectful to others'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Ok'),
                            )
                          ],
                        );
                      });
                  return;
                }
              }
              widget.call(_textEditingController.text);
              _textEditingController.clear();
              //hide the keyboard
              _focusNode.unfocus();
            } else {
              toast("Please type something", length: Toast.LENGTH_LONG);
            }
          },
        )
      ],
    );
  }
}

const vulgars = [
  "fuck",
  "shit",
  "bitch",
  "asshole",
  "damn",
  "hell",
  "cock",
  "pussy",
  "dick",
  "tits",
  "sex",
  "nigger",
  "chink",
  "spic",
  "wop",
  "retard",
  "fag",
  "tranny",
  "whore",
  "moron",
  "idiot",
  "foolish",
  "cunt",
  "bastard",
  "ass",
  "go fuck yourself",
  "kiss my ass",
  "eat shit",
  "slut",
  "fuckwit",
  "motherfucker",
  "twat",
  "piss",
  "suck",
  "jerk",
  "wanker",
  "arsehole",
  "bollocks",
  "douchebag",
  "wank",
  "bugger",
  "crap",
  "piss off",
  "asswipe",
  "son of a bitch",
  "cockhead",
  "dickhead",
  "fanny",
  "balls",
  "bullshit",
  "jackass",
  "dipshit",
  "tosser",
  "stupid",
  "stupit"
];
