// location_service.dart
import 'package:geocoding/geocoding.dart';

class LocationService {
  // 1. Instantiate the newly required Geocoding class instance
  static final Geocoding _geocoding = Geocoding();

  /// Converts an address string into precise Latitude/Longitude coordinates.
  static Future<Location?> getCoordinates(String address) async {
    if (address.trim().isEmpty) return null;

    try {
      // 2. Call the method directly from the instance object
      List<Location> locations = await _geocoding.locationFromAddress(address);

      if (locations.isNotEmpty) {
        return locations.first; // Returns the highest confidence match
      }
    } catch (e) {
      print("Geocoding exception: $e");
    }
    return null;
  }
}
