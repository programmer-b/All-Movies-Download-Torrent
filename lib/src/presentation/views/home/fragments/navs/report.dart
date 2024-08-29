import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../state/report.dart';
import '../../../auth/auth_state.dart';
import '../../components/error_page.dart';
import '../../components/loading_page.dart';
import '../../components/not_logged_in.dart';

class ReportNav extends StatefulWidget {
  const ReportNav(
      {super.key, this.contentTitle, this.contentId, this.contentType});

  final String? contentTitle;
  final String? contentId;
  final String? contentType;

  @override
  State<ReportNav> createState() => _ReportNavState();
}

class _ReportNavState extends State<ReportNav> {
  final _formKey = GlobalKey<FormState>();

  final _contentTitleController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<ReportProvider>(context, listen: false).report(
        contentId: widget.contentId ?? '',
        contentType: widget.contentType ?? '',
        contentTitle: _contentTitleController.text,
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
      final sub = JwtDecoder.decode(getStringAsync("jwt"))!["sub"];
      final String username = sub["username"];
      final String email = sub["email"];

      _nameController.text = username;
      _emailController.text = email;
    }
    if (widget.contentTitle != null) {
      _contentTitleController.text = widget.contentTitle!;
    }
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Provider.of<ReportProvider>(context, listen: false).init());
  }

  @override
  Widget build(BuildContext context) {
    final report = Provider.of<ReportProvider>(context);
    final watcher = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMCA Report'),
      ),
      body: !watcher.isAuthenticated
          ? const NotLoggedIn()
          : report.loading
              ? const LoadingPage()
              : report.error
                  ? const ErrorPage()
                  : report.success
                      ? const _BuildReportSentSuccess()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildTextFormField('Content Title'),
                                const SizedBox(height: 16),
                                _buildTextFormField('Your Name'),
                                const SizedBox(height: 16),
                                _buildTextFormField('Your Email'),
                                const SizedBox(height: 16),
                                _buildTextFormField('Message', maxLines: 5),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: submit,
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                        ),
    );
  }

  Widget _buildTextFormField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          controller: label == 'Content Title'
              ? _contentTitleController
              : label == 'Your Name'
                  ? _nameController
                  : label == 'Your Email'
                      ? _emailController
                      : _messageController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'This field is required';
            }

            if (label == 'Your Email' && !value.isEmail) {
              return 'Invalid email';
            }

            if (label == 'Content Title' && value.length < 3) {
              return 'Content title must be at least 3 characters';
            }

            if (label == 'Your Name' && value.length < 3) {
              return 'Name must be at least 3 characters';
            }

            if (label == 'Message' && value.length < 10) {
              return 'Message must be at least 10 characters';
            }

            return null;
          },
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _BuildReportSentSuccess extends StatelessWidget {
  const _BuildReportSentSuccess();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 16),
          const Text(
            'Report sent successfully',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'We respect the rights of copyright holders. Our team will review your report and get back to you at the email address you provided within 2 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

extension on String {
  bool get isEmail {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
}
