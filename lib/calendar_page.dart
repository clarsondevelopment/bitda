import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  final DateTime? initialSelectedDay;
  final String? autoExpandEventId;

  const CalendarPage({
    super.key,
    this.initialSelectedDay,
    this.autoExpandEventId,
  });

  @override
  State<CalendarPage> createState() =>
      _CalendarPageState();
}

class _CalendarPageState
    extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  // Controllers to manage expansion state per event
  final Map<String, ExpansibleController> _tileControllers = {};

  @override
  void initState() {
    super.initState();
    // Use the passed initial day if available, otherwise default to now
    _focusedDay = widget.initialSelectedDay ?? DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tileControllers.clear();
    super.dispose();
  }

  // Parses documents from Firestore into a Date-to-Map (storing full doc data)
  Map<DateTime, List<Map<String, dynamic>>> _processFirestoreDocs(
      QuerySnapshot snapshot) {
    final Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};

    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

      if (data['time'] != null && data['name'] != null) {
        Timestamp timestamp = data['time'];
        DateTime eventDate = timestamp.toDate();
        final normalizedDate =
        DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (eventsMap[normalizedDate] == null) {
          eventsMap[normalizedDate] = [];
        }

        // Save the document ID for tracking auto-expansion
        data['docId'] = doc.id;
        eventsMap[normalizedDate]!.add(data);
      }
    }
    return eventsMap;
  }

  Future<void> _openMap(String address) async {
    if (address.trim().isEmpty || address == "null") {
      debugPrint('Cannot open map: Address string is empty.');
      return;
    }

    // Constructing with explicit named parameters natively handles
    // encoding and prevents the query from being ignored or corrupted.
    final Uri mapWebUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {
        'api': '1',
        'query': address.trim(),
      },
    );

    try {
      // Launching as an external application prompts the system to intercept
      // the query via the native Maps app or parse it perfectly in a browser.
      await launchUrl(
        mapWebUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching map URL: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calendarTopMessage),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('locations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final eventsMap = _processFirestoreDocs(snapshot.data!);

          List<Map<String, dynamic>> getEventsForDay(DateTime day) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            return eventsMap[normalizedDay] ?? [];
          }

          final selectedEvents = getEventsForDay(_selectedDay ?? _focusedDay);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2025, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: getEventsForDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selectedDay == null
                      ? AppLocalizations.of(context)!.selectDate
                      : '${AppLocalizations.of(context)!.eventsFor} ${_selectedDay!.toLocal().toString().split(' ')[0]}:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                  child: Text(AppLocalizations.of(context)!.noDrives),
                )
                    : ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final eventData = selectedEvents[index];
                    final eventName = eventData['name'] ?? 'Unnamed Event';
                    final eventId = eventData['docId'] ?? eventName;

                    // Convert timestamp to readable date/time string
                    Timestamp timestamp = eventData['time'];
                    DateTime eventDateTime = timestamp.toDate();
                    Timestamp endtimestamp = eventData['end'];
                    DateTime endDateTime = endtimestamp.toDate();
                    String eventTimeFormatted =
                        '${eventDateTime.month}/${eventDateTime.day}/${eventDateTime.year} at ${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';
                    String endTimeFormatted =
                        '${endDateTime.month}/${endDateTime.day}/${endDateTime.year} at ${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}';

                    // Set up an expansion tile controller and check for auto-expand trigger
                    final controller = _tileControllers.putIfAbsent(
                      eventId,
                          () => ExpansibleController(),
                    );

                    final bool shouldAutoExpand =
                        widget.autoExpandEventId != null &&
                            (widget.autoExpandEventId == eventId ||
                                widget.autoExpandEventId == eventName);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        controller: controller,
                        initiallyExpanded: shouldAutoExpand,
                        leading:
                        const Icon(Icons.event, color: Colors.blue),
                        title: Text(
                          eventName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                        Text(AppLocalizations.of(context)!.tapDetails),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.event}: $eventName\n${AppLocalizations.of(context)!.start}: $eventTimeFormatted\n${AppLocalizations.of(context)!.end}: $endTimeFormatted',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: eventData['address'] != null && eventData['address'].toString().trim().isNotEmpty
                                      ? () => _openMap(eventData['address'].toString())
                                      : null,
                                  icon: const Icon(Icons.map),
                                  label: Text(AppLocalizations.of(context)!.openMaps),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}