# Troubleshooting Guide

## Common Build Issues

### "Unable to locate Android SDK"

**Solution:**
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add to ~/.bashrc or ~/.zshrc
```

### "CocoaPods not installed" (iOS)

**Solution:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### "Gradle build failed"

**Solutions:**
1. Clean build:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

2. Update Gradle wrapper (android/gradle/wrapper/gradle-wrapper.properties):
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

3. Increase heap size (android/gradle.properties):
```properties
org.gradle.jvmargs=-Xmx2048m
```

### "Execution failed for task ':app:processDebugResources'"

**Solution:**
Check for duplicate resources in android/app/src/main/res/

### "The plugin [plugin_name] requires a higher Android SDK version"

**Solution:**
Update android/app/build.gradle:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21 // Or higher
        targetSdkVersion 34
    }
}
```

## Runtime Issues

### "MissingPluginException"

**Causes:**
- Plugin not properly installed
- Hot restart needed instead of hot reload
- iOS pods not installed

**Solutions:**
1. Stop app completely and rebuild:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

2. For specific plugins:
```bash
flutter pub cache repair
```

### "setState() called after dispose()"

**Solution:**
```dart
// ❌ WRONG
void fetchData() async {
  final data = await api.getData();
  setState(() => _data = data); // May be called after dispose
}

// ✅ CORRECT
void fetchData() async {
  final data = await api.getData();
  if (mounted) {
    setState(() => _data = data);
  }
}
```

### "RenderBox was not laid out"

**Common causes:**
- Unbounded constraints (e.g., ListView inside Column)
- Missing Expanded/Flexible widgets

**Solutions:**
```dart
// ❌ WRONG
Column(
  children: [
    ListView(...), // Unbounded height
  ],
)

// ✅ CORRECT
Column(
  children: [
    Expanded(
      child: ListView(...),
    ),
  ],
)
```

### "Bottom overflowed by X pixels"

**Solutions:**
1. Wrap in SingleChildScrollView:
```dart
SingleChildScrollView(
  child: Column(
    children: [...],
  ),
)
```

2. Use Flexible/Expanded widgets
3. Add resizeToAvoidBottomInset:
```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  ...
)
```

## Performance Issues

### Slow list scrolling

**Solutions:**
1. Use ListView.builder instead of ListView:
```dart
// ❌ SLOW
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ FAST
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

2. Add const constructors:
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);
  ...
}
```

3. Use RepaintBoundary for complex widgets:
```dart
RepaintBoundary(
  child: ComplexWidget(),
)
```

### Excessive rebuilds

**Solution:**
Use const constructors and split widgets:
```dart
// ❌ Rebuilds everything
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        ExpensiveWidget(), // Rebuilds unnecessarily
      ],
    );
  }
}

// ✅ Only rebuilds what's needed
class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        const ExpensiveWidget(), // Doesn't rebuild
      ],
    );
  }
}
```

### Memory leaks

**Common causes:**
- Not disposing controllers
- Not canceling subscriptions

**Solutions:**
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _controller;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _subscription = stream.listen((data) {});
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ Dispose controller
    _subscription.cancel(); // ✅ Cancel subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

## Dependency Issues

### "Version solving failed"

**Solutions:**
1. Update dependencies:
```bash
flutter pub upgrade
```

2. Override specific versions in pubspec.yaml:
```yaml
dependency_overrides:
  package_name: ^version
```

3. Check for conflicting dependencies:
```bash
flutter pub deps
```

### "The current Dart SDK version is X"

**Solution:**
Update Flutter:
```bash
flutter upgrade
```

Or downgrade dependency requirements in pubspec.yaml

## iOS-Specific Issues

### "The operation couldn't be completed"

**Solution:**
Clean DerivedData:
```bash
cd ios
rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### "Unable to boot simulator"

**Solutions:**
```bash
# Reset simulator
xcrun simctl erase all

# Or create new simulator in Xcode
# Xcode > Window > Devices and Simulators
```

### "Code signing error"

**Solutions:**
1. Check signing settings in Xcode
2. Regenerate provisioning profiles
3. Clean and rebuild:
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

## Android-Specific Issues

### "Cleartext HTTP traffic not permitted"

**Solution:**
Add to android/app/src/main/AndroidManifest.xml:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

Or better, use HTTPS only.

### "Duplicate class found in modules"

**Solution:**
Check for duplicate dependencies in android/app/build.gradle:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-core:21.1.1'
    // Remove or comment out duplicates
}
```

### "Failed to resolve: [package_name]"

**Solutions:**
1. Add to android/build.gradle:
```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

2. Sync Gradle:
```bash
cd android
./gradlew clean
cd ..
flutter pub get
```

## Firebase Issues

### "Default FirebaseApp is not initialized"

**Solution:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize before runApp
  runApp(MyApp());
}
```

### "google-services.json not found"

**Solution:**
1. Download from Firebase Console
2. Place in android/app/
3. Add to android/app/build.gradle:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### "GoogleService-Info.plist not found" (iOS)

**Solution:**
1. Download from Firebase Console
2. Add to Xcode project (Runner folder)
3. Ensure it's in Copy Bundle Resources

## Network Issues

### "Connection timeout"

**Solutions:**
1. Increase timeout:
```dart
final dio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ),
);
```

2. Check network permissions in AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

3. For iOS, check Info.plist for App Transport Security settings

### "SocketException: OS Error: Connection refused"

**Causes:**
- Wrong API URL
- API server not running
- Network firewall blocking

**Solutions:**
- Verify API URL
- Use device IP instead of localhost
- Check firewall settings

## Testing Issues

### "Package import not found in test"

**Solution:**
Add to pubspec.yaml:
```yaml
dev_dependencies:
  test: ^1.24.0
  mockito: ^5.4.2
```

### "NoSuchMethodError in tests"

**Solution:**
Use proper mocks:
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MyService])
void main() {
  late MockMyService mockService;

  setUp(() {
    mockService = MockMyService();
  });

  test('my test', () {
    when(mockService.getData()).thenAnswer((_) async => 'data');
    // Test code
  });
}
```

## Debugging Tools

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance profiling

```dart
// In debug mode
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true; // Show layout bounds
  debugPaintPointersEnabled = true; // Show tap targets
  runApp(MyApp());
}
```

### Network inspection

Use Charles Proxy or Proxyman to inspect HTTP traffic

### Memory profiling

```bash
flutter run --profile
# Then use DevTools > Memory tab
```

## Getting Help

1. **Check Flutter documentation**: docs.flutter.dev
2. **Search GitHub issues**: github.com/flutter/flutter/issues
3. **Stack Overflow**: Use flutter tag
4. **Flutter community**: discord.gg/N7Yshp4
5. **Run flutter doctor**: Diagnose setup issues
   ```bash
   flutter doctor -v
   ```
