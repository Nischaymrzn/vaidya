import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';

abstract class ILightSensorService {
  Stream<int> luxStream();
}

final lightSensorServiceProvider = Provider<ILightSensorService>((ref) {
  return LightSensorService();
});

class LightSensorService implements ILightSensorService {
  @override
  Stream<int> luxStream() {
    // Keep the stream resilient: if sensor access fails, emit nothing.
    return LightSensor.luxStream().handleError((_) {});
  }
}

