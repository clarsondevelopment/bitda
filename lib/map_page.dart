import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'l10n/app_localizations.dart';

class GeoPointMapScreen extends StatefulWidget {
  final Function(DateTime, String)? onEventSelected;

  const GeoPointMapScreen({
    super.key,
    this.onEventSelected,
  });

  @override
  State<GeoPointMapScreen> createState() =>
      _GeoPointMapScreenState();
}

class _GeoPointMapScreenState
    extends State<GeoPointMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.mapTopMessage,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,

        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.0,
              sigmaY: 1.0,
            ),
            child: Container(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
            ),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!
                    .errorMapPoints,
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          final List<Marker> markers = [];

          for (final doc in docs) {
            final data =
            doc.data() as Map<String, dynamic>;

            // ------------------------------------------------
            // Required fields (support both 'start' and 'time')
            // ------------------------------------------------

            final start = data['start'] ?? data['time'];
            final end = data['end'];

            if (start is! Timestamp || end is! Timestamp) {
              continue;
            }

            final startTime = start.toDate();
            final latitudeValue =
            data['latitude'];
            final longitudeValue =
            data['longitude'];

            if (latitudeValue is! num ||
                longitudeValue is! num) {
              continue;
            }

            final latitude =
            latitudeValue.toDouble();

            final longitude =
            longitudeValue.toDouble();

            // ------------------------------------------------
            // Validate coordinates
            // ------------------------------------------------

            if (latitude < -90 ||
                latitude > 90 ||
                longitude < -180 ||
                longitude > 180) {
              continue;
            }

            // ------------------------------------------------
            // Create marker
            // ------------------------------------------------

            markers.add(
              Marker(
                point: LatLng(
                  latitude,
                  longitude,
                ),
                width: 40,
                height: 40,

                child: GestureDetector(
                  onTap: () {
                    widget.onEventSelected?.call(
                      startTime,
                      doc.id,
                    );
                  },

                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            );
          }

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(
                38.9717,
                -76.4922,
              ),
              initialZoom: 12.0,
            ),

            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                'com.clarsondevelopment.bitda',
              ),

              MarkerLayer(
                markers: markers,
              ),
            ],
          );
        },
      ),
    );
  }
}
