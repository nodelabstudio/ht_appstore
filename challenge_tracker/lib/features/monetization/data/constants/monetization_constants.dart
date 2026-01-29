/// Monetization configuration constants for RevenueCat integration.
///
/// All API keys, product IDs, entitlements, and legal URLs centralized here.
class MonetizationConstants {
  MonetizationConstants._();

  /// RevenueCat Apple API key from RevenueCat Dashboard -> Project -> API Keys
  /// Replace with your actual key from the dashboard.
  static const appleApiKey = 'appl_REPLACE_WITH_YOUR_KEY';

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
  static const privacyPolicyUrl = 'https://www.privacypolicies.com/';

  /// Terms of service URL shown in paywall and settings.
  /// Replace with your actual terms of service URL.
  static const termsOfServiceUrl = 'https://www.privacypolicies.com/';

  /// Support email for user inquiries.
  /// Replace with your actual support email address.
  static const supportEmail = 'support@yourapp.com';
}
