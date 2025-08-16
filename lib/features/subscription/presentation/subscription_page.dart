import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/elevated_button_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../l10n/app_localizations.dart';
import 'subscription_cubit.dart';
import 'subscription_state.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    // Load subscription status when page is opened
    context.read<SubscriptionCubit>().loadSubscriptionStatus();

    // Listen for changes in customer info
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      context.read<SubscriptionCubit>().loadSubscriptionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.premiumSubscription,
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state.status == SubscriptionStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: BodyMediumText(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SubscriptionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isSubscribed) {
            return _buildActiveSubscription(context, state);
          }

          return _buildSubscriptionOptions(context, state);
        },
      ),
    );
  }

  Widget _buildActiveSubscription(
    BuildContext context,
    SubscriptionState state,
  ) {
    final subscription = state.subscription;
    String expirationText = '';

    if (subscription.expirationDate != null) {
      final expirationDate = subscription.expirationDate!;
      expirationText = AppLocalizations.of(context)!.expiresOn(
        '${expirationDate.month}/${expirationDate.day}/${expirationDate.year}',
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            TitleLargeText(AppLocalizations.of(context)!.activeSubscription),
            const SizedBox(height: 16),
            BodyMediumText(
              AppLocalizations.of(context)!.enjoyPremiumFeatures,
              textAlign: TextAlign.center,
            ),
            if (expirationText.isNotEmpty) ...[
              const SizedBox(height: 25),
              BodyMediumText(expirationText),
            ],
            const SizedBox(height: 32),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                ElevatedButtonWidget(
                  onPressed:
                      () =>
                          context.read<SubscriptionCubit>().restorePurchases(),

                  text: AppLocalizations.of(context)!.restore,
                ),
                const SizedBox(width: 16),
                ElevatedButtonWidget(
                  onPressed:
                      () =>
                          context
                              .read<SubscriptionCubit>()
                              .openManageSubscriptions(),
                  text:
                      subscription.isInTrialPeriod
                          ? AppLocalizations.of(context)!.cancelTrial
                          : AppLocalizations.of(context)!.manageSubscription,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions(
    BuildContext context,
    SubscriptionState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleLargeText(
              AppLocalizations.of(context)!.upgradeToPremium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            BodyMediumText(
              AppLocalizations.of(context)!.unlockAllFeatures,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              AppLocalizations.of(context)!.startWithFreeTrial,
              color: Colors.green,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButtonWidget(
              onPressed: () async {
                try {
                  await RevenueCatUI.presentPaywall();

                  // Optional: Add a short delay for RevenueCat to update
                  // await Future.delayed(const Duration(seconds: 2));

                  // Reload subscription state
                  // context.read<SubscriptionCubit>().loadSubscriptionStatus();
                } catch (e) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Error: ${e.toString()}')),
                  // );
                }
              },
              text: AppLocalizations.of(context)!.subscribe,
            ),
          ],
        ),
      ),
    );
  }
}
