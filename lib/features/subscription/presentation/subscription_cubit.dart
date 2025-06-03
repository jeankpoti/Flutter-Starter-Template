import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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

  /// Open subscription management page to allow users to cancel their subscription
  Future<void> openManageSubscriptions() async {
    try {
      await _subscriptionRepository.openManageSubscriptions();
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'Failed to open subscription management: $e',
        ),
      );
    }
  }
}
