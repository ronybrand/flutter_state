import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languagePreferenceKey = 'app_language';
const supportedAppLocales = [Locale('pt'), Locale('en')];

abstract interface class LocalePreferenceStore {
  String? readLanguage();
  Future<void> writeLanguage(String language);
}

class SharedPreferencesLocaleStore implements LocalePreferenceStore {
  const SharedPreferencesLocaleStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? readLanguage() => _preferences.getString(_languagePreferenceKey);

  @override
  Future<void> writeLanguage(String language) async {
    final saved = await _preferences.setString(
      _languagePreferenceKey,
      language,
    );
    if (!saved) {
      throw StateError('Could not save the language preference.');
    }
  }
}

final localePreferenceStoreProvider = Provider<LocalePreferenceStore>(
  (ref) => throw UnimplementedError(
    'localePreferenceStoreProvider must be overridden',
  ),
);

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final language = ref.watch(localePreferenceStoreProvider).readLanguage();
    return switch (language) {
      'pt' => const Locale('pt'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedAppLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported app locale.');
    }

    final previousLocale = state;
    state = locale;
    try {
      await ref
          .read(localePreferenceStoreProvider)
          .writeLanguage(locale.languageCode);
    } on Object {
      state = previousLocale;
      rethrow;
    }
  }
}
