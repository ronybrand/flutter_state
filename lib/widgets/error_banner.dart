import 'package:flutter/material.dart';

import '../theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({required this.error, required this.requestId, super.key});

  final String? error;
  final String? requestId;

  @override
  Widget build(BuildContext context) {
    final message = error;
    if (message == null) return const SizedBox.shrink();

    // A live region makes TalkBack and VoiceOver announce the text as soon as it
    // appears, without the user having to find it.
    return Semantics(
      key: const Key('error-banner'),
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          border: Border.all(color: AppColors.danger),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: AppColors.danger)),
            if (requestId != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Reference ID: $requestId',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
