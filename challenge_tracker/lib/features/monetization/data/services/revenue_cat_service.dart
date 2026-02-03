import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/monetization_constants.dart';

/// Singleton service for managing RevenueCat SDK integration.
///
/// Handles SDK initialization, subscription status checks, and purchase operations.
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize the RevenueCat SDK.
  ///
  /// Must be called once at app startup before any purchase operations.
  /// Uses Apple API key from MonetizationConstants.
  Future<void> init() async {
    if (_isInitialized) return;

    // Enable debug logging for development
    await Purchases.setLogLevel(LogLevel.debug);

    // Configure with Apple API key (injected via --dart-define=RC_API_KEY=...)
    final apiKey = MonetizationConstants.appleApiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        'RC_API_KEY not set. Build with: flutter run --dart-define=RC_API_KEY=appl_yourkey',
      );
    }
    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    _isInitialized = true;
  }

  /// Check if the current user has an active Pro subscription.
  ///
  /// Returns true if the user has the 'pro' entitlement active.
  /// Returns false if not subscribed or on error.
  Future<bool> isProUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active
          .containsKey(MonetizationConstants.proEntitlementId);
    } catch (e) {
      // Return false on error (network issues, etc.)
      return false;
    }
  }

  /// Restore previous purchases.
  ///
  /// Useful for users who reinstalled the app or switched devices.
  /// Returns updated CustomerInfo after restoration.
  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Fetch available subscription offerings.
  ///
  /// Returns configured offerings from RevenueCat dashboard.
  /// Used to display paywall with pricing.
  Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }
}
