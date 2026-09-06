import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/services/analytics_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../domain/models/subscription_model.dart';
import '../domain/repository/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionCubit(this._subscriptionRepository)
    : super(SubscriptionState.initial()) {
    loadSubscriptionStatus();
  }

  /// Load the current subscription status and available packages
  Future<void> loadSubscriptionStatus() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    try {
      // Get subscription status and available packages in parallel
      final results = await Future.wait([
        _subscriptionRepository.getSubscriptionStatus(),
        _subscriptionRepository.getOfferings(),
      ]);

      final subscription = results[0] as SubscriptionModel;
      final packages = results[1] as List<Package>;

      // Update user properties for Google Ads audience segmentation
      await _updateSubscriptionUserProperties(subscription);

      emit(
        state.copyWith(
          status: SubscriptionStatus.loaded,
          subscription: subscription,
          availablePackages: packages,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'Failed to load subscription info: $e',
        ),
      );
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    try {
      final subscription = await _subscriptionRepository.restorePurchases();

      // Update user properties for Google Ads audience segmentation
      await _updateSubscriptionUserProperties(subscription);

      emit(
        state.copyWith(
          status: SubscriptionStatus.loaded,
          subscription: subscription,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'Failed to restore purchases: $e',
        ),
      );
    }
  }

  /// Purchase a subscription package
  Future<void> purchasePackage(Package package) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    try {
      final subscription = await _subscriptionRepository.purchasePackage(
        package,
      );

      if (subscription != null) {
        // Track the purchase event with revenue data
        await AnalyticsService.logPurchaseCompleted(
          productName: package.storeProduct.identifier,
          amount: package.storeProduct.price,
          currency: package.storeProduct.currencyCode,
        );

        // Update user properties for Google Ads audience segmentation
        await _updateSubscriptionUserProperties(subscription);

        emit(
          state.copyWith(
            status: SubscriptionStatus.loaded,
            subscription: subscription,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: 'Purchase was not completed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'Failed to purchase package: $e',
        ),
      );
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    return _subscriptionRepository.hasActiveSubscription();
  }

  /// Open Customer Center to allow users to manage their subscription
  /// Includes built-in cancellation surveys and win-back offers
  /// Note: Surveys and offers are configured in RevenueCat dashboard
  Future<void> openManageSubscriptions() async {
    try {
      // Track that user opened Customer Center
      await AnalyticsService.logCustomerCenterOpened();

      // Present Customer Center with callbacks for analytics tracking
      await RevenueCatUI.presentCustomerCenter(
        onRestoreCompleted: (customerInfo) {
          // Reload subscription status after restore
          loadSubscriptionStatus();
        },
        onRefundRequestCompleted: (productId, status) {
          // Track refund request for analytics
          AnalyticsService.logSubscriptionCancellation(
            productId: productId,
            refundStatus: status,
          );
          // Reload subscription status
          loadSubscriptionStatus();
        },
        onFeedbackSurveyCompleted: (optionId) {
          // Track the cancellation reason from the survey
          AnalyticsService.logCancellationReason(reason: optionId);
        },
        onPromotionalOfferSucceeded: (customerInfo, transaction, offerId) {
          // Track when user accepts a win-back offer
          AnalyticsService.logWinbackOfferAccepted(
            offerId: offerId,
            productId: transaction.productIdentifier,
          );
          // Reload subscription status after accepting offer
          loadSubscriptionStatus();
        },
      );

      // Reload subscription status after Customer Center closes
      await loadSubscriptionStatus();
    } catch (e) {
      // Fallback to repository method if Customer Center fails
      try {
        await _subscriptionRepository.openManageSubscriptions();
        await loadSubscriptionStatus();
      } catch (fallbackError) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: 'Failed to open subscription management: $e',
          ),
        );
      }
    }
  }

  /// Helper method to update user properties for Google Ads audience segmentation
  Future<void> _updateSubscriptionUserProperties(
    SubscriptionModel subscription,
  ) async {
    String? subscriptionType;
    if (subscription.isSubscribed) {
      switch (subscription.type) {
        case SubscriptionType.weekly:
          subscriptionType = 'weekly';
          break;
        case SubscriptionType.monthly:
          subscriptionType = 'monthly';
          break;
        case SubscriptionType.yearly:
          subscriptionType = 'yearly';
          break;
        case SubscriptionType.none:
          subscriptionType = null;
          break;
      }
    }

    await AnalyticsService.setSubscriptionUserProperties(
      isSubscribed: subscription.isSubscribed,
      subscriptionType: subscriptionType,
      isInTrial: subscription.isInTrialPeriod,
    );
  }
}
