/// Monetization configuration constants for RevenueCat integration.
///
/// All API keys, product IDs, entitlements, and legal URLs centralized here.
class MonetizationConstants {
  MonetizationConstants._();

  /// RevenueCat Apple API key, injected at build time via --dart-define.
  /// See BUILD.md for usage instructions.
  static const appleApiKey = String.fromEnvironment('RC_API_KEY');

  /// RevenueCat entitlement identifier for Pro subscription.
  /// Must match entitlement created in RevenueCat Dashboard -> Entitlements.
  static const proEntitlementId = 'pro';

  /// Monthly subscription product ID.
  /// Must match product created in App Store Connect and RevenueCat Dashboard.
  static const monthlyProductId = 'challenge_tracker_pro_monthly';

  /// Annual subscription product ID.
  /// Must match product created in App Store Connect and RevenueCat Dashboard.
  static const annualProductId = 'challenge_tracker_pro_annual';

  /// Maximum number of active challenges for free users.
  /// Pro users have unlimited challenges.
  static const freeActiveChallengeLimit = 1;

  /// Privacy policy URL shown in paywall and settings.
  /// Replace with your actual privacy policy URL.
  static const privacyPolicyUrl =
      'https://nodelabstudio.github.io/ht_appstore/privacy-policy.html';

  /// Terms of service URL shown in paywall and settings.
  /// Replace with your actual terms of service URL.
  static const termsOfServiceUrl =
      'https://nodelabstudio.github.io/ht_appstore/terms.html';

  /// Support email for user inquiries.
  /// Replace with your actual support email address.
  static const supportEmail = 'quest30@use.startmail.com';
}
