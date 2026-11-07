import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'calendar_page.dart';
import 'firebase_options.dart';
import 'form_page.dart';
import 'impact_page.dart';
import 'l10n/app_localizations.dart';
import 'map_page.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Handling background message: ${message.messageId}',
  );
}

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(const MainApp());

  _initializeNotifications();
}

Future<void> _initializeNotifications() async {
  try {
    final NotificationService notificationService =
    NotificationService();

    await notificationService.initNotifications();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // On iOS the FCM token needs an APNs token first. The simulator
      // never gets one, and a real device only with the Push
      // Notifications capability and an APNs key in Firebase.
      final String? apnsToken =
          await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        debugPrint(
          'No APNs token (simulator, or push capability missing): '
          'skipping topic subscription',
        );
        return;
      }
    }

    await FirebaseMessaging.instance.subscribeToTopic(
      'pantry_updates',
    );

    debugPrint('Subscribed to pantry_updates');

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM TOKEN: $token');

    debugPrint(
      'Subscribed to pantry_updates',
    );


    debugPrint(
      'FCM TOKEN: $token',
    );

    debugPrint(
      'Notification initialization complete',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Notification setup failed: $e',
    );
    debugPrint(
      '$stackTrace',
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates:
      AppLocalizations.localizationsDelegates,
      supportedLocales:
      AppLocalizations.supportedLocales,
      home: const HomeNavBar(),
    );
  }
}

class HomeNavBar extends StatefulWidget {
  const HomeNavBar({super.key});

  @override
  State<HomeNavBar> createState() =>
      _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {
  int _selectedIndex = 0;

  final GlobalKey<CalendarPageState>
  _calendarKey =
  GlobalKey<CalendarPageState>();

  // Pages are created only when first opened.
  //
  // 0 = Calendar
  // 1 = Map
  // 2 = Food Form
  // 3 = Impact Form
  final List<Widget?> _pages =
  List<Widget?>.filled(4, null);

  void _ensurePage(
      int index,
      BuildContext context,
      ) {
    if (_pages[index] != null) {
      return;
    }

    final localizations =
    AppLocalizations.of(context)!;

    switch (index) {
      case 0:
        _pages[0] = CalendarPage(
          key: _calendarKey,
        );
        break;

      case 1:
        _pages[1] = GeoPointMapScreen(
          onEventSelected: (
              DateTime date,
              String id,
              ) {
            jumpToCalendarEvent(
              date,
              id,
            );
          },
        );
        break;

      case 2:
        _pages[2] = FormPage(
          formUrl:
          'https://blessedintech.github.io/food-pantry-intake/',
        );
        break;

      case 3:
        _pages[3] = ImpactForm(
          formUrl:
          localizations.impactForm,
        );
        break;
    }
  }

  void jumpToCalendarEvent(
      DateTime eventDate,
      String eventId,
      ) {
    _ensurePage(
      0,
      context,
    );

    setState(() {
      _selectedIndex = 0;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _calendarKey.currentState
          ?.jumpToEvent(
        eventDate,
        eventId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _ensurePage(
      0,
      context,
    );

    _ensurePage(
      _selectedIndex,
      context,
    );

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _pages.length,
              (index) {
            return _pages[index] ??
                const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex:
        _selectedIndex,
        onTap: (index) {
          _ensurePage(
            index,
            context,
          );

          setState(() {
            _selectedIndex = index;
          });
        },
        type:
        BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment,
            ),
            label: 'Form',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feedback,
            ),
            label: 'Impact',
          ),
        ],
      ),
    );
  }
}