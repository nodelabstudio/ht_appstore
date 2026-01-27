# Authentication Implementation Guide

## Firebase Authentication

### Setup

Add dependencies to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^5.0.0
```

Initialize Firebase in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### Email/Password Authentication

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  // Sign in
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### Google Sign-In

```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print('Google sign in error: $e');
    return null;
  }
}
```

### Apple Sign-In (iOS only)

```dart
Future<UserCredential?> signInWithApple() async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print('Apple sign in error: $e');
    return null;
  }
}
```

## Custom Backend Authentication (JWT)

### Setup with secure storage

Add dependencies:
```yaml
dependencies:
  http: ^1.1.2
  flutter_secure_storage: ^9.0.0
```

### Auth service with JWT

```dart
class CustomAuthService {
  final storage = FlutterSecureStorage();
  static const String TOKEN_KEY = 'auth_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String API_URL = 'https://your-api.com';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: TOKEN_KEY, value: data['token']);
        await storage.write(key: REFRESH_TOKEN_KEY, value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: TOKEN_KEY);
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: TOKEN_KEY, value: data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: TOKEN_KEY);
    await storage.delete(key: REFRESH_TOKEN_KEY);
  }
}
```

### HTTP interceptor for automatic token refresh

```dart
class AuthenticatedClient {
  final http.Client _client = http.Client();
  final CustomAuthService _authService = CustomAuthService();

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _request(() => _client.get(url, headers: await _getHeaders(headers)));
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _request(() => _client.post(url, headers: await _getHeaders(headers), body: body));
  }

  Future<http.Response> _request(Future<http.Response> Function() request) async {
    var response = await request();
    
    if (response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        response = await request();
      }
    }
    
    return response;
  }

  Future<Map<String, String>> _getHeaders(Map<String, String>? headers) async {
    final token = await _authService.getToken();
    return {
      ...?headers,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
```

## Auth UI patterns

### Login screen with validation

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Use your auth service here
      final authService = AuthService();
      final result = await authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
    }
  }
}
```

## Best practices

1. **Never store passwords**: Always use secure authentication services
2. **Validate inputs**: Check email format, password strength
3. **Handle errors gracefully**: Show user-friendly error messages
4. **Implement biometric auth**: Use `local_auth` package for fingerprint/face ID
5. **Session management**: Auto-logout after inactivity
6. **Multi-factor authentication**: Add SMS or email verification for sensitive apps
