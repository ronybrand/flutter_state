import 'package:flutter/material.dart';

import 'error_banner.dart';
import 'language_selector.dart';

/// Shell shared by the create, edit and login screens.
class FormPage extends StatelessWidget {
  const FormPage({
    required this.title,
    required this.error,
    required this.requestId,
    required this.child,
    super.key,
  });

  final String title;
  final String? error;
  final String? requestId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only the back arrow: the heading below already carries the title, and
      // repeating it in the bar would show it twice.
      appBar: AppBar(actions: [const LanguageSelector()]),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ErrorBanner(error: error, requestId: requestId),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
