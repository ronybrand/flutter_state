import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/request_id.dart';
import '../data/federative_unit.dart';
import '../state/states_providers.dart';
import '../widgets/error_message_controller.dart';
import '../widgets/form_page.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/state_form.dart';
import 'navigation.dart';

class EditStateScreen extends ConsumerStatefulWidget {
  const EditStateScreen({required this.rawId, super.key});

  /// The `:id` path segment as the user (or a deep link) wrote it.
  final String? rawId;

  @override
  ConsumerState<EditStateScreen> createState() => _EditStateScreenState();
}

class _EditStateScreenState extends ConsumerState<EditStateScreen> {
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

  // A path segment is user-controllable (deep links): validate before it
  // reaches the API.
  int? get _id {
    final id = int.tryParse(widget.rawId ?? '');
    return id != null && id > 0 ? id : null;
  }

  Future<void> _submit(FederativeUnit unit, NewFederativeUnit values) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(stateActionsProvider)
          .update(
            unit.copyWith(name: values.name, abbreviation: values.abbreviation),
          );
      if (mounted) closeScreen(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        _errors.show('Failed to update state.', extractRequestId(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = _id;
    if (id == null) {
      return const FormPage(
        title: 'Edit state',
        error: 'Invalid state.',
        requestId: null,
        child: SizedBox.shrink(),
      );
    }

    final loaded = ref.watch(federativeUnitProvider(id));
    final existing = ref
        .watch(statesProvider)
        .value
        ?.map((u) => u.abbreviation)
        .toList();
    final loadError = loaded.hasError && !loaded.isLoading
        ? 'Failed to fetch state.'
        : null;

    return FormPage(
      title: 'Edit state',
      error: _errors.error ?? loadError,
      requestId: _errors.error != null
          ? _errors.requestId
          : (loaded.hasError ? extractRequestId(loaded.error!) : null),
      child: loaded.when(
        loading: () => const LoadingIndicator(),
        error: (_, _) => const SizedBox.shrink(),
        data: (unit) => StateForm(
          key: ValueKey(unit.id),
          initialValues: NewFederativeUnit(
            abbreviation: unit.abbreviation,
            name: unit.name,
          ),
          disabled: _saving,
          existingAbbreviations: existing ?? const [],
          onSubmit: (values) => _submit(unit, values),
        ),
      ),
    );
  }
}
