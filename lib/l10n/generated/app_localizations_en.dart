// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Brazilian States';

  @override
  String get languageSwitchLabel => 'Change language';

  @override
  String get languageSaveError => 'Could not save the language preference.';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get logOut => 'Log out';

  @override
  String get logIn => 'Log in';

  @override
  String get newState => 'New state';

  @override
  String get searchLabel => 'Search by name or abbreviation';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortAscending => 'ascending';

  @override
  String get sortDescending => 'descending';

  @override
  String get sortAbbreviation => 'Abbreviation';

  @override
  String get sortName => 'Name';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noStates => 'No states registered.';

  @override
  String get createFirstState => 'Create the first state';

  @override
  String get deleteStateTitle => 'Delete state';

  @override
  String confirmDeleteState(String abbreviation) {
    return 'Are you sure you want to delete $abbreviation?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String deleteState(String abbreviation) {
    return 'Delete $abbreviation';
  }

  @override
  String editState(String abbreviation) {
    return 'Edit $abbreviation';
  }

  @override
  String created(String date) {
    return 'Created: $date';
  }

  @override
  String updated(String date) {
    return 'Updated: $date';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get logInButton => 'Log in';

  @override
  String get demoCredentials =>
      'Demo credentials (intentionally public): admin / Estado-Demo-2026';

  @override
  String get newStateTitle => 'New state';

  @override
  String get editStateTitle => 'Edit state';

  @override
  String get abbreviation => 'Abbreviation';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Enter the state name...';

  @override
  String get save => 'Save';

  @override
  String get invalidState => 'Invalid state.';

  @override
  String get abbreviationLengthError =>
      'Enter the state abbreviation with 2 letters.';

  @override
  String get abbreviationFormatError =>
      'Enter the state abbreviation with 2 uppercase letters.';

  @override
  String get duplicateAbbreviationError =>
      'A state with this abbreviation already exists.';

  @override
  String get nameMinLengthError =>
      'Enter the state name with at least 3 characters.';

  @override
  String get nameMaxLengthError =>
      'Enter the state name with at most 100 characters.';

  @override
  String get invalidCredentialsError => 'Invalid username or password.';

  @override
  String get loadStatesError => 'Failed to fetch states.';

  @override
  String get loadStateError => 'Failed to fetch state.';

  @override
  String get createStateError => 'Failed to create state.';

  @override
  String get updateStateError => 'Failed to update state.';

  @override
  String get deleteStateError => 'Failed to delete state.';

  @override
  String get apiUnavailableMessage =>
      'The API is offline (paused to save cost). Turn it on with the link below; it takes about 1 minute.';

  @override
  String get turnOnApi => 'Turn on the API';

  @override
  String referenceId(String id) {
    return 'Reference ID: $id';
  }

  @override
  String get loading => 'Loading';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get pageNotFoundDescription =>
      'The screen you are looking for does not exist.';

  @override
  String get backToHome => 'Back to home';

  @override
  String appVersion(String version) {
    return 'app $version';
  }

  @override
  String backendVersion(String commit, String date) {
    return 'back $commit · $date';
  }
}
