import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/core/services/location/location_service.dart';

enum EmergencyAlertDispatchResult {
  launchedComposer,
  unavailable,
  failed,
}

abstract class IEmergencyAlertService {
  Future<EmergencyAlertDispatchResult> sendEmergencyAlertEmail();
}

final emergencyAlertServiceProvider = Provider<IEmergencyAlertService>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return EmergencyAlertService(locationService: locationService);
});

class EmergencyAlertService implements IEmergencyAlertService {
  static const String _fallbackRecipient = 'nischaymaharjann@gmail.com';
  final ILocationService _locationService;

  EmergencyAlertService({required ILocationService locationService})
    : _locationService = locationService;

  @override
  Future<EmergencyAlertDispatchResult> sendEmergencyAlertEmail() async {
    try {
      final snapshot = await _locationService.getCurrentLocation();
      final when = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final locationText = snapshot == null
          ? 'Location unavailable'
          : 'Latitude: ${snapshot.latitude}\n'
                'Longitude: ${snapshot.longitude}\n'
                'Google Maps: https://maps.google.com/?q=${snapshot.latitude},${snapshot.longitude}\n'
                'Accuracy: ${snapshot.accuracyMeters?.toStringAsFixed(1) ?? 'N/A'} m';

      final subject = Uri.encodeComponent('Emergency Fall Alert - Vaidya');
      final body = Uri.encodeComponent(
        'Possible fall detected and no response received within 10 seconds.\n\n'
        'Time: $when\n'
        '$locationText\n\n'
        'Please check immediately.',
      );

      final uri = Uri.parse(
        'mailto:$_fallbackRecipient?subject=$subject&body=$body',
      );
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? EmergencyAlertDispatchResult.launchedComposer
          : EmergencyAlertDispatchResult.unavailable;
    } catch (_) {
      return EmergencyAlertDispatchResult.failed;
    }
  }
}
