import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/safety/presentation/view_model/fall_detection_viewmodel.dart';

class GlobalFallDetectionListener extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalFallDetectionListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  ConsumerState<GlobalFallDetectionListener> createState() =>
      _GlobalFallDetectionListenerState();
}

class _GlobalFallDetectionListenerState
    extends ConsumerState<GlobalFallDetectionListener> {
  late final ProviderSubscription<FallDetectionState> _subscription;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<FallDetectionState>(
      fallDetectionViewModelProvider,
      _onFallStateChanged,
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  void _onFallStateChanged(
    FallDetectionState? previous,
    FallDetectionState next,
  ) {
    if (!mounted) return;

    if (next.awaitingUserConfirmation && !_isDialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDialogOpen) {
          _showFallConfirmationDialog();
        }
      });
    }

    if (!next.awaitingUserConfirmation && _isDialogOpen) {
      widget.navigatorKey.currentState?.maybePop();
      _isDialogOpen = false;
    }

    if (next.alertSent && previous?.alertSent != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAlertSentDialog();
        }
      });
    }
  }

  Future<void> _showFallConfirmationDialog() async {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    final dialogContext = widget.navigatorKey.currentContext;
    if (!mounted || dialogContext == null) return;
    _isDialogOpen = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(fallDetectionViewModelProvider);
            final notifier = ref.read(fallDetectionViewModelProvider.notifier);

            return AlertDialog(
              title: const Text('Possible Fall Detected'),
              content: Text(
                'Are you okay?\n'
                'Alert will be sent in ${state.countdownSeconds}s if no response.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    notifier.sendEmergencyAlertNow();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Send Alert Now'),
                ),
                FilledButton(
                  onPressed: () {
                    notifier.acknowledgeUserSafe();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text("I'm Fine"),
                ),
              ],
            );
          },
        );
      },
    );
    _isDialogOpen = false;
  }

  Future<void> _showAlertSentDialog() async {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
    final dialogContext = widget.navigatorKey.currentContext;
    if (!mounted || dialogContext == null) return;
    if (_isDialogOpen) {
      widget.navigatorKey.currentState?.maybePop();
      _isDialogOpen = false;
    }

    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert Sent'),
        content: const Text(
          'No user response was received in time. Emergency alert has been triggered.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ref.read(fallDetectionViewModelProvider.notifier).clearAlert();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
