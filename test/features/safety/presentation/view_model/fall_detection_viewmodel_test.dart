import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vaidya/core/services/alerts/emergency_alert_service.dart';
import 'package:vaidya/core/services/sensors/accelerometer_service.dart';
import 'package:vaidya/features/safety/presentation/view_model/fall_detection_viewmodel.dart';

class FakeAccelerometerService implements IAccelerometerService {
  final StreamController<AccelerometerEvent> accelerometerController;
  final StreamController<UserAccelerometerEvent> userAccelerometerController;
  final StreamController<GyroscopeEvent> gyroscopeController;

  FakeAccelerometerService(
    this.accelerometerController,
    this.userAccelerometerController,
    this.gyroscopeController,
  );

  @override
  Stream<AccelerometerEvent> accelerometerStream() =>
      accelerometerController.stream;

  @override
  Stream<UserAccelerometerEvent> userAccelerometerStream() =>
      userAccelerometerController.stream;

  @override
  Stream<GyroscopeEvent> gyroscopeStream() => gyroscopeController.stream;
}

class FakeEmergencyAlertService implements IEmergencyAlertService {
  int callCount = 0;

  @override
  Future<EmergencyAlertDispatchResult> sendEmergencyAlertEmail() async {
    callCount += 1;
    return EmergencyAlertDispatchResult.launchedComposer;
  }
}

void main() {
  late StreamController<AccelerometerEvent> accelerometerController;
  late StreamController<UserAccelerometerEvent> userAccelerometerController;
  late StreamController<GyroscopeEvent> gyroscopeController;
  late FakeEmergencyAlertService fakeEmergencyAlertService;
  late ProviderContainer container;

  setUp(() {
    accelerometerController = StreamController<AccelerometerEvent>.broadcast();
    userAccelerometerController =
        StreamController<UserAccelerometerEvent>.broadcast();
    gyroscopeController = StreamController<GyroscopeEvent>.broadcast();
    fakeEmergencyAlertService = FakeEmergencyAlertService();
    container = ProviderContainer(
      overrides: [
        accelerometerServiceProvider.overrideWith(
          (ref) => FakeAccelerometerService(
            accelerometerController,
            userAccelerometerController,
            gyroscopeController,
          ),
        ),
        emergencyAlertServiceProvider.overrideWithValue(
          fakeEmergencyAlertService,
        ),
      ],
    );
  });

  tearDown(() async {
    await accelerometerController.close();
    await userAccelerometerController.close();
    await gyroscopeController.close();
    container.dispose();
  });

  Future<void> emitAcc(AccelerometerEvent event) async {
    accelerometerController.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }

  Future<void> emitUser(UserAccelerometerEvent event) async {
    userAccelerometerController.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }

  Future<void> emitGyro(GyroscopeEvent event) async {
    gyroscopeController.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }

  Future<void> triggerFallPattern() async {
    // Baseline sample to stabilize gravity estimate.
    await emitUser(UserAccelerometerEvent(0.2, 0.0, 0.0, DateTime.now()));
    await emitGyro(GyroscopeEvent(0.1, 0.0, 0.0, DateTime.now()));
    await emitAcc(AccelerometerEvent(9.8, 0.0, 0.0, DateTime.now()));

    // Sustained downward sequence with gravity dip and low rotation.
    for (var i = 0; i < 5; i++) {
      await emitUser(UserAccelerometerEvent(8.6, 0.0, 0.0, DateTime.now()));
      await emitGyro(GyroscopeEvent(0.4, 0.0, 0.0, DateTime.now()));
      await emitAcc(AccelerometerEvent(7.8, 0.0, 0.0, DateTime.now()));
    }

    // Impact.
    await emitUser(UserAccelerometerEvent(14.8, 0.0, 0.0, DateTime.now()));
    await emitAcc(AccelerometerEvent(19.4, 0.0, 0.0, DateTime.now()));

    // Post-impact stillness window.
    for (var i = 0; i < 7; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await emitUser(UserAccelerometerEvent(0.6, 0.0, 0.0, DateTime.now()));
      await emitGyro(GyroscopeEvent(0.2, 0.0, 0.0, DateTime.now()));
      await emitAcc(AccelerometerEvent(9.8, 0.0, 0.0, DateTime.now()));
    }
  }

  group('FallDetectionViewModel', () {
    test('1) starts with expected initial state', () {
      final state = container.read(fallDetectionViewModelProvider);

      expect(state.monitoringEnabled, isTrue);
      expect(state.awaitingUserConfirmation, isFalse);
      expect(state.alertSent, isFalse);
      expect(state.eventCount, 0);
    });

    test('2) updates x/y/z and magnitude on sensor event', () async {
      container.read(fallDetectionViewModelProvider);

      await emitAcc(AccelerometerEvent(3.0, 4.0, 12.0, DateTime.now()));
      await emitUser(UserAccelerometerEvent(1.5, 0, 0, DateTime.now()));
      await emitGyro(GyroscopeEvent(0.7, 0, 0, DateTime.now()));
      final state = container.read(fallDetectionViewModelProvider);

      expect(state.x, 3.0);
      expect(state.y, 4.0);
      expect(state.z, 12.0);
      expect(state.accelerationMagnitude, closeTo(13.0, 0.01));
      expect(state.userAccelerationMagnitude, closeTo(1.5, 0.01));
      expect(state.gyroscopeMagnitude, closeTo(0.7, 0.01));
      expect(state.eventCount, greaterThan(0));
      expect(state.sensorAvailable, isTrue);
    });

    test('3) setMonitoringEnabled(false) pauses monitoring', () async {
      final notifier = container.read(fallDetectionViewModelProvider.notifier);

      notifier.setMonitoringEnabled(false);
      final state = container.read(fallDetectionViewModelProvider);

      expect(state.monitoringEnabled, isFalse);
      expect(state.statusMessage, contains('paused'));
    });

    test('4) setMonitoringEnabled(true) resumes monitoring state', () async {
      final notifier = container.read(fallDetectionViewModelProvider.notifier);
      notifier.setMonitoringEnabled(false);
      notifier.setMonitoringEnabled(true);

      final state = container.read(fallDetectionViewModelProvider);
      expect(state.monitoringEnabled, isTrue);
    });

    test('5) sendEmergencyAlertNow sets alertSent true', () async {
      final notifier = container.read(fallDetectionViewModelProvider.notifier);
      notifier.sendEmergencyAlertNow();
      await Future<void>.delayed(const Duration(milliseconds: 80));

      final state = container.read(fallDetectionViewModelProvider);
      expect(state.alertSent, isTrue);
      expect(
        state.statusMessage,
        anyOf(contains('Preparing GPS'), contains('email draft opened')),
      );
      expect(fakeEmergencyAlertService.callCount, 1);
    });

    test('6) clearAlert resets alert state', () async {
      final notifier = container.read(fallDetectionViewModelProvider.notifier);
      notifier.sendEmergencyAlertNow();
      notifier.clearAlert();

      final state = container.read(fallDetectionViewModelProvider);
      expect(state.alertSent, isFalse);
      expect(state.statusMessage, contains('Monitoring'));
    });

    test(
      '7) acknowledgeUserSafe is no-op when not awaiting confirmation',
      () async {
        final notifier = container.read(
          fallDetectionViewModelProvider.notifier,
        );
        final before = container.read(fallDetectionViewModelProvider);

        notifier.acknowledgeUserSafe();
        final after = container.read(fallDetectionViewModelProvider);

        expect(after.awaitingUserConfirmation, before.awaitingUserConfirmation);
        expect(after.countdownSeconds, before.countdownSeconds);
      },
    );

    test(
      '8) fall-like sequence triggers awaiting confirmation dialog state',
      () async {
        container.read(fallDetectionViewModelProvider);

        await triggerFallPattern();
        final state = container.read(fallDetectionViewModelProvider);

        expect(state.awaitingUserConfirmation, isTrue);
        expect(state.countdownSeconds, greaterThan(0));
        expect(state.alertSent, isFalse);
      },
    );

    test(
      '9) countdown decreases after fall confirmation is triggered',
      () async {
        container.read(fallDetectionViewModelProvider);

        await triggerFallPattern();
        final started = container.read(fallDetectionViewModelProvider);
        await Future<void>.delayed(const Duration(seconds: 1));
        final next = container.read(fallDetectionViewModelProvider);

        expect(started.countdownSeconds, greaterThan(next.countdownSeconds));
      },
    );

    test(
      '10) shows no-data message when stream has no recent events',
      () async {
        container.read(fallDetectionViewModelProvider);

        await Future<void>.delayed(const Duration(milliseconds: 2300));
        final state = container.read(fallDetectionViewModelProvider);

        expect(state.sensorAvailable, isFalse);
        expect(state.statusMessage, contains('No accelerometer data'));
      },
    );

    test(
      '11) disabling monitoring stops sensor tracking until re-enabled',
      () async {
        container.read(fallDetectionViewModelProvider);
        await emitAcc(AccelerometerEvent(9.8, 0.0, 0.0, DateTime.now()));

        final notifier = container.read(
          fallDetectionViewModelProvider.notifier,
        );
        notifier.setMonitoringEnabled(false);
        final paused = container.read(fallDetectionViewModelProvider);

        await emitAcc(AccelerometerEvent(15.0, 1.0, 0.0, DateTime.now()));
        await emitUser(UserAccelerometerEvent(5.0, 0.0, 0.0, DateTime.now()));
        await emitGyro(GyroscopeEvent(2.0, 0.0, 0.0, DateTime.now()));
        final afterPausedEvents = container.read(
          fallDetectionViewModelProvider,
        );

        expect(afterPausedEvents.eventCount, paused.eventCount);
        expect(
          afterPausedEvents.accelerationMagnitude,
          paused.accelerationMagnitude,
        );

        notifier.setMonitoringEnabled(true);
        await emitAcc(AccelerometerEvent(10.1, 0.0, 0.0, DateTime.now()));
        final resumed = container.read(fallDetectionViewModelProvider);
        expect(resumed.eventCount, greaterThan(afterPausedEvents.eventCount));
      },
    );
  });
}
