# Pre-launch Checklist

This file tracks the final steps before submitting the app to the App Store.

- [ ] **Revert All Testing Changes**
  - [ ] **Critical:** Re-enable paywall.
  - [ ] **Critical:** Reset default challenge start date to today.

- [ ] **UI Polish & Features**
  - [ ] Implement Dark Mode.
  - [ ] Fix streak fire icon color (currently stuck on the default theme color).

- [ ] **Final Testing Round**
  - [ ] Test all core features (challenge creation, completion, streaks).
  - [ ] Test all monetization features (paywall, restore purchases) on a physical device with a sandbox account.
  - [ ] Test all settings and notifications.

- [ ] **App Store Preparation**
  - [ ] Take screenshots for the App Store listing.
  - [ ] Write the App Store description and metadata.
  - [ ] Finalize the privacy policy and terms of service.

- [ ] **Build Release Version**
  - [ ] Run `flutter build ipa` to create the final App Store package.
  - [ ] Upload the build to App Store Connect.