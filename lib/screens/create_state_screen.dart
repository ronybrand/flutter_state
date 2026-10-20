import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_error_message.dart';
import '../core/request_id.dart';
import '../data/federative_unit.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/states_providers.dart';
import '../widgets/error_message_controller.dart';
import '../widgets/form_page.dart';
import '../widgets/state_form.dart';
import 'navigation.dart';

class CreateStateScreen extends ConsumerStatefulWidget {
  const CreateStateScreen({super.key});

  @override
  ConsumerState<CreateStateScreen> createState() => _CreateStateScreenState();
}

class _CreateStateScreenState extends ConsumerState<CreateStateScreen> {
  final _errors = ErrorMessageController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _errors.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _errors.dispose();
    super.dispose();
  }

  Future<void> _submit(NewFederativeUnit unit) async {
    setState(() => _saving = true);
    try {
      await ref.read(stateActionsProvider).create(unit);
      if (mounted) closeScreen(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        final strings = AppLocalizations.of(context);
        _errors.show(
          apiErrorMessage(
            error,
            strings.createStateError,
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
    final existing = ref
        .watch(statesProvider)
        .value
        ?.map((u) => u.abbreviation)
        .toList();
    return FormPage(
      title: strings.newStateTitle,
      error: _errors.error,
      requestId: _errors.requestId,
      child: StateForm(
        disabled: _saving,
        existingAbbreviations: existing ?? const [],
        onSubmit: _submit,
      ),
    );
  }
}
