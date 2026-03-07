import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/services/storage/theme_mode_controller.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_theme_screen.dart';

class TestThemeModeController extends ThemeModeController {
  final AppThemeMode initialMode;

  TestThemeModeController(this.initialMode);

  @override
  AppThemeMode build() => initialMode;

  @override
  Future<void> setAppThemeMode(AppThemeMode mode) async {
    state = mode;
  }
}

void main() {
  ProviderContainer createContainer({AppThemeMode mode = AppThemeMode.system}) {
    return ProviderContainer(
      overrides: [
        themeModeControllerProvider.overrideWith(
          () => TestThemeModeController(mode),
        ),
      ],
    );
  }

  Future<ProviderContainer> pumpThemeScreen(
    WidgetTester tester, {
    AppThemeMode mode = AppThemeMode.system,
  }) async {
    final container = createContainer(mode: mode);
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileThemeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('ProfileThemeScreen widget tests', () {
    testWidgets('1) renders Theme app bar title', (tester) async {
      await pumpThemeScreen(tester);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('2) shows Appearance heading', (tester) async {
      await pumpThemeScreen(tester);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('3) shows mode helper subtitle', (tester) async {
      await pumpThemeScreen(tester);
      expect(find.text('Choose your preferred mode.'), findsOneWidget);
    });

    testWidgets('4) shows Light, Dark, System and Auto options', (
      tester,
    ) async {
      await pumpThemeScreen(tester);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Auto (Lux)'), findsOneWidget);
    });

    testWidgets('5) starts with provided initial mode selected', (
      tester,
    ) async {
      final container = await pumpThemeScreen(tester, mode: AppThemeMode.dark);
      expect(container.read(themeModeControllerProvider), AppThemeMode.dark);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
    });

    testWidgets('6) tapping Light updates theme mode', (tester) async {
      final container = await pumpThemeScreen(tester, mode: AppThemeMode.dark);
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeControllerProvider), AppThemeMode.light);
    });

    testWidgets('7) tapping Dark updates theme mode', (tester) async {
      final container = await pumpThemeScreen(tester, mode: AppThemeMode.light);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeControllerProvider), AppThemeMode.dark);
    });

    testWidgets('8) tapping System updates theme mode', (tester) async {
      final container = await pumpThemeScreen(tester, mode: AppThemeMode.light);
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeControllerProvider), AppThemeMode.system);
    });

    testWidgets('9) tapping Auto (Lux) updates theme mode', (tester) async {
      final container = await pumpThemeScreen(
        tester,
        mode: AppThemeMode.system,
      );
      await tester.tap(find.text('Auto (Lux)'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeControllerProvider), AppThemeMode.autoLux);
    });

    testWidgets('10) shows exactly one selected radio icon', (tester) async {
      await pumpThemeScreen(tester, mode: AppThemeMode.system);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsNWidgets(3));
    });
  });
}
