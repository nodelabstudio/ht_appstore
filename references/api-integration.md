# API Integration Guide

## HTTP Requests with Dio

### Setup

Add dependency:
```yaml
dependencies:
  dio: ^5.4.0
```

### Basic usage

```dart
class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // GET request
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}
```

### Interceptors for authentication

```dart
class ApiService {
  final Dio _dio = Dio();
  final SecureStorageService _storage = SecureStorageService();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to all requests
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 (unauthorized) - refresh token
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry request with new token
              final opts = error.requestOptions;
              final token = await _storage.getToken();
              opts.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    // Implement token refresh logic
    return false;
  }
}
```

### Logging interceptor

```dart
_dio.interceptors.add(
  LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ),
);
```

## REST API patterns

### Repository pattern

```dart
// Model
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Repository
class UserRepository {
  final ApiService _api = ApiService();

  Future<List<User>> getUsers() async {
    final response = await _api.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await _api.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> createUser(User user) async {
    final response = await _api.post('/users', user.toJson());
    return User.fromJson(response.data);
  }

  Future<User> updateUser(User user) async {
    final response = await _api.put('/users/${user.id}', user.toJson());
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    await _api.delete('/users/$id');
  }
}
```

### Using repositories with state management

```dart
// With Provider
class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _repository.getUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    try {
      final newUser = await _repository.createUser(user);
      _users.add(newUser);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

## GraphQL with Ferry

### Setup

```yaml
dependencies:
  ferry: ^0.15.0
  gql_http_link: ^1.0.1

dev_dependencies:
  ferry_generator: ^0.9.0
  build_runner: ^2.4.7
```

### Basic query

```graphql
# schema.graphql
query GetUsers {
  users {
    id
    name
    email
  }
}
```

Generate code:
```bash
flutter pub run build_runner build
```

Usage:
```dart
class GraphQLService {
  late final Client client;

  GraphQLService() {
    final link = HttpLink('https://api.example.com/graphql');
    final cache = Cache();
    client = Client(link: link, cache: cache);
  }

  Stream<OperationResponse<GGetUsersData, GGetUsersVars>> getUsers() {
    return client.request(GGetUsersReq());
  }
}
```

## WebSocket connections

```dart
class WebSocketService {
  WebSocket? _socket;
  final String _url = 'wss://api.example.com/ws';

  void connect() {
    _socket = WebSocket(_url);

    _socket!.on('connect', (_) {
      print('Connected');
    });

    _socket!.on('message', (data) {
      print('Received: $data');
      // Handle message
    });

    _socket!.on('disconnect', (_) {
      print('Disconnected');
    });

    _socket!.on('error', (error) {
      print('Error: $error');
    });
  }

  void send(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
```

## File upload

```dart
class FileUploadService {
  final Dio _dio = Dio();

  Future<Response> uploadFile(File file) async {
    String filename = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: filename,
      ),
    });

    return await _dio.post(
      'https://api.example.com/upload',
      data: formData,
      onSendProgress: (sent, total) {
        print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );
  }

  Future<Response> uploadMultipleFiles(List<File> files) async {
    Map<String, dynamic> fileMap = {};
    
    for (int i = 0; i < files.length; i++) {
      String filename = files[i].path.split('/').last;
      fileMap['file$i'] = await MultipartFile.fromFile(
        files[i].path,
        filename: filename,
      );
    }

    FormData formData = FormData.fromMap(fileMap);

    return await _dio.post(
      'https://api.example.com/upload-multiple',
      data: formData,
    );
  }
}
```

## Pagination

```dart
class PaginatedApiService {
  final ApiService _api = ApiService();
  List<User> _users = [];
  int _currentPage = 1;
  bool _hasMore = true;

  List<User> get users => _users;
  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (!_hasMore) return;

    try {
      final response = await _api.get('/users?page=$_currentPage&limit=20');
      final newUsers = (response.data['users'] as List)
          .map((json) => User.fromJson(json))
          .toList();

      _users.addAll(newUsers);
      _currentPage++;
      _hasMore = newUsers.length == 20; // Assuming 20 per page
    } catch (e) {
      print('Error loading more: $e');
    }
  }

  void reset() {
    _users.clear();
    _currentPage = 1;
    _hasMore = true;
  }
}

// In widget with ListView
ListView.builder(
  itemCount: users.length + (hasMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == users.length) {
      // Load more indicator
      service.loadMore();
      return CircularProgressIndicator();
    }
    return UserTile(user: users[index]);
  },
);
```

## Retry logic

```dart
class ApiServiceWithRetry {
  final Dio _dio = Dio();

  Future<Response> getWithRetry(
    String path, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await _dio.get(path);
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

## Caching responses

```dart
class CachedApiService {
  final ApiService _api = ApiService();
  final Map<String, CachedResponse> _cache = {};

  Future<Response> getCached(
    String path, {
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final cached = _cache[path];
    
    if (cached != null && !cached.isExpired) {
      return cached.response;
    }

    final response = await _api.get(path);
    _cache[path] = CachedResponse(
      response: response,
      expiresAt: DateTime.now().add(cacheDuration),
    );
    
    return response;
  }

  void clearCache() {
    _cache.clear();
  }
}

class CachedResponse {
  final Response response;
  final DateTime expiresAt;

  CachedResponse({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

## Best practices

1. **Use repositories** to separate API logic from UI
2. **Handle errors gracefully** with try-catch
3. **Implement retry logic** for transient failures
4. **Cache responses** when appropriate
5. **Use interceptors** for authentication
6. **Type-safe models** with fromJson/toJson
7. **Test API calls** with mocks
8. **Monitor performance** with logging
