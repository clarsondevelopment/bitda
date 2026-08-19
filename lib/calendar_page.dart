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

  final Map<String, ExpansibleController> _tileControllers = {};

  @override
  void initState() {
    super.initState();
    final now = widget.initialSelectedDay ?? DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tileControllers.clear();
    super.dispose();
  }

  Map<DateTime, List<Map<String, dynamic>>> _processFirestoreDocs(
      QuerySnapshot snapshot) {
    final Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};

    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

      final timeField = data['start'] ?? data['time'];
      if (timeField != null && data['name'] != null) {
        Timestamp timestamp = timeField;
        DateTime eventDate = timestamp.toDate();
        final normalizedDate =
        DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (eventsMap[normalizedDate] == null) {
          eventsMap[normalizedDate] = [];
        }

        data['docId'] = doc.id;
        eventsMap[normalizedDate]!.add(data);
      }
    }
    return eventsMap;
  }

  Future<void> _openMap(String address) async {
    if (address.trim().isEmpty || address == "null") {
      return;
    }

    final Uri mapWebUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {
        'api': '1',
        'query': address.trim(),
      },
    );
    await launchUrl(
      mapWebUri,
      mode: LaunchMode.externalApplication,
    );
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

          final activeDay = _selectedDay ?? _focusedDay;
          final selectedEvents = getEventsForDay(activeDay);

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
                    _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                  });
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

                    Timestamp? startTimestamp = eventData['start'] ?? eventData['time'];
                    DateTime eventDateTime = startTimestamp != null
                        ? startTimestamp.toDate()
                        : DateTime.now();

                    Timestamp? endTimestamp = eventData['end'];
                    DateTime endDateTime = endTimestamp != null
                        ? endTimestamp.toDate()
                        : eventDateTime;

                    String eventTimeFormatted =
                        '${eventDateTime.month}/${eventDateTime.day}/${eventDateTime.year} at ${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';
                    String endTimeFormatted =
                        '${endDateTime.month}/${endDateTime.day}/${endDateTime.year} at ${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}';

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