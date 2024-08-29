import 'package:flutter/material.dart';
import '../../../../../utils/strings.dart';

class FaqFragment extends StatelessWidget {
  const FaqFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(faqTitle), // Use the variable
      ),
      body: ListView(
        children: <Widget>[
          _FaqItem(
            question: question1, // Use the variable
            answer: answer1, // Use the variable
          ),
          _FaqItem(
            question: question2, // Use the variable
            answer: answer2, // Use the variable
          ),
          _FaqItem(
            question: question3, // Use the variable
            answer: answer3, // Use the variable
          ),
          _FaqItem(
            question: question4, // Use the variable
            answer: answer4, // Use the variable
          ),
          _FaqItem(
            question: question5, // Use the variable
            answer: answer5, // Use the variable
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
