// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get calendarTopMessage => 'Distribution Calendar';

  @override
  String get mapTopMessage => 'BIT Food Distribution Sites';

  @override
  String get intakeTopMessage => 'Intake Form';

  @override
  String get impactTopMessage => 'Impact Form';

  @override
  String get calendarMenu => 'Calendar';

  @override
  String get findFoodMenu => 'Find Food';

  @override
  String get foodFormMenu => 'Food Form';

  @override
  String get impactFormMenu => 'Impact';

  @override
  String get selectDate => 'Select a date';

  @override
  String get eventsFor => 'Events for';

  @override
  String get noDrives => 'No drives for this day.';

  @override
  String get tapDetails => 'Tap to for more details';

  @override
  String get event => 'Event';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get openMaps => 'Open in Maps';

  @override
  String get errorMapPoints => 'Error loading map points';

  @override
  String get clickOpenNewTab =>
      'Click below to open the form in a new browser tab.';

  @override
  String get openFormNewTab => 'Open Form in New Tab';

  @override
  String get impactForm => 'https://forms.gle/bmcn7W6R7MPQQNzF9';
}
