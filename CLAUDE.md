# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter mobile application** called "math_ai" that helps users solve math problems using AI. The app uses Firebase for backend services, Google Gemini AI for math problem solving, and RevenueCat for subscription management.

## Architecture

The project follows **Clean Architecture** with a feature-based structure:

- **Data Layer**: Repositories that handle API calls and data persistence
- **Domain Layer**: Business logic, models, and repository interfaces
- **Presentation Layer**: UI components, BLoC state management, and pages

### Key Features
- **Account Management**: Sign in/up with Google/Apple, password reset
- **Math Problem Solving**: Camera capture + AI-powered math problem solving using Google Gemini
- **Collections**: Store and manage solved math problems via Firebase Firestore
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
- **Firestore**: Collections storage
- **Storage**: Image storage for math problems
- **AI**: Uses Firebase AI (Gemini) for math problem solving

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
Each feature follows the same structure:
- `data/repository/` - Data access implementations
- `domain/models/` and `domain/repository/` - Business logic and interfaces
- `presentation/` - UI components and state management

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