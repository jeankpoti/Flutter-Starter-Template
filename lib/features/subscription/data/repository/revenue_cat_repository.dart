import 'dart:io';

import 'package:math_ai/core/services/analytics_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/subscription.dart';
import '../../domain/models/subscription_model.dart';
import '../../domain/repository/subscription_repository.dart';

class RevenueCatRepository implements SubscriptionRepository {
  bool _isInitialized = false;
  bool _listenerRegistered = false;
  CustomerInfo? _previousCustomerInfo;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      PurchasesConfiguration configuration;

      if (Platform.isIOS || Platform.isMacOS) {
        configuration = PurchasesConfiguration(Subscription.appleApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(Subscription.googleApiKey);
      } else {
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      // Register CustomerInfo listener for subscription state tracking
      _registerCustomerInfoListener();

      // Store initial customer info for comparison
      _previousCustomerInfo = await Purchases.getCustomerInfo();
    } catch (e) {
      rethrow;
    }
  }

  /// Register listener for CustomerInfo updates to track subscription lifecycle events
  void _registerCustomerInfoListener() {
    if (_listenerRegistered) return;

    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    _listenerRegistered = true;
  }

  /// Handle CustomerInfo updates and track subscription lifecycle events
  Future<void> _onCustomerInfoUpdated(CustomerInfo newInfo) async {
    final previousInfo = _previousCustomerInfo;
    _previousCustomerInfo = newInfo;

    if (previousInfo == null) return;

    final previousModel = _mapCustomerInfoToSubscriptionModel(previousInfo);
    final newModel = _mapCustomerInfoToSubscriptionModel(newInfo);

    // Detect subscription state changes
    await _trackSubscriptionStateChanges(previousModel, newModel);
  }

  /// Track subscription lifecycle events by comparing state changes
  Future<void> _trackSubscriptionStateChanges(
    SubscriptionModel previousState,
    SubscriptionModel newState,
  ) async {
    final productId = newState.productIdentifier ?? previousState.productIdentifier;

    // Trial conversion: was in trial, now subscribed but not in trial
    if (previousState.isInTrialPeriod &&
        !newState.isInTrialPeriod &&
        newState.isSubscribed) {
      await AnalyticsService.logTrialConversion(
        productId: productId ?? 'unknown',
        value: 0, // Value not available from CustomerInfo
        currency: 'USD',
      );
    }

    // Subscription expired: was subscribed, now not subscribed
    if (previousState.isSubscribed && !newState.isSubscribed) {
      await AnalyticsService.logSubscriptionExpire(productId: productId);
    }

    // Subscription reactivated: was not subscribed, now subscribed (not new purchase)
    // Note: New purchases are tracked in purchasePackage method
    if (!previousState.isSubscribed &&
        newState.isSubscribed &&
        !newState.isInTrialPeriod) {
      // This could be a renewal after grace period or reactivation
      await AnalyticsService.logSubscriptionReactivate(productId: productId);
    }

    // Product change: subscription type changed
    if (previousState.isSubscribed &&
        newState.isSubscribed &&
        previousState.productIdentifier != newState.productIdentifier &&
        previousState.productIdentifier != null &&
        newState.productIdentifier != null) {
      await AnalyticsService.logSubscriptionChange(
        fromProductId: previousState.productIdentifier,
        toProductId: newState.productIdentifier,
      );
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfoToSubscriptionModel(customerInfo);
    } catch (e) {
      return SubscriptionModel.initial();
    }
  }

  @override
  Future<SubscriptionModel> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfoToSubscriptionModel(customerInfo);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null) {
        return [];
      }

      return current.availablePackages;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<SubscriptionModel?> purchasePackage(Package package) async {
    try {
      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(package);
      return _mapCustomerInfoToSubscriptionModel(purchaseResult.customerInfo);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(
        Subscription.entitlementID,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> openManageSubscriptions() async {
    try {
      // Use RevenueCat Customer Center for better UX and cancellation surveys
      // Falls back to native management URL if Customer Center fails
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      // Fallback to native subscription management URL
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        final managementURL = customerInfo.managementURL;

        if (managementURL != null) {
          await launchUrl(Uri.parse(managementURL));
        } else {
          throw Exception('Unable to get subscription management URL');
        }
      } catch (fallbackError) {
        rethrow;
      }
    }
  }

  /// Helper method to map CustomerInfo to SubscriptionModel
  SubscriptionModel _mapCustomerInfoToSubscriptionModel(
    CustomerInfo customerInfo,
  ) {
    final isSubscribed = customerInfo.entitlements.active.containsKey(
      Subscription.entitlementID,
    );

    // Default values
    SubscriptionType type = SubscriptionType.none;
    DateTime? expirationDate;
    bool isInTrialPeriod = false;
    String? productIdentifier;

    if (isSubscribed) {
      final entitlement =
          customerInfo.entitlements.active[Subscription.entitlementID];
      if (entitlement != null) {
        // Check if it's a trial
        isInTrialPeriod = entitlement.periodType == PeriodType.trial;

        // Set expiration date
        if (entitlement.expirationDate != null) {
          expirationDate = DateTime.parse(entitlement.expirationDate!);
        }

        // Get product identifier
        productIdentifier = entitlement.productIdentifier;

        // Determine subscription type based on product identifier
        if (productIdentifier.contains('weekly')) {
          type = SubscriptionType.weekly;
        } else if (productIdentifier.contains('monthly')) {
          type = SubscriptionType.monthly;
        } else if (productIdentifier.contains('yearly')) {
          type = SubscriptionType.yearly;
        }
      }
    }

    return SubscriptionModel(
      isSubscribed: isSubscribed,
      type: type,
      expirationDate: expirationDate,
      isInTrialPeriod: isInTrialPeriod,
      productIdentifier: productIdentifier,
    );
  }
}
