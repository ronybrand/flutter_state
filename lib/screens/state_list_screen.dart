import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../core/api_error_message.dart';
import '../core/request_id.dart';
import '../data/federative_unit.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/states_providers.dart';
import '../theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/error_banner.dart';
import '../widgets/error_message_controller.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/language_selector.dart';
import '../widgets/sort_bar.dart';
import '../widgets/state_list_item.dart';

const _debounce = Duration(milliseconds: 300);

class StateListScreen extends ConsumerStatefulWidget {
  const StateListScreen({super.key});

  @override
  ConsumerState<StateListScreen> createState() => _StateListScreenState();
}

class _StateListScreenState extends ConsumerState<StateListScreen> {
  final _errors = ErrorMessageController();
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _errors.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _errors.dispose();
    super.dispose();
  }

  // Hand-rolled debounce: one search box does not justify a package.
  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      _debounce,
      () => ref.read(searchProvider.notifier).set(text),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(statesProvider);
    try {
      await ref.read(statesProvider.future);
    } on Object {
      // The error banner already reports it.
    }
  }

  // A dialog instead of deleting on tap: the destructive choice is explicit.
  Future<void> _confirmDelete(FederativeUnit unit) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteStateTitle),
        content: Text(strings.confirmDeleteState(unit.abbreviation)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await ref.read(stateActionsProvider).delete(unit.id);
    } on Object catch (error) {
      _errors.show(
        apiErrorMessage(
          error,
          strings.deleteStateError,
          unavailableMessage: strings.apiUnavailableMessage,
        ),
        extractRequestId(error),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    ref.listen(statesProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        _errors.show(
          apiErrorMessage(
            next.error!,
            strings.loadStatesError,
            unavailableMessage: strings.apiUnavailableMessage,
          ),
          extractRequestId(next.error!),
        );
      }
    });
    final states = ref.watch(statesProvider);
    final sort = ref.watch(sortProvider);
    final units = states.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: const [LanguageSelector()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                // header, then the rows (or a placeholder), then the footer
                itemCount:
                    (units == null || units.isEmpty ? 1 : units.length) + 2,
                itemBuilder: (context, index) {
                  if (index == 0) return _header(sort);
                  final last =
                      (units == null || units.isEmpty ? 1 : units.length) + 1;
                  if (index == last) return const AppFooter();
                  if (units == null) {
                    return states.hasError && !states.isLoading
                        ? _loadFailed()
                        : const LoadingIndicator();
                  }
                  if (units.isEmpty) return _empty();
                  final unit = units[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StateListItem(
                      unit: unit,
                      deleting: _deleting,
                      onEdit: (u) => context.push('/state/${u.id}/edit'),
                      onDelete: _confirmDelete,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(SortState sort) {
    final strings = AppLocalizations.of(context);
    final authenticated =
        ref.watch(authControllerProvider) == AuthStatus.authenticated;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorBanner(error: _errors.error, requestId: _errors.requestId),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              if (authenticated)
                OutlinedButton(
                  key: const Key('log-out'),
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  child: Text(strings.logOut),
                )
              else
                OutlinedButton(
                  key: const Key('log-in'),
                  onPressed: () => context.push('/login'),
                  child: Text(strings.logIn),
                ),
              FilledButton.icon(
                key: const Key('new-state'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                onPressed: () => context.push('/state/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(strings.newState),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('search'),
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: strings.searchLabel,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          SortBar(
            sort: sort,
            onSort: (field) => ref.read(sortProvider.notifier).toggle(field),
          ),
        ],
      ),
    );
  }

  // The banner says what went wrong; this is the way out. Without it a failed
  // first load would leave nothing on screen but a spinner or a lie ("empty").
  Widget _loadFailed() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: OutlinedButton.icon(
          key: const Key('retry'),
          onPressed: _refresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(AppLocalizations.of(context).tryAgain),
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).noStates,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => context.push('/state/new'),
            child: Text(AppLocalizations.of(context).createFirstState),
          ),
        ],
      ),
    );
  }
}
