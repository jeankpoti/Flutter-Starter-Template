import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/elevated_button_widget.dart';
import '../../../common_widgets/title_large_text_widget.dart';
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
      appBar: const AppBarWidget(title: 'Premium Subscription'),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state.status == SubscriptionStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
      expirationText =
          'Expires on ${expirationDate.month}/${expirationDate.day}/${expirationDate.year}';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const TitleLargeTextWidget(
              text: 'You have an active subscription!',
            ),
            const SizedBox(height: 16),
            BodyMediumTextWidget(
              text: 'Enjoy all premium features of Snap Animal AI',
            ),
            if (expirationText.isNotEmpty) ...[
              const SizedBox(height: 8),
              BodyMediumTextWidget(text: expirationText),
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

                  text: 'Restore',
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
                          ? 'Cancel Trial'
                          : 'Manage Subscription',
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
            const Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock all features and remove ads',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start with a 3-day free trial',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
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
              text: 'Subscribe',
            ),
          ],
        ),
      ),
    );
  }
}
