// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get calendarTopMessage => 'Calendario de distribución';

  @override
  String get mapTopMessage => 'Sitios de distribución de alimentos BIT';

  @override
  String get intakeTopMessage => 'Formulario de admisión';

  @override
  String get impactTopMessage => 'Formulario de impacto';

  @override
  String get calendarMenu => 'Calendario';

  @override
  String get findFoodMenu => 'Buscar alimentos';

  @override
  String get foodFormMenu => 'Formulario de alimentos';

  @override
  String get impactFormMenu => 'Impacto';

  @override
  String get selectDate => 'Seleccione una fecha';

  @override
  String get eventsFor => 'Eventos para';

  @override
  String get noDrives => 'No hay jornadas para este día.';

  @override
  String get tapDetails => 'Toca para ver más detalles';

  @override
  String get event => 'Evento';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get openMaps => 'Abrir en Mapas';

  @override
  String get errorMapPoints => 'Error al cargar los puntos del mapa';

  @override
  String get clickOpenNewTab =>
      'Haga clic abajo para abrir el formulario en una nueva pestaña del navegador.';

  @override
  String get openFormNewTab => 'Abrir formulario en una pestaña nueva';

  @override
  String get impactForm => 'https://forms.gle/9JnWGES1JFfuSiCK9';
}
