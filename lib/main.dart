import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'map_page.dart';
import 'calendar_page.dart';
import 'form_page.dart';
import 'impact_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeNavBar(),
    );
  }
}

class HomeNavBar extends StatefulWidget {
  const HomeNavBar({super.key});

  @override
  State<HomeNavBar> createState() => _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {
  int _selectedIndex = 0;

  DateTime? _targetCalendarDate;
  String? _targetAutoExpandId;

  void jumpToCalendarEvent(DateTime eventDate, String eventId) {
    setState(() {
      _targetCalendarDate = eventDate;
      _targetAutoExpandId = eventId;
      _selectedIndex = 0;
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.blueGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSelected ? 14 : 12,
              color: isSelected ? Colors.blueAccent : Colors.blueGrey,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CalendarPage(
        initialSelectedDay: _targetCalendarDate,
        autoExpandEventId: _targetAutoExpandId,
      ),
      GeoPointMapScreen(
        onEventSelected: (date, id) => jumpToCalendarEvent(date, id),
      ),
      FormPage(formUrl: 'https://blessedintech.github.io/food-pantry-intake/'),
      ImpactForm(formUrl: AppLocalizations.of(context)!.impactForm),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Clear target parameters if user manually clicks bottom nav tabs
            if (index != 1) {
              _targetCalendarDate = null;
              _targetAutoExpandId = null;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(
              icon: Icons.calendar_month_outlined,
              label: AppLocalizations.of(context)!.calendarMenu,
              isSelected: _selectedIndex == 0,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              icon: Icons.map,
              label: AppLocalizations.of(context)!.findFoodMenu,
              isSelected: _selectedIndex == 1,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              icon: Icons.edit_note,
              label: AppLocalizations.of(context)!.foodFormMenu,
              isSelected: _selectedIndex == 2,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              icon: Icons.telegram_outlined,
              label: AppLocalizations.of(context)!.impactFormMenu,
              isSelected: _selectedIndex == 3,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
