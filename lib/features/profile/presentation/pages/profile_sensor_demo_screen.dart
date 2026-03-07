import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/light_sensor_theme_controller.dart';
import 'package:vaidya/features/safety/presentation/view_model/fall_detection_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class ProfileSensorDemoScreen extends ConsumerWidget {
  const ProfileSensorDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorState = ref.watch(lightSensorThemeControllerProvider);
    final sensorController = ref.read(
      lightSensorThemeControllerProvider.notifier,
    );
    final fallState = ref.watch(fallDetectionViewModelProvider);
    final fallNotifier = ref.read(fallDetectionViewModelProvider.notifier);
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Light & Accelerometer',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _SensorCard(
            title: 'Ambient Light',
            body: [
              _valueText(context, '${sensorState.lux} lux'),
              Row(
                children: [
                  Expanded(child: _captionText(context, 'Lux demo control')),
                  Switch.adaptive(
                    value: sensorState.isDemoMode,
                    onChanged: sensorController.setDemoMode,
                  ),
                ],
              ),
              if (sensorState.isDemoMode)
                Slider(
                  min: 0,
                  max: 200,
                  divisions: 200,
                  value: sensorState.lux.clamp(0, 200).toDouble(),
                  onChanged: (value) =>
                      sensorController.setDemoLux(value.round()),
                ),
              if (!sensorState.sensorAvailable)
                _captionText(
                  context,
                  'Ambient light sensor is not available on this device.',
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: 'Accelerometer',
            body: [
              _valueText(
                context,
                '${fallState.accelerationMagnitude.toStringAsFixed(2)} m/s^2',
              ),
              _captionText(
                context,
                'X: ${fallState.x.toStringAsFixed(2)}  '
                'Y: ${fallState.y.toStringAsFixed(2)}  '
                'Z: ${fallState.z.toStringAsFixed(2)}',
              ),
              _captionText(
                context,
                'User acceleration: ${fallState.userAccelerationMagnitude.toStringAsFixed(2)} m/s^2',
              ),
              _captionText(
                context,
                'Gyroscope: ${fallState.gyroscopeMagnitude.toStringAsFixed(2)} rad/s',
              ),
              _captionText(
                context,
                fallState.sensorAvailable
                    ? 'Sensor stream: live (${fallState.eventCount} events)'
                    : 'Sensor stream: not receiving data',
              ),
              _captionText(context, fallState.statusMessage),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _captionText(
                      context,
                      fallState.monitoringEnabled
                          ? 'Fall detection monitoring is enabled'
                          : 'Fall detection monitoring is disabled',
                    ),
                  ),
                  Switch.adaptive(
                    value: fallState.monitoringEnabled,
                    onChanged: fallNotifier.setMonitoringEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: fallState.monitoringEnabled
                      ? fallNotifier.triggerFallCheckForDemo
                      : null,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Trigger Free Fall'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueText(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _captionText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final List<Widget> body;

  const _SensorCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...body,
        ],
      ),
    );
  }
}
