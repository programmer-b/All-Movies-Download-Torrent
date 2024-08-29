import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/urls.dart';
import '../../../../state/contact.dart';
import '../../../auth/auth_state.dart';
import '../../components/error_page.dart';
import '../../components/loading_page.dart';
import '../../components/not_logged_in.dart';

class ContactFragment extends StatefulWidget {
  const ContactFragment({super.key});

  @override
  State<ContactFragment> createState() => _ContactFragmentState();
}

class _ContactFragmentState extends State<ContactFragment> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: !authProvider.isAuthenticated
          ? const NotLoggedIn()
          : const _BuildContact(),
    );
  }
}

class _BuildContact extends StatefulWidget {
  const _BuildContact();

  @override
  State<_BuildContact> createState() => _BuildContactState();
}

class _BuildContactState extends State<_BuildContact> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<ContactProvider>().init());

    final sub = JwtDecoder.decode(getStringAsync("jwt"))!["sub"];
    final String username = sub["username"];
    final String email = sub["email"];

    _nameController.text = username;
    _emailController.text = email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final message = _messageController.text;

      context.read<ContactProvider>().submit(contactUrl, name, email, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();

    return contactProvider.loading
        ? const LoadingPage()
        : contactProvider.error
            ? ErrorPage(retry: () => context.read<ContactProvider>().init())
            : contactProvider.success
                ? const _ContactSuccessfullySubmitted()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _TextForm(
                            title: 'Name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _TextForm(
                            title: 'Email',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _TextForm(
                            title: 'Message',
                            controller: _messageController,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your message';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  );
  }
}

class _TextForm extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;

  const _TextForm({
    required this.title,
    required this.controller,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _ContactSuccessfullySubmitted extends StatelessWidget {
  const _ContactSuccessfullySubmitted();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 50, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Contact Submitted Successfully',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for reaching out to us. We have received your message and will get back to you as soon as we can.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            //close button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
