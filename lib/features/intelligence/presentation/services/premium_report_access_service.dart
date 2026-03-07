import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/features/profile/domain/usecases/create_profile_checkout_session_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_payment_status_usecase.dart';

class PremiumReportAccessService {
  PremiumReportAccessService._();

  static Future<bool> ensurePremiumAccess(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final session = ref.read(userSessionServiceProvider);
    if (session.getCurrentUserIsPremium()) return true;

    final statusResult = await ref.read(
      getProfilePaymentStatusUsecaseProvider,
    )();
    final isPremium = statusResult.fold(
      (_) => false,
      (status) => status.isPremium,
    );
    if (isPremium) {
      await session.setCurrentUserIsPremium(true);
      return true;
    }

    if (!context.mounted) return false;
    final unlock = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Premium required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'PDF report downloads are available on Premium plan.',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Unlock PDF download'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (unlock != true || !context.mounted) return false;

    final checkoutResult = await ref.read(
      createProfileCheckoutSessionUsecaseProvider,
    )();

    if (checkoutResult.isLeft()) {
      final failure = checkoutResult.fold((left) => left, (_) => null);
      final message = failure?.message ?? '';
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          message.isEmpty ? 'Failed to start Stripe checkout.' : message,
        );
      }
      return false;
    }

    final checkoutUrl = checkoutResult.getOrElse(() => '').trim();
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Invalid checkout URL received.');
      }
      return false;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      SnackbarUtils.showError(context, 'Unable to open Stripe checkout.');
    }
    return false;
  }
}
