import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/models/subscription_model.dart';

enum SubscriptionStatus { initial, loading, loaded, error }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final SubscriptionModel subscription;
  final List<Package> availablePackages;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.subscription = const SubscriptionModel(),
    this.availablePackages = const [],
    this.errorMessage,
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState();
  }

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    SubscriptionModel? subscription,
    List<Package>? availablePackages,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      availablePackages: availablePackages ?? this.availablePackages,
      errorMessage: errorMessage,
    );
  }

  bool get isSubscribed => subscription.isSubscribed;

  @override
  List<Object?> get props => [
    status,
    subscription,
    availablePackages,
    errorMessage,
  ];
}
