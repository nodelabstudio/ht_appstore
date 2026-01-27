# State Management Patterns

## Provider (Recommended for beginners)

### Setup

```yaml
dependencies:
  provider: ^6.1.1
```

### Basic usage

```dart
// 1. Create a model
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // Notify widgets to rebuild
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

// 2. Provide the model
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}

// 3. Consume the model
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Read value (rebuilds when changed)
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Text('Count: ${counter.count}');
              },
            ),
            // Or use context.watch
            Text('Count: ${context.watch<Counter>().count}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Call method without rebuild
        onPressed: () => context.read<Counter>().increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Multiple providers

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => Counter()),
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => CartModel()),
  ],
  child: MyApp(),
);
```

### Provider patterns

**Lazy loading** (default):
```dart
Provider(
  create: (_) => MyService(), // Created when first accessed
  child: MyApp(),
);
```

**Eager loading**:
```dart
Provider(
  create: (_) => MyService(),
  lazy: false, // Created immediately
  child: MyApp(),
);
```

**Proxy provider** (depends on another provider):
```dart
ProxyProvider<AuthService, UserRepository>(
  update: (context, auth, previous) => UserRepository(auth),
  child: MyApp(),
);
```

## Riverpod (Modern, type-safe)

### Setup

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
```

### Basic usage

```dart
// 1. Create providers
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

// 2. Wrap app with ProviderScope
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// 3. Consume with ConsumerWidget
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Scaffold(
      body: Center(
        child: Text('Count: $count'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Riverpod provider types

**StateProvider** (simple state):
```dart
final nameProvider = StateProvider<String>((ref) => 'John');

// Read and write
final name = ref.watch(nameProvider);
ref.read(nameProvider.notifier).state = 'Jane';
```

**FutureProvider** (async data):
```dart
final userProvider = FutureProvider<User>((ref) async {
  return await api.getUser();
});

// In widget
final userAsync = ref.watch(userProvider);
return userAsync.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

**StreamProvider** (real-time data):
```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return database.messagesStream();
});
```

## Bloc (Structured with events)

### Setup

```yaml
dependencies:
  flutter_bloc: ^8.1.3
```

### Basic usage

```dart
// 1. Define events
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}

// 2. Define states
class CounterState {
  final int count;
  CounterState(this.count);
}

// 3. Create bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    
    on<DecrementEvent>((event, emit) {
      emit(CounterState(state.count - 1));
    });
  }
}

// 4. Provide bloc
BlocProvider(
  create: (context) => CounterBloc(),
  child: MyApp(),
);

// 5. Use in widget
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          return Center(
            child: Text('Count: ${state.count}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CounterBloc>().add(IncrementEvent());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Bloc patterns

**BlocListener** (react to state changes):
```dart
BlocListener<CounterBloc, CounterState>(
  listener: (context, state) {
    if (state.count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  child: CounterWidget(),
);
```

**BlocConsumer** (build + listen):
```dart
BlocConsumer<CounterBloc, CounterState>(
  listener: (context, state) {
    // Side effects
  },
  builder: (context, state) {
    // UI
    return Text('Count: ${state.count}');
  },
);
```

## GetX (All-in-one)

### Setup

```yaml
dependencies:
  get: ^4.6.6
```

### Basic usage

```dart
// 1. Create controller
class CounterController extends GetxController {
  var count = 0.obs; // Observable

  void increment() => count++;
  void decrement() => count--;
}

// 2. Use in widget (no Provider needed!)
class CounterScreen extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('Count: ${controller.count}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### GetX navigation (bonus)

```dart
// No context needed!
Get.to(() => NextScreen());
Get.back();
Get.off(() => HomeScreen()); // Remove current
Get.offAll(() => LoginScreen()); // Clear stack

// Named routes
Get.toNamed('/details');

// With arguments
Get.toNamed('/user', arguments: {'id': 123});
```

## State management comparison

| Feature | Provider | Riverpod | Bloc | GetX |
|---------|----------|----------|------|------|
| Learning curve | Easy | Medium | Hard | Easy |
| Boilerplate | Low | Low | High | Very low |
| Type safety | Good | Excellent | Excellent | Moderate |
| Testing | Good | Excellent | Excellent | Good |
| Performance | Good | Excellent | Good | Good |
| Community | Large | Growing | Large | Large |
| Best for | Simple apps | All apps | Large apps | Rapid dev |

## Choosing the right solution

**Use Provider** if:
- Building your first Flutter app
- Want simple, straightforward state management
- Don't need advanced features

**Use Riverpod** if:
- Want compile-time safety
- Need excellent testing support
- Building medium to large apps
- Want modern Flutter patterns

**Use Bloc** if:
- Need clear separation of business logic
- Want explicit state transitions
- Building large, complex apps
- Team prefers structured patterns

**Use GetX** if:
- Want all-in-one solution (state + routing + dependencies)
- Need rapid development
- Building small to medium apps
- Want minimal boilerplate

## Best practices

1. **Keep business logic separate** from UI
2. **Use immutable state** when possible
3. **Test your state logic** independently
4. **Avoid excessive rebuilds** with proper selectors
5. **Document state transitions** for complex flows
6. **Use dependency injection** for services
7. **Handle loading and error states** explicitly
