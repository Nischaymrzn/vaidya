import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/services/storage/light_sensor_theme_controller.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_sensor_demo_screen.dart';
import 'package:vaidya/features/safety/presentation/view_model/fall_detection_viewmodel.dart';

class TestLightSensorThemeController extends LightSensorThemeController {
  final LightSensorThemeState initialState;

  TestLightSensorThemeController(this.initialState);

  @override
  LightSensorThemeState build() => initialState;
}

class TestFallDetectionViewModel extends FallDetectionViewModel {
  final FallDetectionState initialState;

  TestFallDetectionViewModel(this.initialState);

  @override
  FallDetectionState build() => initialState;
}

void main() {
  Widget buildTestWidget({
    LightSensorThemeState? lightState,
    FallDetectionState? fallState,
  }) {
    return ProviderScope(
      overrides: [
        lightSensorThemeControllerProvider.overrideWith(
          () => TestLightSensorThemeController(
            lightState ??
                const LightSensorThemeState(
                  lux: 120,
                  brightness: Brightness.light,
                  sensorAvailable: true,
                  isDemoMode: false,
                ),
          ),
        ),
        fallDetectionViewModelProvider.overrideWith(
          () => TestFallDetectionViewModel(
            fallState ??
                const FallDetectionState(
                  monitoringEnabled: true,
                  sensorAvailable: true,
                  awaitingUserConfirmation: false,
                  alertSent: false,
                  countdownSeconds: 0,
                  eventCount: 17,
                  x: 0.6,
                  y: -0.4,
                  z: 9.7,
                  accelerationMagnitude: 9.73,
                  userAccelerationMagnitude: 1.2,
                  gyroscopeMagnitude: 0.5,
                  lastFallAt: null,
                  statusMessage: 'Monitoring for fall-like movement',
                ),
          ),
        ),
      ],
      child: const MaterialApp(home: ProfileSensorDemoScreen()),
    );
  }

  group('ProfileSensorDemoScreen widget tests', () {
    testWidgets('1) renders Light & Accelerometer title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Light & Accelerometer'), findsOneWidget);
    });

    testWidgets('2) shows Ambient Light card title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Ambient Light'), findsOneWidget);
    });

    testWidgets('3) shows Accelerometer card title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Accelerometer'), findsOneWidget);
    });

    testWidgets('4) shows lux value text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('120 lux'), findsOneWidget);
    });

    testWidgets('5) shows unavailable light sensor message when needed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          lightState: const LightSensorThemeState(
            lux: 0,
            brightness: Brightness.light,
            sensorAvailable: false,
            isDemoMode: false,
          ),
        ),
      );
      expect(
        find.text('Ambient light sensor is not available on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('6) shows accelerometer magnitude', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('9.73 m/s^2'), findsOneWidget);
    });

    testWidgets('7) shows x/y/z line', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('X: 0.60'), findsOneWidget);
      expect(find.textContaining('Y: -0.40'), findsOneWidget);
      expect(find.textContaining('Z: 9.70'), findsOneWidget);
    });

    testWidgets('8) shows live stream status with event count', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(
        find.textContaining('Sensor stream: live (17 events)'),
        findsOneWidget,
      );
    });

    testWidgets('9) shows non-live stream status when sensor unavailable', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          fallState: const FallDetectionState(
            monitoringEnabled: true,
            sensorAvailable: false,
            awaitingUserConfirmation: false,
            alertSent: false,
            countdownSeconds: 0,
            eventCount: 0,
            x: 0,
            y: 0,
            z: 0,
            accelerationMagnitude: 0,
            userAccelerationMagnitude: 0,
            gyroscopeMagnitude: 0,
            lastFallAt: null,
            statusMessage: 'No accelerometer data.',
          ),
        ),
      );
      expect(find.text('Sensor stream: not receiving data'), findsOneWidget);
    });

    testWidgets('10) shows fall detection status message text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          fallState: const FallDetectionState(
            monitoringEnabled: true,
            sensorAvailable: true,
            awaitingUserConfirmation: false,
            alertSent: false,
            countdownSeconds: 0,
            eventCount: 7,
            x: 1,
            y: 2,
            z: 3,
            accelerationMagnitude: 3.74,
            userAccelerationMagnitude: 0.8,
            gyroscopeMagnitude: 0.4,
            lastFallAt: null,
            statusMessage: 'Monitoring for fall-like movement',
          ),
        ),
      );
      expect(find.text('Monitoring for fall-like movement'), findsOneWidget);
    });

    testWidgets('11) shows lux demo switch control', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Lux demo control'), findsOneWidget);
      final adaptiveSwitchCount =
          find.byType(Switch).evaluate().length +
          find.byType(CupertinoSwitch).evaluate().length;
      expect(adaptiveSwitchCount, greaterThanOrEqualTo(1));
    });

    testWidgets('12) shows trigger free fall button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Trigger Free Fall'), findsOneWidget);
    });
  });
}
