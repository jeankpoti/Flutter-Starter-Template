# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

You are an expert Flutter developer specializing in Clean Architecture with Feature-first organization and flutter_bloc for state management.

## Core Principles

### Clean Architecture
- Strictly adhere to the Clean Architecture layers: Presentation, Domain, and Data
- Follow the dependency rule: dependencies always point inward
- Domain layer contains entities, repositories (interfaces), and use cases
- Data layer implements repositories and contains data sources and models
- Presentation layer contains UI components, blocs, and view models
- Use proper abstractions with interfaces/abstract classes for each component
- Every feature should follow this layered architecture pattern

### Feature-First Organization
- Organize code by features instead of technical layers
- Each feature is a self-contained module with its own implementation of all layers
- Core or shared functionality goes in a separate 'core' directory
- Features should have minimal dependencies on other features
- Common directory structure for each feature:
  
```
lib/
├── core/                          # Shared/common code
│   ├── error/                     # Error handling, failures
│   ├── network/                   # Network utilities, interceptors
│   ├── utils/                     # Utility functions and extensions
│   └── widgets/                   # Reusable widgets
├── features/                      # All app features
│   ├── feature_a/                 # Single feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Remote and local data sources
│   │   │   ├── models/            # DTOs and data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business objects
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic use cases
│   │   └── presentation/          # Presentation layer
│   │       ├── bloc/              # Bloc/Cubit state management
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/           # Feature-specific widgets
│   └── feature_b/                 # Another feature with same structure
└── main.dart                      # Entry point
```

### flutter_bloc Implementation
- Use Bloc for complex event-driven logic and Cubit for simpler state management
- Implement properly typed Events and States for each Bloc
- Use Freezed for immutable state and union types
- Create granular, focused Blocs for specific feature segments
- Handle loading, error, and success states explicitly
- Avoid business logic in UI components
- Use BlocProvider for dependency injection of Blocs
- Implement BlocObserver for logging and debugging
- Separate event handling from UI logic

### Dependency Injection
- Use GetIt as a service locator for dependency injection
- Register dependencies by feature in separate files
- Implement lazy initialization where appropriate
- Use factories for transient objects and singletons for services
- Create proper abstractions that can be easily mocked for testing

## Coding Standards

### State Management
- States should be immutable using Freezed
- Use union types for state representation (initial, loading, success, error)
- Emit specific, typed error states with failure details
- Keep state classes small and focused
- Use copyWith for state transitions
- Handle side effects with BlocListener
- Prefer BlocBuilder with buildWhen for optimized rebuilds

### Error Handling
- Use custom Result<Success, Failure> classes for structured error handling
- Create custom Exception and Failure classes for domain-specific errors
- Implement proper error mapping between layers
- Centralize error handling strategies
- Provide user-friendly error messages
- Log errors for debugging and analytics

#### Result Pattern Error Handling
- Use Result pattern for better error control without complex functional programming
- Create a base Result class with Success and Failure cases
- Use sealed classes or enums for different error types
- Handle errors with pattern matching using switch expressions
- Example implementation for structured error handling:

```dart
// Define base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}

// Specific failure types
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred', String? code]) 
    : super(message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred', String? code]) 
    : super(message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred', String? code]) 
    : super(message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed', String? code]) 
    : super(message, code: code);
}

// Result class for structured error handling
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

// Extension methods for easier Result handling
extension ResultExtensions<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  Failure? get failure => isError ? (this as Error<T>).failure : null;
  
  // Pattern matching helper
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final failure) => error(failure),
    };
  }
  
  // Map success value
  Result<R> map<R>(R Function(T) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success(mapper(data)),
      Error<T>() => Error(failure!),
    };
  }
}
```

### Repository Pattern
- Repositories act as a single source of truth for data
- Implement caching strategies when appropriate
- Handle network connectivity issues gracefully
- Map data models to domain entities
- Create proper abstractions with well-defined method signatures
- Handle pagination and data fetching logic

### Testing Strategy
- Write unit tests for domain logic, repositories, and Blocs
- Implement integration tests for features
- Create widget tests for UI components
- Use mocks for dependencies with mockito or mocktail
- Follow Given-When-Then pattern for test structure
- Aim for high test coverage of domain and data layers

### Performance Considerations
- Use const constructors for immutable widgets
- Implement efficient list rendering with ListView.builder
- Minimize widget rebuilds with proper state management
- Use computation isolation for expensive operations with compute()
- Implement pagination for large data sets
- Cache network resources appropriately
- Profile and optimize render performance

### Code Quality
- Use lint rules with flutter_lints package
- Keep functions small and focused (under 30 lines)
- Apply SOLID principles throughout the codebase
- Use meaningful naming for classes, methods, and variables
- Document public APIs and complex logic
- Implement proper null safety
- Use value objects for domain-specific types

## Implementation Examples

### Use Case Implementation
```dart
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class GetUser implements UseCase<User, String> {
  final UserRepository repository;

  GetUser(this.repository);

  @override
  Future<Result<User>> call(String userId) async {
    return await repository.getUser(userId);
  }
}
```

### Repository Implementation
```dart
abstract class UserRepository {
  Future<Result<User>> getUser(String id);
  Future<Result<List<User>>> getUsers();
  Future<Result<void>> saveUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<User>> getUser(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteUser = await remoteDataSource.getUser(id);
        await localDataSource.cacheUser(remoteUser);
        return Success(remoteUser.toDomain());
      } else {
        final localUser = await localDataSource.getLastUser();
        return Success(localUser.toDomain());
      }
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  // Other implementations...
}
```

### Bloc Implementation
```dart
@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(User user) = _Loaded;
  const factory UserState.error(Failure failure) = _Error;
}

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.getUser(String id) = _GetUser;
  const factory UserEvent.refreshUser() = _RefreshUser;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUser getUser;
  String? currentUserId;

  UserBloc({required this.getUser}) : super(const UserState.initial()) {
    on<_GetUser>(_onGetUser);
    on<_RefreshUser>(_onRefreshUser);
  }

  Future<void> _onGetUser(_GetUser event, Emitter<UserState> emit) async {
    currentUserId = event.id;
    emit(const UserState.loading());
    final result = await getUser(event.id);
    result.when(
      success: (user) => emit(UserState.loaded(user)),
      error: (failure) => emit(UserState.error(failure)),
    );
  }

  Future<void> _onRefreshUser(_RefreshUser event, Emitter<UserState> emit) async {
    if (currentUserId != null) {
      emit(const UserState.loading());
      final result = await getUser(currentUserId!);
      result.when(
        success: (user) => emit(UserState.loaded(user)),
        error: (failure) => emit(UserState.error(failure)),
      );
    }
  }
}
```

### UI Implementation
```dart
class UserPage extends StatelessWidget {
  final String userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserBloc>()
        ..add(UserEvent.getUser(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          actions: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<UserBloc>().add(const UserEvent.refreshUser());
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return state.maybeWhen(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (user) => UserDetailsWidget(user: user),
              error: (failure) => ErrorWidget(failure: failure),
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}
```

### Dependency Registration
```dart
final getIt = GetIt.instance;

void initDependencies() {
  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  
  // Features - User
  // Data sources
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  
  // Repository
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
    networkInfo: getIt(),
  ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetUser(getIt()));
  
  // Bloc
  getIt.registerFactory(() => UserBloc(getUser: getIt()));
}
```

## Project Overview

This is a **Flutter mobile application** called "math_ai" that helps users solve math problems using AI. The app uses Firebase for backend services, Google Gemini AI for math problem solving, and RevenueCat for subscription management.

### Key Features
- **Account Management**: Sign in/up with Google/Apple, password reset
- **Math Problem Solving**: Camera capture + AI-powered math problem solving using Google Gemini
- **Collections**: Store and manage solved math problems via Firebase Firestore
- **Study Materials**: Upload and manage study materials with AI-powered quiz generation
- **Subscription**: Premium features managed through RevenueCat
- **Theme Management**: Dark/light mode with persistence

### Firebase Integration
- **Authentication**: Google Sign-In, Apple Sign-In, email/password
- **Firestore**: Collections and study materials storage
- **Storage**: Image storage for math problems and study materials
- **AI**: Uses Firebase AI (Gemini) for math problem solving and quiz generation

## Development Commands

### Build Commands
- `flutter run` - Run app in debug mode
- `flutter run --release` - Run app in release mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS
- `flutter build web` - Build for web

### Testing & Analysis
- `flutter test` - Run unit tests
- `flutter analyze` - Run Dart static analysis
- `flutter doctor` - Check development environment

### Dependency Management
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies
- `flutter clean` - Clean build artifacts

## Key Dependencies

### Core Flutter
- `flutter_bloc: ^8.1.6` - State management
- `go_router: ^15.1.1` - Navigation
- `shared_preferences: ^2.3.3` - Local storage
- `get_it` - Dependency injection
- `freezed` - Code generation for immutable classes
- `equatable` - Value equality

### Firebase
- `firebase_core: ^3.13.0` - Firebase initialization
- `firebase_auth: ^5.1.0` - Authentication
- `cloud_firestore: ^5.0.1` - Database
- `firebase_storage: ^12.4.5` - File storage
- `firebase_ai: ^2.0.0` - Gemini AI integration

### UI/UX
- `google_fonts: ^6.2.1` - Typography
- `flutter_markdown: ^0.7.7` - Markdown rendering
- `font_awesome_flutter: ^10.8.0` - Icons
- `persistent_bottom_nav_bar: ^6.2.1` - Navigation

### Third-party Services
- `purchases_flutter: ^8.8.1` - RevenueCat subscriptions
- `google_sign_in: ^6.2.2` - Google authentication
- `sign_in_with_apple: ^6.1.1` - Apple authentication

## Configuration Files

- `pubspec.yaml` - Flutter project configuration and dependencies
- `analysis_options.yaml` - Dart static analysis rules (uses flutter_lints)
- `firebase.json` - Firebase project configuration
- Platform GoogleService files in respective platform directories

## Development Notes

- Uses Firebase project ID: "math-homework-ai"
- App supports all platforms (mobile, web, desktop)
- RevenueCat integration for subscription management
- Theme persistence via SharedPreferences
- Navigation handled through go_router with named routes
- Image picking functionality for math problem capture

## Theme and Color Guidelines

The app supports both **dark mode** and **light mode** themes. When working with colors or styling:

### Color Usage Requirements
- **ALWAYS** use `Theme.of(context).colorScheme` for colors instead of hardcoded values
- **NEVER** use hardcoded colors like `Colors.white`, `Colors.black`, or specific color values
- Use semantic color properties that adapt automatically to theme changes

### Recommended Color Properties
- `Theme.of(context).colorScheme.primary` - Primary brand color
- `Theme.of(context).colorScheme.onPrimary` - Text/icons on primary color
- `Theme.of(context).colorScheme.surface` - Card/container backgrounds
- `Theme.of(context).colorScheme.onSurface` - Text on surface
- `Theme.of(context).colorScheme.background` - Screen background (deprecated, use surface)
- `Theme.of(context).colorScheme.secondary` - **ACCENT COLOR** - Use for highlights, icons, buttons, and interactive elements
- `Theme.of(context).colorScheme.onSecondary` - Text/icons on secondary/accent color
- `Theme.of(context).colorScheme.secondaryContainer` - Background containers with accent color
- `Theme.of(context).colorScheme.onSecondaryContainer` - Text on secondary container
- `Theme.of(context).colorScheme.tertiary` - Additional accent color for variety
- `Theme.of(context).colorScheme.error` - Error states
- `Theme.of(context).colorScheme.outline` - Borders and dividers

### Text Colors
- Use `Theme.of(context).textTheme` for text styling
- Common patterns:
  - `Theme.of(context).textTheme.bodyLarge?.color` - Primary text
  - `Theme.of(context).textTheme.bodyMedium?.color` - Secondary text
  - `Theme.of(context).colorScheme.onSurface.withOpacity(0.6)` - Disabled text

### Accent Color Usage
The **secondary color** serves as the main accent color throughout the app. Use it for:
- Interactive elements (buttons, switches, sliders)
- Icons and highlights
- Progress indicators and loading states
- Active/selected states
- Call-to-action elements
- Emphasis and visual hierarchy

### Color Combinations
- **Primary + Secondary**: Main brand color with accent highlights
- **Surface + Secondary**: Card backgrounds with accent elements
- **SecondaryContainer**: For subtle accent backgrounds
- Always use corresponding `on*` colors for text/icons on colored backgrounds

### Testing Both Themes
Always test UI changes in both light and dark modes to ensure proper contrast and readability.

Refer to official Flutter and flutter_bloc documentation for more detailed implementation guidelines.