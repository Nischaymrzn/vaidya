import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vaidya/core/services/alerts/emergency_alert_service.dart';
import 'package:vaidya/core/services/sensors/accelerometer_service.dart';

class FallDetectionState {
  final bool monitoringEnabled;
  final bool sensorAvailable;
  final bool awaitingUserConfirmation;
  final bool alertSent;
  final int countdownSeconds;
  final int eventCount;
  final double x;
  final double y;
  final double z;
  final double accelerationMagnitude;
  final double userAccelerationMagnitude;
  final double gyroscopeMagnitude;
  final DateTime? lastFallAt;
  final String statusMessage;

  const FallDetectionState({
    required this.monitoringEnabled,
    required this.sensorAvailable,
    required this.awaitingUserConfirmation,
    required this.alertSent,
    required this.countdownSeconds,
    required this.eventCount,
    required this.x,
    required this.y,
    required this.z,
    required this.accelerationMagnitude,
    required this.userAccelerationMagnitude,
    required this.gyroscopeMagnitude,
    required this.lastFallAt,
    required this.statusMessage,
  });

  const FallDetectionState.initial()
    : monitoringEnabled = true,
      sensorAvailable = false,
      awaitingUserConfirmation = false,
      alertSent = false,
      countdownSeconds = 0,
      eventCount = 0,
      x = 0,
      y = 0,
      z = 0,
      accelerationMagnitude = 9.8,
      userAccelerationMagnitude = 0,
      gyroscopeMagnitude = 0,
      lastFallAt = null,
      statusMessage = 'Monitoring fall-like movement';

  FallDetectionState copyWith({
    bool? monitoringEnabled,
    bool? sensorAvailable,
    bool? awaitingUserConfirmation,
    bool? alertSent,
    int? countdownSeconds,
    int? eventCount,
    double? x,
    double? y,
    double? z,
    double? accelerationMagnitude,
    double? userAccelerationMagnitude,
    double? gyroscopeMagnitude,
    DateTime? lastFallAt,
    String? statusMessage,
  }) {
    return FallDetectionState(
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
      awaitingUserConfirmation:
          awaitingUserConfirmation ?? this.awaitingUserConfirmation,
      alertSent: alertSent ?? this.alertSent,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      eventCount: eventCount ?? this.eventCount,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      accelerationMagnitude:
          accelerationMagnitude ?? this.accelerationMagnitude,
      userAccelerationMagnitude:
          userAccelerationMagnitude ?? this.userAccelerationMagnitude,
      gyroscopeMagnitude: gyroscopeMagnitude ?? this.gyroscopeMagnitude,
      lastFallAt: lastFallAt ?? this.lastFallAt,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

final fallDetectionViewModelProvider =
    NotifierProvider<FallDetectionViewModel, FallDetectionState>(
      FallDetectionViewModel.new,
    );

class FallDetectionViewModel extends Notifier<FallDetectionState> {
  // Optimization for real-device demos:
  // lower thresholds for easier demo triggering.
  static const double _gravityDipThreshold = 9.2;
  static const double _downwardArmingThreshold = 6.0;
  static const double _minDownwardUserMagnitude = 3.2;
  static const double _maxRotationForDownwardArming = 2.2;
  static const int _requiredDownwardSamples = 3;
  static const double _impactAccThreshold = 17.0;
  static const double _impactUserThreshold = 12.0;
  static const Duration _preImpactWindow = Duration(milliseconds: 1500);
  static const Duration _postImpactSettleDuration = Duration(milliseconds: 700);
  static const Duration _postImpactStillnessWindow = Duration(
    milliseconds: 1800,
  );
  static const double _stillUserMeanThreshold = 2.8;
  static const double _stillGyroMeanThreshold = 1.8;
  static const double _stillGyroPeakThreshold = 3.2;
  static const Duration _cooldownDuration = Duration(seconds: 15);
  static const int _responseTimeoutSeconds = 10;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  Timer? _countdownTimer;
  Timer? _healthTimer;
  bool _isDispatchingAlert = false;

  DateTime? _gravityDipAt;
  DateTime? _downwardArmedAt;
  DateTime? _impactAt;
  DateTime? _cooldownUntil;
  DateTime? _lastSensorEventAt;

  double _latestUserMagnitude = 0;
  double _latestGyroMagnitude = 0;
  double _latestUserX = 0;
  double _latestUserY = 0;
  double _latestUserZ = 0;
  double _gravityX = 0;
  double _gravityY = 0;
  double _gravityZ = 9.8;
  int _downwardSampleCount = 0;

  final List<double> _postImpactUserMagnitudes = [];
  final List<double> _postImpactGyroMagnitudes = [];

  @override
  FallDetectionState build() {
    const initialState = FallDetectionState.initial();

    _stopSensorStreams();
    if (initialState.monitoringEnabled) {
      _startSensorStreams();
    }

    ref.onDispose(() async {
      _stopSensorStreams();
      _countdownTimer?.cancel();
      _countdownTimer = null;
    });

    return initialState;
  }

  void _startSensorStreams() {
    if (_accelerometerSubscription != null ||
        _userAccelerometerSubscription != null ||
        _gyroscopeSubscription != null) {
      return;
    }

    final service = ref.read(accelerometerServiceProvider);
    _accelerometerSubscription = service.accelerometerStream().listen(
      _onAccelerometerEvent,
      onError: (_) =>
          _markSensorUnavailable('Accelerometer stream unavailable.'),
    );
    _userAccelerometerSubscription = service.userAccelerometerStream().listen(
      _onUserAccelerometerEvent,
      onError: (_) {},
    );
    _gyroscopeSubscription = service.gyroscopeStream().listen(
      _onGyroscopeEvent,
      onError: (_) {},
    );
    _lastSensorEventAt = null;
    _startHealthTimer();
  }

  void _stopSensorStreams() {
    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _userAccelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _healthTimer?.cancel();
    _healthTimer = null;
    _lastSensorEventAt = null;
  }

  void _onUserAccelerometerEvent(UserAccelerometerEvent event) {
    if (!state.monitoringEnabled) return;
    _latestUserX = event.x;
    _latestUserY = event.y;
    _latestUserZ = event.z;
    _latestUserMagnitude = _vectorMagnitude(event.x, event.y, event.z);
    state = state.copyWith(userAccelerationMagnitude: _latestUserMagnitude);
  }

  void _onGyroscopeEvent(GyroscopeEvent event) {
    if (!state.monitoringEnabled) return;
    _latestGyroMagnitude = _vectorMagnitude(event.x, event.y, event.z);
    state = state.copyWith(gyroscopeMagnitude: _latestGyroMagnitude);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!state.monitoringEnabled) return;
    final now = DateTime.now();
    _lastSensorEventAt = now;

    final accMagnitude = _vectorMagnitude(event.x, event.y, event.z);
    _updateGravityEstimate(event.x, event.y, event.z);
    final downwardProjection = _downwardProjectionOnGravity();

    final shouldResetStatus =
        !state.sensorAvailable ||
        state.statusMessage.contains('unavailable') ||
        state.statusMessage.startsWith('No accelerometer data');

    state = state.copyWith(
      sensorAvailable: true,
      eventCount: state.eventCount + 1,
      x: event.x,
      y: event.y,
      z: event.z,
      accelerationMagnitude: accMagnitude,
      statusMessage: shouldResetStatus
          ? 'Monitoring fall-like movement'
          : state.statusMessage,
    );

    if (state.awaitingUserConfirmation) return;
    if (_cooldownUntil != null && now.isBefore(_cooldownUntil!)) return;

    if (accMagnitude <= _gravityDipThreshold) {
      _gravityDipAt = now;
    }

    if (downwardProjection >= _downwardArmingThreshold &&
        _latestUserMagnitude >= _minDownwardUserMagnitude &&
        _latestGyroMagnitude <= _maxRotationForDownwardArming) {
      _downwardSampleCount += 1;
      if (_downwardSampleCount >= _requiredDownwardSamples) {
        final hasGravityDip = _isWithinWindow(
          _gravityDipAt,
          now,
          _preImpactWindow,
        );
        if (hasGravityDip) {
          _downwardArmedAt = now;
        }
      }
    } else {
      _downwardSampleCount = 0;
    }

    if (_impactAt == null) {
      final impactDetected =
          accMagnitude >= _impactAccThreshold ||
          _latestUserMagnitude >= _impactUserThreshold;

      final downwardCue = _isWithinWindow(
        _downwardArmedAt,
        now,
        _preImpactWindow,
      );

      final armed = downwardCue;
      if (impactDetected && armed) {
        _impactAt = now;
        _postImpactUserMagnitudes.clear();
        _postImpactGyroMagnitudes.clear();
        state = state.copyWith(
          statusMessage: 'Impact detected. Validating stillness...',
        );
      }
      return;
    }

    final elapsedSinceImpact = now.difference(_impactAt!);
    if (elapsedSinceImpact < _postImpactSettleDuration) {
      // Pillow drops typically bounce immediately; ignore that rebound window.
      return;
    }

    _postImpactUserMagnitudes.add(_latestUserMagnitude);
    _postImpactGyroMagnitudes.add(_latestGyroMagnitude);

    final samplingElapsed = elapsedSinceImpact - _postImpactSettleDuration;
    if (samplingElapsed < _postImpactStillnessWindow) return;

    final meanUser = _mean(_postImpactUserMagnitudes);
    final meanGyro = _mean(_postImpactGyroMagnitudes);
    final peakGyro = _max(_postImpactGyroMagnitudes);

    _resetPattern();

    if (meanUser <= _stillUserMeanThreshold &&
        meanGyro <= _stillGyroMeanThreshold &&
        peakGyro <= _stillGyroPeakThreshold) {
      _triggerFallConfirmation();
    } else {
      state = state.copyWith(statusMessage: 'Movement spike ignored.');
    }
  }

  void _triggerFallConfirmation() {
    _resetPattern();
    _countdownTimer?.cancel();

    state = state.copyWith(
      awaitingUserConfirmation: true,
      alertSent: false,
      countdownSeconds: _responseTimeoutSeconds,
      lastFallAt: DateTime.now(),
      statusMessage: 'Possible fall detected. Please confirm you are okay.',
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.countdownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        _sendEmergencyAlert();
        return;
      }
      state = state.copyWith(
        countdownSeconds: next,
        statusMessage: 'No response yet. Sending alert in ${next}s.',
      );
    });
  }

  void acknowledgeUserSafe() {
    if (!state.awaitingUserConfirmation) return;

    _countdownTimer?.cancel();
    _cooldownUntil = DateTime.now().add(_cooldownDuration);
    state = state.copyWith(
      awaitingUserConfirmation: false,
      countdownSeconds: 0,
      alertSent: false,
      statusMessage: 'Marked safe. Monitoring resumed.',
    );
  }

  void sendEmergencyAlertNow() {
    _sendEmergencyAlert();
  }

  void clearAlert() {
    if (!state.alertSent) return;
    state = state.copyWith(
      alertSent: false,
      statusMessage: 'Monitoring fall-like movement',
    );
  }

  void setMonitoringEnabled(bool enabled) {
    if (enabled == state.monitoringEnabled) return;

    _countdownTimer?.cancel();
    _resetPattern();
    _cooldownUntil = null;

    if (enabled) {
      _startSensorStreams();
    } else {
      _stopSensorStreams();
    }

    state = state.copyWith(
      monitoringEnabled: enabled,
      sensorAvailable: false,
      awaitingUserConfirmation: false,
      countdownSeconds: 0,
      alertSent: false,
      statusMessage: enabled
          ? 'Waiting for accelerometer data...'
          : 'Fall detection is paused',
    );
  }

  void triggerFallCheckForDemo() {
    if (!state.monitoringEnabled || state.awaitingUserConfirmation) return;
    _triggerFallConfirmation();
  }

  void _startHealthTimer() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!state.monitoringEnabled || state.awaitingUserConfirmation) return;
      final last = _lastSensorEventAt;
      final stale =
          last == null || DateTime.now().difference(last).inSeconds >= 3;
      if (stale) {
        _markSensorUnavailable(
          'No accelerometer data. Move phone or test on a real device.',
        );
      }
    });
  }

  void _markSensorUnavailable(String message) {
    state = state.copyWith(sensorAvailable: false, statusMessage: message);
  }

  void _sendEmergencyAlert() {
    if (_isDispatchingAlert) return;
    _isDispatchingAlert = true;
    _countdownTimer?.cancel();
    _cooldownUntil = DateTime.now().add(_cooldownDuration);
    state = state.copyWith(
      awaitingUserConfirmation: false,
      countdownSeconds: 0,
      alertSent: true,
      statusMessage: 'No response received. Preparing GPS emergency email...',
    );
    unawaited(_dispatchEmergencyEmail());
  }

  Future<void> _dispatchEmergencyEmail() async {
    final result = await ref
        .read(emergencyAlertServiceProvider)
        .sendEmergencyAlertEmail();

    final nextMessage = switch (result) {
      EmergencyAlertDispatchResult.launchedComposer =>
        'Emergency email draft opened with GPS location.',
      EmergencyAlertDispatchResult.unavailable =>
        'Emergency email app unavailable. Please send alert manually.',
      EmergencyAlertDispatchResult.failed =>
        'Failed to prepare emergency email with GPS.',
    };
    state = state.copyWith(statusMessage: nextMessage);
    _isDispatchingAlert = false;
  }

  void _resetPattern() {
    _gravityDipAt = null;
    _downwardArmedAt = null;
    _impactAt = null;
    _downwardSampleCount = 0;
    _postImpactUserMagnitudes.clear();
    _postImpactGyroMagnitudes.clear();
  }

  bool _isWithinWindow(DateTime? timestamp, DateTime now, Duration window) {
    return timestamp != null && now.difference(timestamp) <= window;
  }

  double _vectorMagnitude(double x, double y, double z) {
    return math.sqrt(x * x + y * y + z * z);
  }

  void _updateGravityEstimate(double x, double y, double z) {
    // Initialize quickly from first sample, then smooth to reduce noise.
    if (state.eventCount == 0) {
      _gravityX = x;
      _gravityY = y;
      _gravityZ = z;
      return;
    }
    const alpha = 0.85;
    _gravityX = alpha * _gravityX + (1 - alpha) * x;
    _gravityY = alpha * _gravityY + (1 - alpha) * y;
    _gravityZ = alpha * _gravityZ + (1 - alpha) * z;
  }

  double _downwardProjectionOnGravity() {
    final gravityNorm = _vectorMagnitude(_gravityX, _gravityY, _gravityZ);
    if (gravityNorm <= 0.001) return 0;
    final gx = _gravityX / gravityNorm;
    final gy = _gravityY / gravityNorm;
    final gz = _gravityZ / gravityNorm;
    return (_latestUserX * gx) + (_latestUserY * gy) + (_latestUserZ * gz);
  }

  double _mean(List<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (a, b) => a + b);
    return sum / values.length;
  }

  double _max(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce(math.max);
  }
}
