import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/subscription.dart';
import '../../domain/models/subscription_model.dart';
import '../../domain/repository/subscription_repository.dart';

class RevenueCatRepository implements SubscriptionRepository {
  bool _isInitialized = false;

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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfoToSubscriptionModel(customerInfo);
    } catch (e) {
      debugPrint('Failed to get subscription status: $e');
      return SubscriptionModel.initial();
    }
  }

  @override
  Future<SubscriptionModel> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfoToSubscriptionModel(customerInfo);
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      rethrow;
    }
  }

  @override
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null) {
        debugPrint('No current offering available');
        return [];
      }

      return current.availablePackages;
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return [];
    }
  }

  @override
  Future<SubscriptionModel?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return _mapCustomerInfoToSubscriptionModel(purchaseResult);
    } catch (e) {
      if (e is PurchasesErrorCode) {
        debugPrint('Purchase error: $e');
      } else {
        debugPrint('Failed to purchase package: $e');
      }
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
      debugPrint('Failed to check subscription status: $e');
      return false;
    }
  }

  @override
  Future<void> openManageSubscriptions() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final managementURL = customerInfo.managementURL;

      if (managementURL != null) {
        await launchUrl(Uri.parse(managementURL));
        debugPrint('Opened subscription management page');
      } else {
        debugPrint('Management URL is null');
        throw Exception('Unable to get subscription management URL');
      }
    } catch (e) {
      debugPrint('Failed to open subscription management: $e');
      rethrow;
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
