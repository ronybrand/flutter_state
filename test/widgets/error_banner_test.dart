import 'package:flutter/semantics.dart';
import 'package:flutter_state/core/api_error_message.dart';
import 'package:flutter_state/widgets/error_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  testWidgets('renders nothing without an error', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const ErrorBanner(error: null, requestId: null),
    );
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('Reference ID'), findsNothing);
    expect(find.byKey(const Key('error-banner')), findsNothing);
  });

  testWidgets('shows the message', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const ErrorBanner(error: 'Failed', requestId: null),
    );
    expect(find.text('Failed'), findsOneWidget);
    expect(find.textContaining('Reference ID'), findsNothing);
  });

  testWidgets('shows the reference id when present', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const ErrorBanner(error: 'Failed', requestId: 'abc'),
    );
    expect(find.text('Reference ID: abc'), findsOneWidget);
  });

  testWidgets('is a live region, so screen readers announce it on appearing', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderTest(
      tester,
      const ErrorBanner(error: 'Failed', requestId: null),
    );
    final node = tester.getSemantics(find.byKey(const Key('error-banner')));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('offers the turn-on link only when the API is unavailable', (
    tester,
  ) async {
    final opened = <Uri>[];
    await pumpWidgetUnderTest(
      tester,
      ErrorBanner(
        error: apiUnavailableMessage,
        requestId: null,
        openLink: (uri) async => opened.add(uri),
      ),
    );

    await tester.tap(find.byKey(const Key('turn-on-api')));

    expect(opened, [Uri.parse(startApiUrl)]);
  });

  testWidgets('shows no link for an ordinary error', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const ErrorBanner(error: 'Failed', requestId: null),
    );
    expect(find.byKey(const Key('turn-on-api')), findsNothing);
  });
}
