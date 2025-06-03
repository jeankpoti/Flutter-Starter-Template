import 'package:equatable/equatable.dart';

enum SubscriptionType { none, weekly, monthly, yearly }

class SubscriptionModel extends Equatable {
  final bool isSubscribed;
  final SubscriptionType type;
  final DateTime? expirationDate;
  final bool isInTrialPeriod;
  final String? productIdentifier;

  const SubscriptionModel({
    this.isSubscribed = false,
    this.type = SubscriptionType.none,
    this.expirationDate,
    this.isInTrialPeriod = false,
    this.productIdentifier,
  });

  factory SubscriptionModel.initial() {
    return const SubscriptionModel();
  }

  SubscriptionModel copyWith({
    bool? isSubscribed,
    SubscriptionType? type,
    DateTime? expirationDate,
    bool? isInTrialPeriod,
    String? productIdentifier,
  }) {
    return SubscriptionModel(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      type: type ?? this.type,
      expirationDate: expirationDate ?? this.expirationDate,
      isInTrialPeriod: isInTrialPeriod ?? this.isInTrialPeriod,
      productIdentifier: productIdentifier ?? this.productIdentifier,
    );
  }

  @override
  List<Object?> get props => [
    isSubscribed,
    type,
    expirationDate,
    isInTrialPeriod,
    productIdentifier,
  ];
}
