import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../core/api_error_message.dart';
import '../core/request_id.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../widgets/error_message_controller.dart';
import '../widgets/form_page.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _errors = ErrorMessageController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  // `_submitting` only takes effect on the next frame, so a second tap landing
  // before it would still see false: this flag is set synchronously.
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    _errors.addListener(() => setState(() {}));
    for (final controller in [_username, _password]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _errors.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _username.text.isNotEmpty && _password.text.isNotEmpty && !_submitting;

  Future<void> _submit() async {
    if (_inFlight || !_canSubmit) return;
    _inFlight = true;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(username: _username.text, password: _password.text);
      if (mounted) context.go('/');
    } on Object catch (error) {
      _inFlight = false;
      if (mounted) {
        setState(() => _submitting = false);
        final strings = AppLocalizations.of(context);
        _errors.show(
          apiErrorMessage(
            error,
            strings.invalidCredentialsError,
            unavailableMessage: strings.apiUnavailableMessage,
          ),
          extractRequestId(error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return FormPage(
      title: strings.loginTitle,
      error: _errors.error,
      requestId: _errors.requestId,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('username'),
              controller: _username,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(labelText: strings.username),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password'),
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: strings.password),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: const Key('submit-login'),
                onPressed: _canSubmit ? _submit : null,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(strings.logInButton),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.demoCredentials,
              key: Key('demo-credentials'),
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
