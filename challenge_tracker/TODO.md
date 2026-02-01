# Pre-launch Checklist

This file tracks the final steps before submitting the app to the App Store.

- [x] **Revert All Testing Changes**
  - [x] **Critical:** Re-enable paywall.
  - [x] **Critical:** Reset default challenge start date to today.

---

### UI Polish & Features
- [x] **Implement Dark Mode**
- [ ] **Implement Dark Mode Toggle:** Add a manual light/dark/system toggle in the Settings screen.
- [ ] **Fix Streak Icon Color:** The fire icon color on the detail screen is stuck on the default theme color and does not change conditionally. This is a known theming issue.

---

### Final Testing Round
- [ ] Test all core features on a physical device.
- [ ] Test monetization (paywall, restore purchases) on a physical device with a sandbox account.
- [- ] Test notifications.

---

### App Store Preparation
- [ ] Take screenshots for the App Store listing (in both light and dark mode).
- [ ] Write the App Store description and metadata.
- [ ] Finalize the privacy policy and terms of service.

---

### Build Release Version
- [ ] Run `flutter build ipa` to create the final App Store package.
- [ ] Upload the build to App Store Connect.
