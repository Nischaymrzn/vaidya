import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/sensors/light_sensor_service.dart';

class LightSensorThemeState {
  final int lux;
  final Brightness brightness;
  final bool sensorAvailable;
  final bool isDemoMode;

  const LightSensorThemeState({
    required this.lux,
    required this.brightness,
    required this.sensorAvailable,
    required this.isDemoMode,
  });

  LightSensorThemeState copyWith({
    int? lux,
    Brightness? brightness,
    bool? sensorAvailable,
    bool? isDemoMode,
  }) {
    return LightSensorThemeState(
      lux: lux ?? this.lux,
      brightness: brightness ?? this.brightness,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
}

final lightSensorThemeControllerProvider =
    NotifierProvider<LightSensorThemeController, LightSensorThemeState>(
      LightSensorThemeController.new,
    );

class LightSensorThemeController extends Notifier<LightSensorThemeState> {
  static const int _toDarkLuxThreshold = 12;
  static const int _toLightLuxThreshold = 35;
  static const int _defaultDemoLux = 10;

  StreamSubscription<int>? _subscription;

  @override
  LightSensorThemeState build() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final initial = LightSensorThemeState(
      lux: 0,
      brightness: platformBrightness,
      sensorAvailable: false,
      isDemoMode: false,
    );

    _subscription?.cancel();
    _subscription = ref.read(lightSensorServiceProvider).luxStream().listen(
      _onLuxChanged,
      onError: (_) {
        state = state.copyWith(sensorAvailable: false);
      },
    );

    ref.onDispose(() async {
      await _subscription?.cancel();
      _subscription = null;
    });

    return initial;
  }

  void _onLuxChanged(int lux) {
    if (state.isDemoMode) return;
    final boundedLux = lux < 0 ? 0 : lux;
    final nextBrightness = _resolveBrightness(
      current: state.brightness,
      lux: boundedLux,
    );

    state = state.copyWith(
      lux: boundedLux,
      brightness: nextBrightness,
      sensorAvailable: true,
    );
  }

  void setDemoMode(bool enabled) {
    if (enabled) {
      final demoLux = state.lux > 0 ? state.lux : _defaultDemoLux;
      final brightness = _resolveBrightness(
        current: state.brightness,
        lux: demoLux,
      );
      state = state.copyWith(
        isDemoMode: true,
        lux: demoLux,
        brightness: brightness,
      );
      return;
    }

    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    state = state.copyWith(
      isDemoMode: false,
      brightness: state.sensorAvailable ? state.brightness : platformBrightness,
    );
  }

  void setDemoLux(int lux) {
    final boundedLux = lux < 0 ? 0 : lux;
    final nextBrightness = _resolveBrightness(
      current: state.brightness,
      lux: boundedLux,
    );

    state = state.copyWith(
      isDemoMode: true,
      lux: boundedLux,
      brightness: nextBrightness,
    );
  }

  Brightness _resolveBrightness({
    required Brightness current,
    required int lux,
  }) {
    if (current == Brightness.dark && lux >= _toLightLuxThreshold) {
      return Brightness.light;
    }
    if (current == Brightness.light && lux <= _toDarkLuxThreshold) {
      return Brightness.dark;
    }
    return current;
  }
}
