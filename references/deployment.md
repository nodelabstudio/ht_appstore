# Deployment Guide

## Pre-deployment checklist

### 1. Update app metadata

**pubspec.yaml**:
```yaml
name: your_app_name
description: A new Flutter application
version: 1.0.0+1  # version+build_number
```

**Android (android/app/build.gradle)**:
```gradle
defaultConfig {
    applicationId "com.yourcompany.yourapp"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

**iOS (ios/Runner/Info.plist)**:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 2. App icons and splash screens

**Generate icons**:
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

Run: `flutter pub run flutter_launcher_icons`

**Splash screen** (use flutter_native_splash):
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.8

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/splash_icon.png
  android: true
  ios: true
```

Run: `flutter pub run flutter_native_splash:create`

## iOS deployment

### 1. Apple Developer account setup

1. Enroll in Apple Developer Program ($99/year)
2. Create App ID in developer.apple.com
3. Generate certificates and provisioning profiles

### 2. Xcode configuration

Open `ios/Runner.xcworkspace` in Xcode:

1. **General tab**:
   - Set Bundle Identifier
   - Set Version and Build number
   - Select Team

2. **Signing & Capabilities**:
   - Enable "Automatically manage signing"
   - Select your Team
   - Or manually configure provisioning profiles

3. **Build Settings**:
   - Set iOS Deployment Target (minimum iOS version)

### 3. Generate iOS certificates

**Development certificate**:
```bash
# Create certificate signing request
# Keychain Access > Certificate Assistant > Request from Certificate Authority
```

**Distribution certificate**:
1. Go to developer.apple.com > Certificates
2. Create new "Apple Distribution" certificate
3. Download and install in Keychain

**Provisioning profile**:
1. Go to developer.apple.com > Profiles
2. Create "App Store" profile
3. Download and install

### 4. Build release

```bash
# Clean and build
flutter clean
flutter pub get
flutter build ios --release

# Or build with Xcode
# Product > Archive
```

### 5. Upload to App Store Connect

1. Open Xcode
2. Product > Archive
3. Wait for archive to complete
4. Window > Organizer
5. Select archive > Distribute App
6. Choose "App Store Connect"
7. Follow upload wizard

### 6. App Store Connect configuration

1. Go to appstoreconnect.apple.com
2. My Apps > Create New App
3. Fill in metadata:
   - App name
   - Subtitle
   - Description
   - Keywords
   - Screenshots (required sizes)
   - Privacy policy URL
   - Support URL
   - Marketing URL (optional)
   - App category
   - Content rating

4. **Screenshots required**:
   - 6.5" iPhone (1284x2778 or 1290x2796)
   - 5.5" iPhone (1242x2208)
   - iPad Pro (2048x2732)

5. App Privacy:
   - Fill out privacy questionnaire
   - Specify data collection practices

6. Pricing and Availability
7. Submit for Review

### Common iOS issues

**Missing provisioning profile**:
```bash
# Re-download profiles
xcode-select --install
```

**Code signing error**:
- Check Bundle Identifier matches App ID
- Verify Team selection in Xcode
- Regenerate provisioning profile

## Android deployment

### 1. Generate signing key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Store password securely!

### 2. Configure signing

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

Add to `.gitignore`:
```
**/android/key.properties
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 3. Update AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Add permissions -->
        <uses-permission android:name="android.permission.INTERNET"/>
    </application>
</manifest>
```

### 4. Build release

```bash
# Build App Bundle (recommended)
flutter build appbundle --release

# Build APK
flutter build apk --release --split-per-abi
```

Output location:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### 5. Google Play Console setup

1. Go to play.google.com/console
2. Create Application
3. Fill in Store Listing:
   - App name
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (2-8 per device type)
     - Phone: 16:9 or 9:16
     - 7" tablet: 16:9 or 9:16
     - 10" tablet: 16:9 or 9:16
   - Feature graphic: 1024x500
   - App icon: 512x512
   - Privacy policy URL
   - App category
   - Content rating

4. **Content rating**:
   - Complete questionnaire
   - Get rating (everyone, teen, mature, etc.)

5. **App content**:
   - Privacy policy
   - Ads declaration
   - Target audience
   - Data safety

6. **Countries/regions**:
   - Select distribution countries
   - Set pricing (free or paid)

### 6. Upload release

1. Production > Create new release
2. Upload app bundle (.aab file)
3. Add release notes
4. Review and rollout

### 7. Internal/Beta testing

Before production:
1. Create internal testing track
2. Add testers (email addresses)
3. Upload app bundle to internal track
4. Get feedback
5. Fix issues
6. Promote to production

## Release automation with Fastlane

### Install Fastlane

```bash
# macOS
brew install fastlane

# Or with Ruby
gem install fastlane
```

### iOS Fastlane setup

```bash
cd ios
fastlane init
```

**Fastfile**:
```ruby
default_platform(:ios)

platform :ios do
  desc "Push to TestFlight"
  lane :beta do
    build_app(scheme: "Runner")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end

  desc "Release to App Store"
  lane :release do
    build_app(scheme: "Runner")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false
    )
  end
end
```

Run: `fastlane beta` or `fastlane release`

### Android Fastlane setup

```bash
cd android
fastlane init
```

**Fastfile**:
```ruby
default_platform(:android)

platform :android do
  desc "Deploy to Play Store"
  lane :deploy do
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab"
    )
  end

  desc "Deploy to internal testing"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab"
    )
  end
end
```

Run: `fastlane internal` or `fastlane deploy`

## Version management

### Updating version numbers

**Increment version**:
```bash
# From 1.0.0+1 to 1.0.1+2
flutter pub version patch

# From 1.0.0+1 to 1.1.0+2
flutter pub version minor

# From 1.0.0+1 to 2.0.0+2
flutter pub version major
```

### App Store version strategy

- **Major** (1.0.0): Significant changes, redesigns
- **Minor** (1.1.0): New features, improvements
- **Patch** (1.0.1): Bug fixes, small updates

### Build numbers

- Increment for each upload to stores
- Must always increase (can't reuse)

## App Store Review Guidelines

### iOS rejection reasons

1. **Crashes/bugs**: Test thoroughly
2. **Incomplete info**: Fill all metadata
3. **Copycat apps**: Ensure originality
4. **Privacy violations**: Clear privacy policy
5. **In-app purchases**: Proper implementation
6. **Misleading content**: Accurate descriptions
7. **Poor performance**: Optimize app
8. **Inappropriate content**: Follow guidelines

### Google Play rejection reasons

1. **Broken functionality**: Test all features
2. **Privacy policy**: Required for most apps
3. **Permissions**: Request only necessary ones
4. **Metadata**: Accurate screenshots/descriptions
5. **Malware**: Code security
6. **Intellectual property**: Own rights to content
7. **Monetization**: Clear pricing, no deceptive practices

## Post-deployment

### Monitor crash reports

**iOS**:
- Xcode Organizer > Crashes
- App Store Connect > App Analytics

**Android**:
- Google Play Console > Quality > Android vitals
- Crashlytics integration

### Update strategy

1. Monitor user feedback
2. Track crash reports
3. Fix critical bugs quickly
4. Plan feature releases
5. Test thoroughly before updates
6. Use staged rollouts (Google Play)

### Analytics

Integrate analytics to track:
- User engagement
- Feature usage
- Conversion rates
- Retention metrics

Recommended tools:
- Google Analytics for Firebase
- Mixpanel
- Amplitude

## Troubleshooting

### iOS upload issues

**"Invalid binary"**:
- Check minimum iOS version
- Verify all required frameworks included

**"Missing required icon"**:
- Regenerate icons with flutter_launcher_icons

### Android upload issues

**"You uploaded a debuggable APK"**:
- Build with --release flag

**"Version code must be higher"**:
- Increment versionCode in build.gradle

**"APK not aligned"**:
- Use zipalign tool or build with Flutter CLI
