import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A form screen closes by popping off the stack, so the user lands exactly where
/// they came from. Opened cold (a deep link, restored state) there is nothing to
/// pop and `pop()` would do nothing at all, so land on the list instead.
void closeScreen(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}
