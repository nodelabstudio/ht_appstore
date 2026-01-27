# Security Implementation Guide

## Secure storage

### Never use SharedPreferences for sensitive data

```dart
// ❌ WRONG - SharedPreferences is not encrypted
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('authToken', token); // Insecure!

// ✅ CORRECT - Use flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'authToken', value: token);
```

### Flutter Secure Storage setup

Add dependency:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

Usage:
```dart
class SecureStorageService {
  final storage = FlutterSecureStorage();

  // Store token
  Future<void> storeToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // Retrieve token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // Delete token
  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }

  // Delete all
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  // Store with encryption options (iOS)
  Future<void> storeSecure(String key, String value) async {
    await storage.write(
      key: key,
      value: value,
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }
}
```

## API security

### HTTPS only

```dart
// ❌ WRONG - HTTP is insecure
final response = await http.get(Uri.parse('http://api.example.com/data'));

// ✅ CORRECT - Always use HTTPS
final response = await http.get(Uri.parse('https://api.example.com/data'));
```

### Certificate pinning

Add dependency:
```yaml
dependencies:
  http_certificate_pinning: ^2.1.0
```

Implementation:
```dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class SecureHttpClient {
  static Future<void> init() async {
    List<String> allowedSHAFingerprints = [
      'YOUR_CERTIFICATE_SHA256_FINGERPRINT',
    ];

    await HttpCertificatePinning.init(
      allowedSHAFingerprints: allowedSHAFingerprints,
    );
  }

  static Future<String> secureGet(String url) async {
    try {
      return await HttpCertificatePinning.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Certificate pinning failed: $e');
      throw Exception('Connection not secure');
    }
  }
}
```

### Environment variables for API keys

Never hardcode API keys:
```dart
// ❌ WRONG - API key in code
const API_KEY = 'sk_live_1234567890abcdef';

// ✅ CORRECT - Use environment variables
// Create .env file (add to .gitignore)
// API_KEY=sk_live_1234567890abcdef
```

Use flutter_dotenv:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Load in `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// Use it
String apiKey = dotenv.env['API_KEY'] ?? '';
```

## Data encryption

### Encrypt sensitive local data

Add dependency:
```yaml
dependencies:
  encrypt: ^5.0.3
```

Implementation:
```dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  late final Key key;
  late final IV iv;
  late final Encrypter encrypter;

  EncryptionService() {
    // Generate key from password (in production, use secure key derivation)
    key = Key.fromLength(32);
    iv = IV.fromLength(16);
    encrypter = Encrypter(AES(key));
  }

  String encrypt(String plainText) {
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}

// Usage
final encryptionService = EncryptionService();
String sensitiveData = "credit card number";
String encrypted = encryptionService.encrypt(sensitiveData);
String decrypted = encryptionService.decrypt(encrypted);
```

### Encrypted database with SQLCipher

Add dependency:
```yaml
dependencies:
  sqflite_sqlcipher: ^2.2.1
```

Usage:
```dart
import 'package:sqflite_sqlcipher/sqflite.dart';

Future<Database> openEncryptedDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'encrypted_app.db');

  return await openDatabase(
    path,
    password: 'your-secure-password', // Store in secure storage!
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          name TEXT,
          email TEXT
        )
      ''');
    },
  );
}
```

## Input validation

### Form validation

```dart
class ValidationService {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain special character';
    }
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // Sanitize input
  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '') // Remove HTML tags
        .trim();
  }
}
```

### SQL injection prevention

```dart
// ❌ WRONG - Vulnerable to SQL injection
await db.rawQuery('SELECT * FROM users WHERE name = "$name"');

// ✅ CORRECT - Use parameterized queries
await db.query(
  'users',
  where: 'name = ?',
  whereArgs: [name],
);
```

## Authentication security

### Secure password storage

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordService {
  // Hash password with salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Generate random salt
  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(values);
  }

  // Verify password
  static bool verifyPassword(String password, String hash, String salt) {
    return hashPassword(password, salt) == hash;
  }
}
```

### Session management

```dart
class SessionManager {
  Timer? _inactivityTimer;
  static const Duration _timeout = Duration(minutes: 15);
  final VoidCallback onTimeout;

  SessionManager({required this.onTimeout});

  void startSession() {
    resetTimer();
  }

  void resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeout, () {
      onTimeout(); // Auto-logout
    });
  }

  void endSession() {
    _inactivityTimer?.cancel();
  }
}

// Usage
final sessionManager = SessionManager(
  onTimeout: () {
    // Logout user
    Navigator.pushReplacementNamed(context, '/login');
  },
);

// Reset on user activity
GestureDetector(
  onTap: () => sessionManager.resetTimer(),
  child: YourWidget(),
);
```

## Biometric authentication

Add dependency:
```yaml
dependencies:
  local_auth: ^2.1.7
```

Implementation:
```dart
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    return await auth.canCheckBiometrics && await auth.isDeviceSupported();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}
```

## Security checklist

### Pre-deployment security audit

- [ ] All API calls use HTTPS
- [ ] Sensitive data stored with flutter_secure_storage
- [ ] API keys in environment variables, not hardcoded
- [ ] Input validation on all user inputs
- [ ] SQL queries use parameterized statements
- [ ] Passwords hashed (never stored plain text)
- [ ] Certificate pinning implemented for sensitive APIs
- [ ] Session timeout implemented
- [ ] Biometric auth for sensitive operations
- [ ] Error messages don't expose system information
- [ ] Debug logging disabled in release builds
- [ ] ProGuard/R8 enabled for Android
- [ ] Jailbreak/root detection for sensitive apps
- [ ] Data encryption for sensitive local storage
- [ ] Secure random number generation for tokens
- [ ] Regular dependency updates for security patches

### Code obfuscation

For Android (build.gradle):
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
    }
}
```

For Flutter (build command):
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
flutter build ios --obfuscate --split-debug-info=build/ios/outputs/symbols
```

## Penetration testing resources

Before release:
1. Run static analysis: `flutter analyze`
2. Test with OWASP Mobile Security Testing Guide
3. Use tools like MobSF for automated security testing
4. Test for common vulnerabilities (OWASP Top 10 Mobile)
