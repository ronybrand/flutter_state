import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state/data/info_repository.dart';
import 'package:flutter_state/providers.dart';
import 'package:flutter_state/widgets/app_footer.dart';
import 'package:flutter_state/widgets/loading_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpFooter(
  WidgetTester tester, {
  required Future<BackendInfo> Function() backend,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        appVersionProvider.overrideWith((ref) async => '1.2.3'),
        backendInfoProvider.overrideWith((ref) => backend()),
      ],
      child: const MaterialApp(home: Scaffold(body: AppFooter())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('always shows the app version, even if the backend is down', (
    tester,
  ) async {
    await pumpFooter(tester, backend: () async => throw Exception('down'));
    expect(find.textContaining('app 1.2.3'), findsOneWidget);
    expect(find.textContaining('back '), findsNothing);
  });

  testWidgets('adds the backend build once it answers', (tester) async {
    await pumpFooter(
      tester,
      backend: () async =>
          BackendInfo(commit: 'def5678', time: DateTime(2026, 1, 2, 3, 4, 5)),
    );
    expect(find.textContaining('app 1.2.3'), findsOneWidget);
    expect(
      find.textContaining('back def5678 · 01/02/2026, 03:04:05 AM'),
      findsOneWidget,
    );
  });

  testWidgets('LoadingIndicator is a labelled progress indicator', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingIndicator())),
    );
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    handle.dispose();
  });
}
