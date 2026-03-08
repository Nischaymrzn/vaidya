import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/theme_mode_controller.dart';
import 'package:vaidya/themes/colors.dart';

class ProfileThemeScreen extends ConsumerWidget {
  const ProfileThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    final colorScheme = theme.colorScheme;
    final cardColor = AppColors.card;
    final borderColor = AppColors.border;
    final mutedColor = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Theme',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose your preferred mode.',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _option(
                context: context,
                title: 'Light',
                subtitle: 'Always use light theme',
                selected: mode == AppThemeMode.light,
                onTap: () => ref
                    .read(themeModeControllerProvider.notifier)
                    .setAppThemeMode(AppThemeMode.light),
              ),
              const SizedBox(height: 8),
              _option(
                context: context,
                title: 'Dark',
                subtitle: 'Always use dark theme',
                selected: mode == AppThemeMode.dark,
                onTap: () => ref
                    .read(themeModeControllerProvider.notifier)
                    .setAppThemeMode(AppThemeMode.dark),
              ),
              const SizedBox(height: 8),
              _option(
                context: context,
                title: 'System',
                subtitle: 'Follow device theme',
                selected: mode == AppThemeMode.system,
                onTap: () => ref
                    .read(themeModeControllerProvider.notifier)
                    .setAppThemeMode(AppThemeMode.system),
              ),
              const SizedBox(height: 8),
              _option(
                context: context,
                title: 'Auto (Lux)',
                subtitle: 'Switch light/dark from ambient light sensor',
                selected: mode == AppThemeMode.autoLux,
                onTap: () => ref
                    .read(themeModeControllerProvider.notifier)
                    .setAppThemeMode(AppThemeMode.autoLux),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final mutedColor = AppColors.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : AppColors.border,
          ),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? theme.colorScheme.primary : mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
