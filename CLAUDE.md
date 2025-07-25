# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter mobile application** called "math_ai" that helps users solve math problems using AI. The app uses Firebase for backend services, Google Gemini AI for math problem solving, and RevenueCat for subscription management.

## Architecture

The project follows a **feature-based structure** with traditional Flutter architecture:

- **Data Layer**: Repositories and services that handle API calls and data persistence
- **Domain Layer**: Models and repository interfaces
- **Presentation Layer**: UI components, Cubit state management, and pages

### Key Features
- **Account Management**: Sign in/up with Google/Apple, password reset
- **Math Problem Solving**: Camera capture + AI-powered math problem solving using Google Gemini
- **Collections**: Store and manage solved math problems via Firebase Firestore
- **Study Materials**: Upload and manage study materials with AI-powered quiz generation
- **Subscription**: Premium features managed through RevenueCat
- **Theme Management**: Dark/light mode with persistence

### State Management
Uses **flutter_bloc** with separate Cubits for each feature:
- `AccountCubit`: Authentication state
- `SolveMathCubit`: Math solving functionality
- `FirebaseCollectionCubit`: Collections management
- `SubscriptionCubit`: Subscription state
- `ThemeCubit`: Theme management

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

## File Structure Notes

### lib/features/
Each feature follows a consistent structure:
- `data/repository/` - Data access implementations and services
- `domain/models/` and `domain/repository/` - Business logic models and interfaces
- `presentation/` - UI components, Cubit state management, and pages

### lib/common_widgets/
Reusable UI components following consistent naming:
- `*_widget.dart` - All custom widgets end with "widget"
- Organized by component type (buttons, text, form fields, etc.)

### Platform-specific Files
- `android/` - Android configuration and native code
- `ios/` - iOS configuration and native code  
- `web/` - Web platform assets
- `macos/`, `windows/`, `linux/` - Desktop platform support

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

## Cubit State Management Pattern

The app uses **flutter_bloc** with Cubit pattern for state management:

### Cubit Structure
Each feature has its own Cubit with corresponding state classes:
- `FeatureCubit` - Business logic and state management
- `FeatureState` - State class with properties like `isLoading`, `errorMsg`, etc.

### Common State Properties
- `isLoading` - Boolean indicating loading state
- `isSuccess` - Boolean indicating successful operations
- `errorMsg` - String containing error messages
- Feature-specific data properties

### Usage Pattern
```dart
// In presentation layer
BlocBuilder<FeatureCubit, FeatureState>(
  builder: (context, state) {
    if (state.isLoading) return LoadingWidget();
    if (state.errorMsg != null) return ErrorWidget(state.errorMsg!);
    return SuccessWidget(state.data);
  },
)

BlocListener<FeatureCubit, FeatureState>(
  listener: (context, state) {
    if (state.errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMsg!)),
      );
    }
  },
  child: YourWidget(),
)
```

## Theme and Color Guidelines

The app supports both **dark mode** and **light mode** themes.

### Color Usage Requirements
- **ALWAYS** use `Theme.of(context).colorScheme` for colors instead of hardcoded values
- **NEVER** use hardcoded colors like `Colors.white`, `Colors.black`, or specific color values
- Use semantic color properties that adapt automatically to theme changes

### Essential Color Properties
- `Theme.of(context).colorScheme.primary` - Primary brand color
- `Theme.of(context).colorScheme.onPrimary` - Text/icons on primary color
- `Theme.of(context).colorScheme.surface` - Card/container backgrounds
- `Theme.of(context).colorScheme.onSurface` - Text on surface
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
  - `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)` - Disabled text

### Accent Color Usage
The **secondary color** serves as the main accent color throughout the app. Use it for:
- Interactive elements (buttons, switches, sliders)
- Icons and highlights
- Progress indicators and loading states
- Active/selected states
- Call-to-action elements
- Emphasis and visual hierarchy

### Testing Both Themes
Always test UI changes in both light and dark modes to ensure proper contrast and readability.

## Modern UI Design Guidelines

### Design Principles
Follow Material Design 3 principles:
- Use Material Design 3 as the foundation
- Leverage dynamic color schemes and adaptive layouts
- Implement proper elevation and surface treatments
- Use consistent rounded corners and modern shapes

### Visual Hierarchy
- **Primary Elements**: Use primary colors and larger typography for key actions and titles
- **Secondary Elements**: Use secondary colors and medium typography for supporting content
- **Tertiary Elements**: Use muted colors and smaller typography for less important information

### Spacing System
```dart
// Base spacing unit: 8dp
const double _spacing1 = 4.0;   // 0.5x - Micro spacing
const double _spacing2 = 8.0;   // 1x - Base unit
const double _spacing3 = 12.0;  // 1.5x - Small spacing
const double _spacing4 = 16.0;  // 2x - Default spacing
const double _spacing5 = 20.0;  // 2.5x - Medium spacing
const double _spacing6 = 24.0;  // 3x - Large spacing
const double _spacing8 = 32.0;  // 4x - Extra large spacing
const double _spacing10 = 40.0; // 5x - Section spacing
const double _spacing12 = 48.0; // 6x - Page spacing
const double _spacing16 = 64.0; // 8x - Major sections
```

### Layout Patterns
- **Margins**: Use 16dp as standard screen margins
- **Padding**: Use 16dp for card/container internal padding
- **Element Spacing**: Use 8dp between related elements, 16dp between sections
- **Buttons**: Use 48dp minimum touch target, 16dp internal padding

### Typography System
```dart
// Headlines - Use for main titles and section headers
Theme.of(context).textTheme.displayLarge   // 64px - Hero titles
Theme.of(context).textTheme.headlineLarge  // 32px - Page titles
Theme.of(context).textTheme.headlineMedium // 28px - Card titles
Theme.of(context).textTheme.headlineSmall  // 24px - Subsection headers

// Body - Use for main content and descriptions
Theme.of(context).textTheme.bodyLarge      // 16px - Main body text
Theme.of(context).textTheme.bodyMedium     // 14px - Secondary text
Theme.of(context).textTheme.bodySmall      // 12px - Supporting text

// Labels - Use for buttons, tabs, and form labels
Theme.of(context).textTheme.labelLarge     // 14px - Button text
Theme.of(context).textTheme.labelMedium    // 12px - Tab labels
Theme.of(context).textTheme.labelSmall     // 11px - Form labels
```

### Component Design Patterns

#### Cards and Containers
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 8.0,
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: YourContent(),
  ),
)
```

#### Buttons
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),
  onPressed: onPressed,
  child: Text('Primary Action'),
)
```

#### Input Fields
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    contentPadding: const EdgeInsets.all(16.0),
  ),
)
```

### Accessibility Guidelines
- **Minimum 48dp touch targets** for all interactive elements
- **Never rely on color alone** to convey information
- Provide alternative indicators (icons, text, patterns)
- Use meaningful text labels and semantic widgets
- Test with screen readers and various accessibility settings

### Animation Guidelines
- **Duration**: 200-300ms for micro-interactions, 300-500ms for transitions
- **Easing**: Use natural curves (Curves.easeInOut, Curves.fastOutSlowIn)
- **Purpose**: Every animation should have a clear purpose
- **Performance**: Prefer Transform-based animations over layout changes

## DRY Principles and Reusable Widgets

### When to Create Reusable Widgets
Create a reusable widget when:
- The same UI pattern appears 3+ times across the app
- A component has configurable properties that could benefit other screens
- Complex UI logic can be encapsulated and reused
- A widget represents a common design pattern

### Widget Organization
```
lib/common_widgets/
├── layout/          # Cards, spacing, headers
├── interactive/     # Buttons, text fields, chips
├── state/          # Loading, error, empty states
├── display/        # Info cards, badges, indicators
└── navigation/     # Tab bars, breadcrumbs
```

### Naming Conventions
- **File names**: `component_name_widget.dart`
- **Class names**: `ComponentNameWidget`
- **Use descriptive prefixes**: `Modern`, `Custom`, `App`

### Best Practices
1. **Design for Flexibility**: Make widgets generic and configurable
2. **Provide Sensible Defaults**: Include reasonable default values
3. **Handle Edge Cases**: Account for null values and error states
4. **Make Widgets Testable**: Use keys and proper semantics
5. **Document Thoroughly**: Include usage examples and descriptions

## Feature-Specific Notes

### Account Feature
- Uses `AccountCubit` with traditional state management
- Supports Google, Apple, and email/password authentication
- State includes `isLoading`, `isSuccess`, `errorMsg` properties

### Solve Math Feature
- Uses `SolveMathCubit` for math problem solving
- Integrates with Firebase AI (Gemini) for problem analysis
- `FirebaseCollectionCubit` manages saved problems
- Supports both image and text input

### Study Feature
- Uses traditional repository pattern with services
- `StudyPlanService` and `QuizService` for business logic
- Models include `StudyMaterial`, `StudyPlan`, and `Quiz`

### Subscription Feature
- Uses `SubscriptionCubit` with RevenueCat integration
- Manages premium feature access
- Handles subscription status and purchases

## Development Guidelines

### Architecture Guidelines
- Follow the existing Cubit pattern for new features
- Use the established repository pattern for data access
- Maintain consistent file naming conventions
- Follow Flutter best practices for state management

### UI/UX Development Guidelines
- **Always prioritize accessibility** - ensure all UI elements meet WCAG guidelines
- **Use the design system** - follow established color, typography, and spacing guidelines
- **Test comprehensively** - verify UI in both light/dark modes and various screen sizes
- **Implement meaningful animations** - use animations purposefully for feedback and guidance
- **Design mobile-first** - create responsive layouts that work across all device sizes
- **Maintain visual consistency** - use established patterns and components
- **Follow Material Design 3** - leverage modern design principles and patterns

### Code Quality Standards
- Write clean, maintainable, and well-documented code
- Follow Dart and Flutter best practices and conventions
- Use meaningful variable and function names
- Implement proper error handling and validation
- Write unit tests for business logic and widget tests for UI components
- Keep functions and widgets focused and single-purpose
- Use const constructors where possible for performance
- Avoid deep widget nesting - break complex widgets into smaller components

## Essential Resources
- **[Flutter Documentation](https://docs.flutter.dev/)** - Official Flutter documentation
- **[Material Design 3](https://m3.material.io/)** - Design system guidelines
- **[Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)** - Widget documentation
- **[Pub.dev](https://pub.dev/)** - Dart and Flutter package repository