import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';

import 'l10n/app_localizations.dart'; // Provides the ImageFilter class


class GeoPointMapScreen extends StatefulWidget {
  final Function(DateTime, String)? onEventSelected;

  const GeoPointMapScreen({super.key, this.onEventSelected});

  @override
  State<GeoPointMapScreen> createState() => _GeoPointMapScreenState();
}

class _GeoPointMapScreenState extends State<GeoPointMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mapTopMessage),
        centerTitle: true,
        // 2. Clear out all default solid Material 3 backgrounds
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,

        // 3. Add the blurring engine into the flexibleSpace slot
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            // Adjust the blur intensity (higher numbers = more blurry)
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              // Tint color overlay (use white for light mode, black/grey for dark maps)
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('locations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.errorMapPoints));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Marker> markers = [];
          final docs = snapshot.data!.docs;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Check if required fields exist before accessing to prevent errors
            if (data['time'] == null || data['position'] == null) continue;

            final eventDocId = doc.id;
            final eventDate = (data['time'] as Timestamp).toDate();

            // Extract the GeoPoint object from Firestore
            final GeoPoint? geoPoint = data['position'];

            if (geoPoint != null) {
              markers.add(
                Marker(
                  point: LatLng(geoPoint.latitude, geoPoint.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      // Use the callback provided by HomeNavBar to switch tabs in the main scaffold
                      widget.onEventSelected?.call(eventDate, eventDocId);
                    },
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ),
              );
            }
          }

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(38.9717, -76.4922), // Center on Maryland
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourname.myapp',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}