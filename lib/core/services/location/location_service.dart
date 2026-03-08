import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationSnapshot {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime capturedAt;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });
}

abstract class ILocationService {
  Future<LocationSnapshot?> getCurrentLocation();
}

final locationServiceProvider = Provider<ILocationService>((ref) {
  return LocationService();
});

class LocationService implements ILocationService {
  @override
  Future<LocationSnapshot?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
