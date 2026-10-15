import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A single widget on its own, with a Material shell around it.
Future<void> pumpWidgetUnderTest(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}
