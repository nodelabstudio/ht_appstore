# Database Implementation Guide

## Firebase Firestore

### Setup

Add dependency:
```yaml
dependencies:
  cloud_firestore: ^4.14.0
```

### Basic operations

```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create
  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  // Read single document
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Read collection
  Future<List<Map<String, dynamic>>> getUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Update
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Delete
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Real-time updates
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _db.collection('users').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  // Queries
  Future<List<Map<String, dynamic>>> getUsersByAge(int minAge) async {
    final snapshot = await _db
        .collection('users')
        .where('age', isGreaterThanOrEqualTo: minAge)
        .orderBy('age')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Batch operations
  Future<void> batchUpdate(List<String> userIds) async {
    final batch = _db.batch();
    for (var id in userIds) {
      batch.update(
        _db.collection('users').doc(id),
        {'lastUpdated': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
  }
}
```

### Data modeling best practices

```dart
// Use subcollections for one-to-many relationships
// users/{userId}/posts/{postId}

// Store references for many-to-many
class Post {
  final String id;
  final String title;
  final List<String> authorIds; // References to user documents
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.authorIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authorIds': authorIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      title: map['title'],
      authorIds: List<String>.from(map['authorIds']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

## Supabase (PostgreSQL)

### Setup

Add dependencies:
```yaml
dependencies:
  supabase_flutter: ^2.1.0
```

Initialize in `main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

### Basic operations

```dart
class SupabaseService {
  final supabase = Supabase.instance.client;

  // Create
  Future<void> createUser(Map<String, dynamic> data) async {
    await supabase.from('users').insert(data);
  }

  // Read
  Future<List<Map<String, dynamic>>> getUsers() async {
    return await supabase.from('users').select();
  }

  // Update
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await supabase.from('users').update(data).eq('id', id);
  }

  // Delete
  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }

  // Real-time subscriptions
  void subscribeToUsers(Function(List<Map<String, dynamic>>) onData) {
    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .listen((data) => onData(data));
  }

  // Complex queries
  Future<List<Map<String, dynamic>>> getUsersWithPosts() async {
    return await supabase
        .from('users')
        .select('*, posts(*)')
        .gte('age', 18)
        .order('created_at', ascending: false)
        .limit(10);
  }

  // RPC (stored procedures)
  Future<dynamic> searchUsers(String query) async {
    return await supabase.rpc('search_users', params: {'query': query});
  }
}
```

## SQLite (Local database)

### Setup

Add dependency:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

### Database helper

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        age INTEGER,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD operations
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Join queries
  Future<List<Map<String, dynamic>>> getUsersWithPosts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT users.*, posts.title as postTitle, posts.content as postContent
      FROM users
      LEFT JOIN posts ON users.id = posts.userId
      ORDER BY users.createdAt DESC
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
```

### Model class with SQLite

```dart
class User {
  final int? id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
```

## Hive (Fast local storage)

### Setup

Add dependencies:
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### Basic usage

```dart
import 'package:hive_flutter/hive_flutter.dart';

// Initialize Hive
await Hive.initFlutter();

// Open box
var box = await Hive.openBox('myBox');

// Store data
box.put('name', 'John');
box.put('age', 30);

// Read data
var name = box.get('name');
var age = box.get('age', defaultValue: 0);

// Delete data
box.delete('name');

// Close box
await box.close();
```

### Type adapters for custom objects

```dart
import 'package:hive/hive.dart';

part 'user.g.dart'; // Generated file

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String email;

  User({required this.name, required this.age, required this.email});
}

// Register adapter
Hive.registerAdapter(UserAdapter());

// Use it
var box = await Hive.openBox<User>('users');
box.add(User(name: 'John', age: 30, email: 'john@example.com'));
```

## Database selection guide

**Firebase Firestore**: Best for real-time apps, social features, easy backend setup
**Supabase**: Best for complex relational data, SQL queries, open-source preference
**SQLite**: Best for offline-first apps, no internet dependency, full control
**Hive**: Best for fast local storage, simple data structures, high performance

## Best practices

1. **Use transactions** for atomic operations
2. **Index frequently queried fields**
3. **Paginate large datasets**
4. **Cache data locally** for offline support
5. **Sanitize inputs** to prevent SQL injection
6. **Batch operations** for better performance
7. **Use streams** for real-time updates efficiently
