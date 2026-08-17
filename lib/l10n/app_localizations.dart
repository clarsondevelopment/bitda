import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
  ];

  /// No description provided for @calendarTopMessage.
  ///
  /// In en, this message translates to:
  /// **'Distribution Calendar'**
  String get calendarTopMessage;

  /// No description provided for @mapTopMessage.
  ///
  /// In en, this message translates to:
  /// **'BIT Food Distribution Sites'**
  String get mapTopMessage;

  /// No description provided for @intakeTopMessage.
  ///
  /// In en, this message translates to:
  /// **'Intake Form'**
  String get intakeTopMessage;

  /// No description provided for @impactTopMessage.
  ///
  /// In en, this message translates to:
  /// **'Impact Form'**
  String get impactTopMessage;

  /// No description provided for @calendarMenu.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarMenu;

  /// No description provided for @findFoodMenu.
  ///
  /// In en, this message translates to:
  /// **'Find Food'**
  String get findFoodMenu;

  /// No description provided for @foodFormMenu.
  ///
  /// In en, this message translates to:
  /// **'Food Form'**
  String get foodFormMenu;

  /// No description provided for @impactFormMenu.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impactFormMenu;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @eventsFor.
  ///
  /// In en, this message translates to:
  /// **'Events for'**
  String get eventsFor;

  /// No description provided for @noDrives.
  ///
  /// In en, this message translates to:
  /// **'No drives for this day.'**
  String get noDrives;

  /// No description provided for @tapDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to for more details'**
  String get tapDetails;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @openMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openMaps;

  /// No description provided for @errorMapPoints.
  ///
  /// In en, this message translates to:
  /// **'Error loading map points'**
  String get errorMapPoints;

  /// No description provided for @clickOpenNewTab.
  ///
  /// In en, this message translates to:
  /// **'Click below to open the form in a new browser tab.'**
  String get clickOpenNewTab;

  /// No description provided for @openFormNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open Form in New Tab'**
  String get openFormNewTab;

  /// No description provided for @impactForm.
  ///
  /// In en, this message translates to:
  /// **'https://forms.gle/bmcn7W6R7MPQQNzF9'**
  String get impactForm;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
