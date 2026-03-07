import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract class IAccelerometerService {
  Stream<AccelerometerEvent> accelerometerStream();
  Stream<UserAccelerometerEvent> userAccelerometerStream();
  Stream<GyroscopeEvent> gyroscopeStream();
}

final accelerometerServiceProvider = Provider<IAccelerometerService>((ref) {
  return AccelerometerService();
});

class AccelerometerService implements IAccelerometerService {
  @override
  Stream<AccelerometerEvent> accelerometerStream() {
    return accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    );
  }

  @override
  Stream<UserAccelerometerEvent> userAccelerometerStream() {
    return userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    );
  }

  @override
  Stream<GyroscopeEvent> gyroscopeStream() {
    return gyroscopeEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    );
  }
}
