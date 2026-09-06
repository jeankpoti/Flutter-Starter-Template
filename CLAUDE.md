# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter Starter Template** - a production-ready mobile application that demonstrates AI-powered features. The app uses Firebase for backend services, Google Gemini AI for core functionality, and RevenueCat for subscription management.

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

### lib/features/study/presentation/widgets/
Feature-specific reusable components organized by functionality:
- `review/` - Flashcard review components (refactored from large review page)
  - `flashcard_display_widget.dart` - Card display with flip animations and math rendering
  - `flashcard_completion_dialog.dart` - Review completion statistics dialog  
  - `flashcard_review_buttons.dart` - Spaced repetition rating buttons
- `deck/` - Flashcard deck management components (refactored from large deck page)
  - `deck_stats_header_widget.dart` - Statistics header with card counts
  - `flashcard_item_widget.dart` - Individual card display in lists
  - `card_edit_dialog_widget.dart` - Card creation/editing dialog

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

- Configure your own Firebase project via `flutterfire configure`
- App supports all platforms (mobile, web, desktop)
- RevenueCat integration for subscription management
- Theme persistence via SharedPreferences
- Navigation handled through go_router with named routes
- Image picking functionality for math problem capture

## Internationalization and Translation Guidelines

### 🌍 **MANDATORY TRANSLATION POLICY**

**NEVER use hardcoded strings in UI components.** All user-facing text MUST be translatable using the localization system.

### Supported Languages
- **English** (`en`) - Primary language
- **French** (`fr`) - Secondary language
- **Spanish** (`es`) - Tertiary language

### Translation File Locations
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_fr.arb` - French translations
- `lib/l10n/app_es.arb` - Spanish translations
- Generated files: `lib/l10n/app_localizations.dart` (auto-generated)

### **CRITICAL RULES - ALWAYS FOLLOW**

#### 1. **Never Use Hardcoded Strings**
```dart
// ❌ WRONG - Hardcoded string
Text('Save'),
AppBar(title: Text('Settings')),
SnackBar(content: Text('Success!')),

// ✅ CORRECT - Using translations
Text(AppLocalizations.of(context)!.save),
AppBar(title: Text(AppLocalizations.of(context)!.settings)),
SnackBar(content: Text(AppLocalizations.of(context)!.success)),
```

#### 2. **Add Translation Keys for All New Text**
When adding new UI text, ALWAYS add keys to all three `.arb` files:

**app_en.arb:**
```json
{
  "newFeatureTitle": "New Feature",
  "newFeatureDescription": "This is a description of the new feature"
}
```

**app_fr.arb:**
```json
{
  "newFeatureTitle": "Nouvelle fonctionnalité",  
  "newFeatureDescription": "Ceci est une description de la nouvelle fonctionnalité"
}
```

**app_es.arb:**
```json
{
  "newFeatureTitle": "Nueva Característica",  
  "newFeatureDescription": "Esta es una descripción de la nueva característica"
}
```

#### 3. **Regenerate Localizations After Changes**
After modifying `.arb` files, ALWAYS run:
```bash
flutter gen-l10n
```

#### 4. **Handle Parameters in Translations**
For dynamic content, use parameterized translations:

**app_en.arb:**
```json
{
  "welcomeUser": "Welcome, {username}!",
  "itemCount": "You have {count} items"
}
```

**Usage:**
```dart
Text(AppLocalizations.of(context)!.welcomeUser(user.name)),
Text(AppLocalizations.of(context)!.itemCount(items.length)),
```

#### 5. **Translation Key Naming Conventions**
- Use **camelCase** for keys
- Be descriptive and specific
- Group related keys with prefixes

**Examples:**
```json
{
  "mathLevel": "Math Level",
  "mathLevelDescription": "Choose your education level",
  "mathLevelElementary": "Elementary",
  "mathLevelHighSchool": "High School",
  "mathLevelCollege": "College",
  
  "quiz": "Quiz",
  "quizCompleted": "Quiz Completed!",
  "quizScore": "Score: {score}%",
  "quizRetake": "Retake Quiz"
}
```

### **Common Translation Patterns**

#### Dropdown/Picker Options
```dart
// ✅ Always translate dropdown options
SettingsDropdown<MathLevel>(
  getDisplayText: (level) => _getMathLevelDisplayName(context, level),
  // Helper function uses AppLocalizations
)
```

#### Success/Error Messages
```dart
// ✅ Always translate feedback messages
AppSnackBar.showSuccess(
  context,
  AppLocalizations.of(context)!.dataSaved,
);

AppSnackBar.showError(
  context,
  AppLocalizations.of(context)!.errorOccurred,
);
```

#### Button Labels
```dart
// ✅ Always translate button text
ElevatedButton(
  onPressed: onPressed,
  child: Text(AppLocalizations.of(context)!.save),
)
```

#### Form Labels and Hints
```dart
// ✅ Always translate form elements
TextFormField(
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context)!.email,
    hintText: AppLocalizations.of(context)!.enterEmail,
  ),
)
```

### **Quality Assurance**

#### Before Submitting Code:
1. **Search for hardcoded strings**: `grep -r '"[A-Z]' lib/` 
2. **Test all languages**: Switch between English, French, and Spanish in app
3. **Verify all new text is translated**: Check all three `.arb` files
4. **Run localization generation**: `flutter gen-l10n`
5. **No compilation errors**: `flutter analyze`

#### Translation Review Checklist:
- [ ] All user-visible text uses `AppLocalizations.of(context)!`
- [ ] Translation keys added to `app_en.arb`, `app_fr.arb`, and `app_es.arb`
- [ ] French and Spanish translations are accurate and natural
- [ ] Dynamic content uses parameterized translations
- [ ] `flutter gen-l10n` executed successfully
- [ ] App tested in all three languages (English, French, Spanish)
- [ ] No hardcoded strings remain

### **Existing Translation Keys**
Key categories already available:
- **Authentication**: signIn, signUp, email, password, etc.
- **Navigation**: solve, study, history, settings, etc.
- **Math Levels**: elementary, highSchool, college + descriptions
- **Languages**: englishLanguage, frenchLanguage, spanishLanguage
- **UI Actions**: save, cancel, delete, retry, loading, etc.
- **Messages**: success, error, somethingWentWrong, etc.

### **Tools and Commands**
```bash
# Generate localization files
flutter gen-l10n

# Find potential hardcoded strings
grep -r '"[A-Z]' lib/ --include="*.dart"

# Search for specific translation key usage
grep -r "AppLocalizations.of(context)" lib/

# Validate app in French and Spanish
# Change device language to French or Spanish and test the app
```

### **Resources**
- [Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)

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

### Equatable for State Management

**IMPORTANT**: All state classes and data models used in state management MUST extend `Equatable` to ensure proper state change detection by BlocBuilder/BlocListener.

#### Why Equatable is Required
- Without Equatable, BlocBuilder won't detect changes when model properties are updated
- Default object equality only checks references, not content
- UI won't update immediately when state changes occur

#### Implementation Pattern
```dart
import 'package:equatable/equatable.dart';

// State class example
class FeatureState extends Equatable {
  final List<Item> items;
  final bool isLoading;
  final String? errorMsg;

  const FeatureState({
    this.items = const [],
    this.isLoading = false,
    this.errorMsg,
  });

  @override
  List<Object?> get props => [items, isLoading, errorMsg];
}

// Model class example
class Item extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const Item({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, title, isCompleted];
}
```

#### Rules for Equatable Usage
1. **All state classes** must extend Equatable
2. **All model classes** used in state must extend Equatable
3. **Include all properties** in the props getter
4. **Use const constructors** where possible
5. **Don't override == and hashCode** when using Equatable

## Theme and Color Guidelines

The app supports both **dark mode** and **light mode** themes.

### Color Usage Requirements
- **ALWAYS** use `Theme.of(context).colorScheme` for colors instead of hardcoded values
- **NEVER** use hardcoded colors like `Colors.white`, `Colors.black`, or specific color values
- **NEVER** put black color on red background - this creates accessibility issues and poor readability
- **ALWAYS** use white color on red background for proper contrast and accessibility
- Use semantic color properties that adapt automatically to theme changes

### Text Color Consistency on Colored Backgrounds
When using colored backgrounds, **ALWAYS** explicitly specify the appropriate contrasting text color:

- **Error containers**: Use `onErrorContainer` for text on `errorContainer` backgrounds
- **Secondary backgrounds**: Use `onSecondary` for text on `secondary` backgrounds  
- **Primary backgrounds**: Use `onPrimary` for text on `primary` backgrounds
- **Surface containers**: Use `onSurfaceVariant` for text on `surfaceContainer` backgrounds

**Example patterns to follow:**
```dart
// For buttons with secondary background
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.secondary,
    foregroundColor: Theme.of(context).colorScheme.onSecondary,
  ),
  child: LabelLargeText(
    'Button Text',
    color: Theme.of(context).colorScheme.onSecondary, // Explicit color
  ),
)

// For error messages
SnackBar(
  backgroundColor: Theme.of(context).colorScheme.errorContainer,
  content: Text(
    'Error message',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onErrorContainer, // Explicit color
    ),
  ),
)
```

**Why this matters:** Custom text widgets may not automatically inherit button foreground colors, so explicit color specification ensures proper contrast and accessibility across all themes.

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

### File Size Limits
- **CRITICAL**: Every file must be **400 lines or less**
- **UI files are especially important** - break down large widgets into smaller components
- If a file exceeds 400 lines, immediately refactor it into multiple smaller files
- Extract reusable components into separate widget files
- Use composition over large monolithic widgets

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

### Component Refactoring Guidelines
When a UI file exceeds 400 lines, follow these refactoring patterns:
1. **Extract Display Components**: Create separate widgets for complex UI sections
2. **Extract Dialog Components**: Move dialog widgets to separate files with static show methods
3. **Extract Helper Widgets**: Create reusable components for repeated UI patterns
4. **Preserve Exact Functionality**: Ensure refactored components maintain identical behavior
5. **Maintain Design Consistency**: Keep exact styling, animations, and interactions
6. **Use Composition**: Replace large methods with smaller, composed widgets

**Example Refactoring Pattern**:
```dart
// Before: Large page file (800+ lines)
class LargePage extends StatefulWidget { ... }

// After: Main page (< 400 lines) + components
class LargePage extends StatefulWidget { 
  // Uses: HeaderWidget, ItemWidget, DialogWidget
}

// Separate component files (< 400 lines each)
class HeaderWidget extends StatelessWidget { ... }
class ItemWidget extends StatelessWidget { ... }  
class DialogWidget extends StatefulWidget {
  static void show(BuildContext context) { ... }
}
```

## Firebase Security Rules

The app implements comprehensive security rules to protect user data and ensure proper access control.

### Security Rules Architecture

#### Firestore Rules (`firestore.rules`)
The Firestore security rules follow these principles:
- **Authentication Required**: All operations require authenticated users
- **User Isolation**: Users can only access their own data
- **Field Validation**: Required fields are enforced at the database level
- **Type Safety**: Data types are validated (e.g., timestamps)

#### Key Security Patterns

1. **Authentication Check**
```javascript
function isAuthenticated() {
  return request.auth != null;
}
```

2. **Ownership Verification**
```javascript
function isOwner(resource) {
  return request.auth.uid == resource.data.userId;
}

function willOwnDocument() {
  return request.auth.uid == request.resource.data.userId;
}
```

3. **Required Fields Validation**
```javascript
allow create: if isAuthenticated()
  && willOwnDocument()
  && hasRequiredFields(['userId', 'createdAt', 'title'])
  && request.resource.data.createdAt is timestamp;
```

#### Collections and Their Rules

**Collections** (`/collections/{document}`)
- Required fields: `userId`, `createdAt`, `title`
- Users can only CRUD their own collections
- Timestamp validation on `createdAt`

**Quiz Results** (`/quizResults/{document}`)  
- Required fields: `userId`, `studyPlanId`, `questions`, `score`, `completedAt`
- Score must be between 0-100
- Questions must be a list
- Users can only access their own results

**Study Materials** (`/studyMaterials/{document}`)
- Required fields: `userId`, `createdAt`, `title`, `topics`
- Topics must be a list
- Users can only CRUD their own materials

**Study Plans** (`/studyPlans/{document}`)
- Required fields: `userId`, `createdAt`, `title`, `topics`, `totalTopics`
- Topics must be a list
- totalTopics must be a number
- Users can only CRUD their own plans

#### Storage Rules (`storage.rules`)
```javascript
// Images are stored under user-specific paths
match /images/{userId}/{allPaths=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId
    && request.resource.size < 10 * 1024 * 1024; // 10MB limit
}
```

### Cloud Functions Security

The app uses Cloud Functions for sensitive operations:

1. **User Existence Check** (`checkAppleUserExists`, `checkGoogleUserExists`)
   - Prevents creating duplicate accounts
   - Uses HTTPS onRequest pattern with CORS headers
   - Returns user existence status without exposing user data

Example implementation:
```javascript
exports.checkAppleUserExists = functions.https.onRequest(async (req, res) => {
  // CORS headers for web compatibility
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  
  // Validate request
  const { appleId } = req.body;
  if (!appleId) {
    return res.status(400).json({ error: 'Apple ID is required' });
  }
  
  // Check user existence
  const users = await admin.auth().getUsers([{ providerUid: appleId, providerId: 'apple.com' }]);
  res.json({ exists: users.users.length > 0 });
});
```

### Frontend File Size Validation

The frontend enforces the same file size limits as Firebase Storage:

```dart
// In ImageCaptureCubit
static const maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

Future<void> _validateFileSize(File file) async {
  final fileSize = await file.length();
  if (fileSize > maxFileSizeBytes) {
    final fileSizeMB = fileSize / (1024 * 1024);
    throw FileSizeException(
      'File size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of ${maxFileSizeBytes ~/ (1024 * 1024)}MB'
    );
  }
}
```

### Security Best Practices Implemented

1. **Email Verification**: Users must verify email before accessing the app
2. **Secure Authentication Flow**: Check user existence before creating new accounts
3. **Data Isolation**: Strict user-based data segregation
4. **Input Validation**: Both client and server-side validation
5. **File Size Limits**: Prevent abuse through large file uploads
6. **Type Safety**: Enforce correct data types in Firestore
7. **CORS Configuration**: Proper headers for web compatibility

### Important Security Considerations

- Never trust client-side validation alone - always validate on the server
- The security rules are the last line of defense - implement checks in the app code too
- Regularly review and test security rules with the Firebase Rules Simulator
- Monitor Firebase Authentication and Firestore usage for anomalies
- Keep Firebase Admin SDK usage minimal and secure

### Security Documentation

For detailed security implementation guides, see:
- **[FIREBASE_SECURITY_RULES.md](FIREBASE_SECURITY_RULES.md)** - Comprehensive security rules documentation
- **[SECURITY_RULES_IMPLEMENTATION.md](SECURITY_RULES_IMPLEMENTATION.md)** - Implementation summary and status
- **[FIRESTORE_MIGRATION_GUIDE.md](FIRESTORE_MIGRATION_GUIDE.md)** - Guide for migrating document structures

## Essential Resources
- **[Flutter Documentation](https://docs.flutter.dev/)** - Official Flutter documentation
- **[Material Design 3](https://m3.material.io/)** - Design system guidelines
- **[Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)** - Widget documentation
- **[Pub.dev](https://pub.dev/)** - Dart and Flutter package repository