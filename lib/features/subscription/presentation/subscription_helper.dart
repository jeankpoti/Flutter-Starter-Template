import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import 'subscription_cubit.dart';

class SubscriptionHelper {
  /// Check if user has premium access, and prompt to upgrade if not
  ///
  /// Returns true if the user has premium access, false otherwise
  static bool checkPremiumAccess(
    BuildContext context, {
    bool showDialog = true,
  }) {
    final subscriptionState = context.read<SubscriptionCubit>().state;

    if (subscriptionState.isSubscribed) {
      return true;
    }

    if (showDialog) {
      _showPremiumRequiredDialog(context);
    }

    return false;
  }

  /// Navigate to subscription page
  static void navigateToSubscription(BuildContext context) {
    context.pushNamed(AppRoute.subscriptionPage.name);
  }

  /// Check if user is currently in a trial period
  static bool isInTrialPeriod(BuildContext context) {
    final subscriptionState = context.read<SubscriptionCubit>().state;
    return subscriptionState.isSubscribed &&
        subscriptionState.subscription.isInTrialPeriod;
  }

  /// Get remaining trial days if user is in trial period
  static int? getRemainingTrialDays(BuildContext context) {
    final subscriptionState = context.read<SubscriptionCubit>().state;

    if (!subscriptionState.isSubscribed ||
        !subscriptionState.subscription.isInTrialPeriod ||
        subscriptionState.subscription.expirationDate == null) {
      return null;
    }

    final now = DateTime.now();
    final expirationDate = subscriptionState.subscription.expirationDate!;
    final difference = expirationDate.difference(now);

    return difference.inDays + 1; // +1 to include the current day
  }

  /// Show a dialog prompting the user to upgrade to premium
  static Future<void> _showPremiumRequiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.premiumFeature),
            content: Text(
              AppLocalizations.of(context)!.premiumFeatureDescription,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.notNow),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigateToSubscription(context);
                },
                child: Text(AppLocalizations.of(context)!.upgrade),
              ),
            ],
          ),
    );
  }
}
