import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api_error_message.dart';
import '../core/request_id.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/error_banner.dart';
import '../widgets/error_message_controller.dart';
import '../widgets/language_selector.dart';

const _maxQuestionLength = 1000;
const _aiAgentRepositoryUrl = 'https://github.com/ronybrand/estado-ai-agent';

class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  final _questionController = TextEditingController();
  final _errors = ErrorMessageController();
  String? _answer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _errors.addListener(_onErrorChanged);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _errors.dispose();
    super.dispose();
  }

  void _onErrorChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isSubmitting) return;

    final strings = AppLocalizations.of(context);
    _errors.clear();
    setState(() {
      _answer = null;
      _isSubmitting = true;
    });

    try {
      final response = await ref
          .read(askRepositoryProvider)
          .ask(
            question: question,
            language: Localizations.localeOf(context).languageCode,
          );
      if (mounted) setState(() => _answer = response.answer);
    } on Object catch (error) {
      if (mounted) {
        _errors.show(
          apiErrorMessage(
            error,
            strings.askAiError,
            unavailableMessage: strings.apiUnavailableMessage,
          ),
          extractRequestId(error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openSource() async {
    final opened = await launchUrl(
      Uri.parse(_aiAgentRepositoryUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _errors.show(AppLocalizations.of(context).askAiSourceError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.askAiTitle),
        actions: const [LanguageSelector()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ErrorBanner(
                    error: _errors.error,
                    requestId: _errors.requestId,
                  ),
                  Text(strings.askAiHowItWorks),
                  const SizedBox(height: 8),
                  Text(
                    strings.askAiLanguageLimitNote,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('ask-ai-question'),
                    controller: _questionController,
                    maxLength: _maxQuestionLength,
                    maxLines: 3,
                    enabled: !_isSubmitting,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: strings.askAiQuestionLabel,
                      hintText: strings.askAiPlaceholder,
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      key: const Key('ask-ai-submit'),
                      onPressed:
                          _isSubmitting ||
                              _questionController.text.trim().isEmpty
                          ? null
                          : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        _isSubmitting
                            ? strings.askAiPendingButton
                            : strings.askAiButton,
                      ),
                    ),
                  ),
                  if (_answer case final answer?) ...[
                    const SizedBox(height: 20),
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        key: const Key('ask-ai-answer'),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MarkdownBody(
                          data: answer,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _openSource,
                      child: Text(strings.askAiSourceLink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
