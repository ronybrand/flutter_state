import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api_error_message.dart';
import '../theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.error,
    required this.requestId,
    this.openLink,
    super.key,
  });

  final String? error;
  final String? requestId;

  /// How the turn-on link is opened; defaults to the external browser. A
  /// parameter so tests don't need the url_launcher platform channel.
  final Future<void> Function(Uri uri)? openLink;

  Future<void> _open(Uri uri) => (openLink ?? _openInBrowser)(uri);

  static Future<void> _openInBrowser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

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
            if (message == apiUnavailableMessage)
              TextButton(
                key: const Key('turn-on-api'),
                onPressed: () => _open(Uri.parse(startApiUrl)),
                child: const Text(
                  'Turn on the API',
                  style: TextStyle(
                    color: AppColors.danger,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
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
