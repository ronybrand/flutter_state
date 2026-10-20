import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Brazilian States'**
  String get appTitle;

  /// No description provided for @languageSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageSwitchLabel;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the language preference.'**
  String get languageSaveError;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @newState.
  ///
  /// In en, this message translates to:
  /// **'New state'**
  String get newState;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name or abbreviation'**
  String get searchLabel;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'descending'**
  String get sortDescending;

  /// No description provided for @sortAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get sortAbbreviation;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noStates.
  ///
  /// In en, this message translates to:
  /// **'No states registered.'**
  String get noStates;

  /// No description provided for @createFirstState.
  ///
  /// In en, this message translates to:
  /// **'Create the first state'**
  String get createFirstState;

  /// No description provided for @deleteStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete state'**
  String get deleteStateTitle;

  /// No description provided for @confirmDeleteState.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {abbreviation}?'**
  String confirmDeleteState(String abbreviation);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteState.
  ///
  /// In en, this message translates to:
  /// **'Delete {abbreviation}'**
  String deleteState(String abbreviation);

  /// No description provided for @editState.
  ///
  /// In en, this message translates to:
  /// **'Edit {abbreviation}'**
  String editState(String abbreviation);

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String created(String date);

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updated(String date);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInButton;

  /// No description provided for @demoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Demo credentials (intentionally public): admin / Estado-Demo-2026'**
  String get demoCredentials;

  /// No description provided for @newStateTitle.
  ///
  /// In en, this message translates to:
  /// **'New state'**
  String get newStateTitle;

  /// No description provided for @editStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit state'**
  String get editStateTitle;

  /// No description provided for @abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get abbreviation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the state name...'**
  String get nameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @invalidState.
  ///
  /// In en, this message translates to:
  /// **'Invalid state.'**
  String get invalidState;

  /// No description provided for @abbreviationLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter the state abbreviation with 2 letters.'**
  String get abbreviationLengthError;

  /// No description provided for @abbreviationFormatError.
  ///
  /// In en, this message translates to:
  /// **'Enter the state abbreviation with 2 uppercase letters.'**
  String get abbreviationFormatError;

  /// No description provided for @duplicateAbbreviationError.
  ///
  /// In en, this message translates to:
  /// **'A state with this abbreviation already exists.'**
  String get duplicateAbbreviationError;

  /// No description provided for @nameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter the state name with at least 3 characters.'**
  String get nameMinLengthError;

  /// No description provided for @nameMaxLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter the state name with at most 100 characters.'**
  String get nameMaxLengthError;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get invalidCredentialsError;

  /// No description provided for @loadStatesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch states.'**
  String get loadStatesError;

  /// No description provided for @loadStateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch state.'**
  String get loadStateError;

  /// No description provided for @createStateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create state.'**
  String get createStateError;

  /// No description provided for @updateStateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update state.'**
  String get updateStateError;

  /// No description provided for @deleteStateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete state.'**
  String get deleteStateError;

  /// No description provided for @apiUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The API is offline (paused to save cost). Turn it on with the link below; it takes about 1 minute.'**
  String get apiUnavailableMessage;

  /// No description provided for @turnOnApi.
  ///
  /// In en, this message translates to:
  /// **'Turn on the API'**
  String get turnOnApi;

  /// No description provided for @referenceId.
  ///
  /// In en, this message translates to:
  /// **'Reference ID: {id}'**
  String referenceId(String id);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'The screen you are looking for does not exist.'**
  String get pageNotFoundDescription;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'app {version}'**
  String appVersion(String version);

  /// No description provided for @backendVersion.
  ///
  /// In en, this message translates to:
  /// **'back {commit} · {date}'**
  String backendVersion(String commit, String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
