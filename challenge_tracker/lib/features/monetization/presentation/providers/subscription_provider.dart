import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/constants/monetization_constants.dart';

/// Stream provider that listens to subscription status changes.
///
/// Emits true when user has active Pro subscription, false otherwise.
/// Polls RevenueCat every 30 seconds for updates (purchase events trigger immediate refresh).
final subscriptionProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();

  Future<void> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.active
          .containsKey(MonetizationConstants.proEntitlementId);
      controller.add(isPro);
    } catch (e) {
      controller.add(false);
    }
  }

  // Initial check
  checkSubscriptionStatus();

  // Poll every 30 seconds
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    checkSubscriptionStatus();
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

/// One-shot provider to check if user is currently a Pro subscriber.
///
/// Returns true if user has active Pro entitlement, false otherwise.
/// Use this for initial checks; use subscriptionProvider for reactive updates.
final isProProvider = FutureProvider<bool>((ref) async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active
        .containsKey(MonetizationConstants.proEntitlementId);
  } catch (e) {
    // Return false on error (network issues, etc.)
    return false;
  }
});
