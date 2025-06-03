import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/subscription_model.dart';

abstract class SubscriptionRepository {
  /// Initialize the subscription service
  Future<void> initialize();

  /// Get the current subscription status
  Future<SubscriptionModel> getSubscriptionStatus();

  /// Restore previous purchases
  Future<SubscriptionModel> restorePurchases();

  /// Get available subscription packages
  Future<List<Package>> getOfferings();

  /// Purchase a subscription package
  Future<SubscriptionModel?> purchasePackage(Package package);

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription();

  /// Open the subscription management page in the app store
  Future<void> openManageSubscriptions();
}
