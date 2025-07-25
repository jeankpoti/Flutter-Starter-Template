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
    if (state.isLoading) {
      return LoadingWidget();
    }
    if (state.errorMsg != null) {
      return ErrorWidget(state.errorMsg!);
    }
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
  - `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)` - Disabled text

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

## Modern UI Design Guidelines

### Design Principles
Follow these principles to create a modern, professional, and appealing UI:

#### Material Design 3 (Material You)
- Use Material Design 3 principles as the foundation
- Leverage dynamic color schemes and adaptive layouts
- Implement proper elevation and surface treatments
- Use consistent rounded corners and modern shapes

#### Visual Hierarchy
- **Primary Elements**: Use primary colors and larger typography for key actions and titles
- **Secondary Elements**: Use secondary colors and medium typography for supporting content
- **Tertiary Elements**: Use muted colors and smaller typography for less important information
- **Information Architecture**: Organize content logically with clear navigation paths

#### Consistency
- Maintain consistent spacing, colors, and typography throughout the app
- Use established patterns for similar interactions
- Create reusable components for common UI elements

### Advanced Color System

#### Color Roles and Usage
```dart
// Status Colors
Theme.of(context).colorScheme.error        // Error states, destructive actions
Theme.of(context).colorScheme.onError      // Text/icons on error color
Theme.of(context).colorScheme.errorContainer // Error backgrounds
Theme.of(context).colorScheme.onErrorContainer // Text on error containers

// Success/Warning Colors (use with caution, prefer semantic containers)
Theme.of(context).colorScheme.tertiary     // Success states, positive actions
Theme.of(context).colorScheme.onTertiary   // Text/icons on tertiary color
Theme.of(context).colorScheme.tertiaryContainer // Success backgrounds

// Surface Variations
Theme.of(context).colorScheme.surface              // Default surfaces
Theme.of(context).colorScheme.surfaceContainerLowest  // Lowest elevation
Theme.of(context).colorScheme.surfaceContainerLow     // Low elevation
Theme.of(context).colorScheme.surfaceContainer        // Default elevation
Theme.of(context).colorScheme.surfaceContainerHigh    // High elevation
Theme.of(context).colorScheme.surfaceContainerHighest // Highest elevation
```

#### Color Contrast Requirements
- **Minimum contrast ratio 4.5:1** for normal text
- **Minimum contrast ratio 3:1** for large text (18pt+ or 14pt+ bold)
- **Minimum contrast ratio 3:1** for interactive elements
- Use contrast checking tools to verify accessibility

#### Color Psychology and Usage
- **Primary**: Brand identity, main actions, key elements
- **Secondary**: Accent elements, highlights, secondary actions
- **Tertiary**: Success states, positive feedback, special elements
- **Error**: Destructive actions, error states, warnings
- **Neutral**: Text, dividers, backgrounds, supporting elements

### Typography System

#### Text Styles Hierarchy
```dart
// Headlines - Use for main titles and section headers
Theme.of(context).textTheme.displayLarge   // 64px - Hero titles
Theme.of(context).textTheme.displayMedium  // 45px - Large headers
Theme.of(context).textTheme.displaySmall   // 36px - Section headers

Theme.of(context).textTheme.headlineLarge  // 32px - Page titles
Theme.of(context).textTheme.headlineMedium // 28px - Card titles
Theme.of(context).textTheme.headlineSmall  // 24px - Subsection headers

// Titles - Use for component titles and important text
Theme.of(context).textTheme.titleLarge     // 22px - List item titles
Theme.of(context).textTheme.titleMedium    // 16px - Card subtitles
Theme.of(context).textTheme.titleSmall     // 14px - Overlines, captions

// Body - Use for main content and descriptions
Theme.of(context).textTheme.bodyLarge      // 16px - Main body text
Theme.of(context).textTheme.bodyMedium     // 14px - Secondary text
Theme.of(context).textTheme.bodySmall      // 12px - Supporting text

// Labels - Use for buttons, tabs, and form labels
Theme.of(context).textTheme.labelLarge     // 14px - Button text
Theme.of(context).textTheme.labelMedium    // 12px - Tab labels
Theme.of(context).textTheme.labelSmall     // 11px - Form labels
```

#### Typography Best Practices
- **Line Height**: Use 1.2-1.6 line height for optimal readability
- **Letter Spacing**: Follow Material Design spacing guidelines
- **Font Weights**: Use font weights meaningfully (400 for body, 500-600 for emphasis, 700+ for headers)
- **Text Color**: Ensure sufficient contrast with background colors
- **Hierarchy**: Create clear visual hierarchy with size, weight, and color variations

### Spacing and Layout System

#### Consistent Spacing Scale
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

// Usage Examples
EdgeInsets.all(_spacing4)                    // 16dp all around
EdgeInsets.symmetric(horizontal: _spacing4)  // 16dp left/right
EdgeInsets.only(top: _spacing6, bottom: _spacing8) // Varied spacing
```

#### Layout Patterns
- **Margins**: Use 16dp as standard screen margins
- **Padding**: Use 16dp for card/container internal padding
- **Element Spacing**: Use 8dp between related elements, 16dp between sections
- **List Items**: Use 16dp vertical padding, 16dp horizontal margins
- **Buttons**: Use 48dp minimum touch target, 16dp internal padding

### Component Design Patterns

#### Cards and Containers
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12.0), // Consistent rounded corners
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 8.0,
        spreadRadius: 0,
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: YourContent(),
  ),
)
```

#### Buttons and Interactive Elements
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    minimumSize: const Size(double.infinity, 48), // Full width, 48dp height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 2,
  ),
  onPressed: onPressed,
  child: Text('Primary Action', style: Theme.of(context).textTheme.labelLarge),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.primary,
    side: BorderSide(color: Theme.of(context).colorScheme.outline),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
  onPressed: onPressed,
  child: Text('Secondary Action', style: Theme.of(context).textTheme.labelLarge),
)
```

#### Input Fields
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint text',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2.0,
      ),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    contentPadding: const EdgeInsets.all(16.0),
  ),
  style: Theme.of(context).textTheme.bodyLarge,
)
```

### Accessibility Guidelines

#### Color Accessibility
- **Never rely on color alone** to convey information
- Provide alternative indicators (icons, text, patterns)
- Ensure sufficient color contrast ratios
- Test with color blindness simulators

#### Touch Targets
- **Minimum 48dp touch targets** for all interactive elements
- Provide adequate spacing between touch targets (8dp minimum)
- Use visual feedback for touch interactions

#### Screen Reader Support
```dart
Semantics(
  label: 'Descriptive label for screen readers',
  hint: 'Additional context or instructions',
  button: true, // Identifies as button
  enabled: isEnabled,
  child: YourWidget(),
)

// For decorative elements
ExcludeSemantics(
  child: DecorativeIcon(),
)
```

#### Text Accessibility
- Use meaningful text labels and descriptions
- Ensure text is resizable up to 200% without loss of functionality
- Provide alternative text for images and icons
- Use clear, simple language

### Animation and Motion

#### Animation Principles
- **Duration**: Use appropriate timing (200-300ms for micro-interactions, 300-500ms for transitions)
- **Easing**: Use natural easing curves (Curves.easeInOut, Curves.fastOutSlowIn)
- **Purpose**: Every animation should have a clear purpose (feedback, guidance, delight)
- **Performance**: Prefer Transform-based animations over layout changes

#### Common Animation Patterns
```dart
// Fade transitions
AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: YourWidget(),
)

// Scale animations for emphasis
AnimatedScale(
  duration: const Duration(milliseconds: 200),
  scale: isPressed ? 0.95 : 1.0,
  child: YourButton(),
)

// Smooth container changes
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  color: isSelected ? selectedColor : defaultColor,
  child: YourContent(),
)
```

### Responsive Design

#### Breakpoints
```dart
class Responsive {
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1024;
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1024;
}
```

#### Adaptive Layouts
- Use flexible layouts that adapt to different screen sizes
- Implement appropriate navigation patterns for each form factor
- Adjust text sizes and spacing for different screen densities
- Consider landscape orientation and provide appropriate layouts

### Loading and Error States

#### Loading States
```dart
// Skeleton loading
Container(
  width: double.infinity,
  height: 20.0,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(4.0),
  ),
)

// Shimmer effect for enhanced loading states
// Progress indicators with meaningful text
Column(
  children: [
    CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
    ),
    const SizedBox(height: 16),
    Text(
      'Loading your data...',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  ],
)
```

#### Error States
```dart
// Error message with action
Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(12.0),
  ),
  child: Column(
    children: [
      Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: 48.0,
      ),
      const SizedBox(height: 16),
      Text(
        'Something went wrong',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Please try again or contact support if the problem persists.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: onRetry,
        child: const Text('Try Again'),
      ),
    ],
  ),
)
```

### UI Testing and Quality Assurance

#### Visual Testing Checklist
- [ ] Test in both light and dark themes
- [ ] Verify color contrast ratios meet WCAG guidelines
- [ ] Test with different font sizes (accessibility settings)
- [ ] Check layouts on different screen sizes
- [ ] Verify touch targets are appropriately sized
- [ ] Test with screen readers enabled
- [ ] Validate loading and error states
- [ ] Check animation performance on lower-end devices

#### Tools and Resources
- **Flutter Inspector**: For debugging layout issues
- **Color Contrast Analyzers**: For accessibility testing
- **Device Simulators**: For testing different screen sizes
- **Screen Reader Testing**: For accessibility validation

## Official Documentation and Resources

### Essential Flutter Resources
- **[Flutter Documentation](https://docs.flutter.dev/)** - Official Flutter documentation with guides, API reference, and best practices
- **[Pub.dev](https://pub.dev/)** - Official Dart and Flutter package repository
- **[Material Design 3 for Flutter](https://m3.material.io/develop/flutter)** - Official Material Design 3 implementation guide for Flutter

### Additional Resources
- **[Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)** - Comprehensive widget documentation
- **[Flutter Accessibility Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)** - Official accessibility guidelines
- **[Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)** - Performance optimization guidelines
- **[Material Design Guidelines](https://m3.material.io/)** - Complete Material Design 3 specification
- **[Flutter Cookbook](https://docs.flutter.dev/cookbook)** - Common Flutter development patterns and solutions

### Design and UX Resources
- **[Material Theme Builder](https://m3.material.io/theme-builder)** - Generate custom Material Design 3 color schemes
- **[Material Design Color System](https://m3.material.io/styles/color/system/overview)** - Color theory and implementation
- **[Material Design Typography](https://m3.material.io/styles/typography/overview)** - Typography scale and guidelines
- **[WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)** - Web Content Accessibility Guidelines for compliance

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
- Local data persistence with repositories

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
- **Use the design system** - follow the established color, typography, and spacing guidelines
- **Test comprehensively** - verify UI in both light/dark modes and various screen sizes
- **Implement meaningful animations** - use animations purposefully for feedback and guidance
- **Design mobile-first** - create responsive layouts that work across all device sizes
- **Maintain visual consistency** - use established patterns and components throughout the app
- **Optimize for performance** - ensure smooth 60fps animations and quick load times
- **Follow Material Design 3** - leverage modern design principles and patterns
- **Consider all user states** - design for loading, error, empty, and success states
- **Write semantic code** - use proper accessibility labels and semantic widgets

### Code Quality Standards
- Write clean, maintainable, and well-documented code
- Follow Dart and Flutter best practices and conventions
- Use meaningful variable and function names
- Implement proper error handling and validation
- Write unit tests for business logic and widget tests for UI components
- Keep functions and widgets focused and single-purpose
- Use const constructors where possible for performance
- Avoid deep widget nesting - break complex widgets into smaller components

## DRY Principles and Reusable Widgets

### Don't Repeat Yourself (DRY) Guidelines

The DRY principle is fundamental to maintaining clean, maintainable code. When developing UI components, always look for opportunities to extract common patterns into reusable widgets.

#### When to Create Reusable Widgets

**Create a reusable widget when:**
- The same UI pattern appears 3+ times across the app
- A component has configurable properties that could benefit other screens
- Complex UI logic can be encapsulated and reused
- A widget represents a common design pattern (cards, buttons, form fields)
- The component might be used in future features

**Example indicators for extraction:**
```dart
// ❌ BAD: Repeated card pattern
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [BoxShadow(...)],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(children: [...]),
  ),
)

// ✅ GOOD: Extract to reusable widget
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  
  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Padding(
        padding: padding!,
        child: child,
      ),
    );
  }
}
```

### Reusable Widget Categories

#### 1. Layout Widgets
Common layout patterns that can be reused across features:

```dart
// Spacing widgets
class VerticalSpacing extends StatelessWidget {
  final double height;
  const VerticalSpacing(this.height, {super.key});
  
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

// Section headers
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
```

#### 2. Interactive Widgets
Buttons, form controls, and other interactive elements:

```dart
// Modern button variants
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  
  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getTextColor(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );
    
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          child: child,
        );
      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          child: child,
        );
      case ButtonType.tertiary:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size(double.infinity, 56),
          ),
          child: child,
        );
    }
  }
  
  Color _getTextColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case ButtonType.secondary:
        return Theme.of(context).colorScheme.onSurface;
      case ButtonType.tertiary:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

enum ButtonType { primary, secondary, tertiary }
```

#### 3. State Widgets
Common state representations (loading, error, empty):

```dart
// Loading state widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showSpinner;
  
  const LoadingStateWidget({
    super.key,
    this.message,
    this.showSpinner = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner) ...[
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
          ],
          if (message != null)
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ModernButton(
                text: 'Try Again',
                onPressed: onRetry,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;
  
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ModernButton(
                text: actionText!,
                onPressed: onAction,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### 4. Form Widgets
Consistent form controls across the app:

```dart
// Modern text field
class ModernTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  
  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        filled: true,
        fillColor: enabled 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.all(16.0),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: enabled 
            ? null 
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
```

### Widget Organization Strategy

#### File Structure for Reusable Widgets
```
lib/common_widgets/
├── layout/
│   ├── modern_card_widget.dart
│   ├── section_header_widget.dart
│   └── spacing_widgets.dart
├── interactive/
│   ├── modern_button_widget.dart
│   ├── modern_text_field_widget.dart
│   └── action_chip_widget.dart
├── state/
│   ├── loading_state_widget.dart
│   ├── error_state_widget.dart
│   └── empty_state_widget.dart
├── display/
│   ├── info_card_widget.dart
│   ├── progress_indicator_widget.dart
│   └── status_badge_widget.dart
└── navigation/
    ├── modern_tab_bar_widget.dart
    └── breadcrumb_widget.dart
```

#### Naming Conventions
- **File names**: `component_name_widget.dart` (e.g., `modern_button_widget.dart`)
- **Class names**: `ComponentNameWidget` (e.g., `ModernButtonWidget`)
- **Use descriptive prefixes**: `Modern`, `Custom`, `App` to distinguish from built-in widgets
- **Group by functionality**: Layout, Interactive, State, Display, Navigation

#### Documentation Standards for Reusable Widgets
```dart
/// A modern, reusable button widget that follows Material Design 3 principles.
/// 
/// This widget provides consistent button styling across the app with support
/// for primary, secondary, and tertiary button types. It handles loading states
/// and can display icons alongside text.
/// 
/// Example usage:
/// ```dart
/// ModernButton(
///   text: 'Save Changes',
///   icon: Icons.save,
///   type: ButtonType.primary,
///   isLoading: state.isLoading,
///   onPressed: () => context.read<MyCubit>().saveData(),
/// )
/// ```
class ModernButton extends StatelessWidget {
  /// The text displayed on the button
  final String text;
  
  /// Callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// The visual style of the button (primary, secondary, tertiary)
  final ButtonType type;
  
  /// Whether to show loading spinner instead of text
  final bool isLoading;
  
  /// Optional icon to display before the text
  final IconData? icon;
  
  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
  });
  
  // Implementation...
}
```

### Best Practices for Reusable Widgets

#### 1. Design for Flexibility
```dart
// ❌ BAD: Too specific
class ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  // ...
}

// ✅ GOOD: Generic and flexible
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  // ...
}
```

#### 2. Provide Sensible Defaults
```dart
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? customShadows;
  
  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0), // Sensible default
    this.backgroundColor, // Null means use theme color
    this.borderRadius = 12.0, // Standard app radius
    this.customShadows, // Null means use default shadows
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: customShadows ?? _defaultShadows(context),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
  
  List<BoxShadow> _defaultShadows(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 12.0,
    ),
  ];
}
```

#### 3. Make Widgets Testable
```dart
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Key? buttonKey; // Add specific key for testing
  
  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonKey,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: buttonKey, // Use specific key for widget testing
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Usage with testing key
ModernButton(
  text: 'Submit',
  buttonKey: const Key('submit_button'),
  onPressed: () => submitForm(),
)
```

#### 4. Handle Edge Cases
```dart
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Text(
              _getInitials(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
  
  String _getInitials() {
    if (initials != null && initials!.isNotEmpty) {
      return initials!.substring(0, math.min(2, initials!.length)).toUpperCase();
    }
    return '?'; // Fallback for no initials
  }
}
```

### Refactoring Guidelines

#### When to Refactor Into Reusable Widgets

**Immediate refactoring triggers:**
- Copy-pasting the same widget code
- Similar UI patterns with slight variations
- Complex widgets that could be simplified
- Widgets that violate single responsibility principle

**Refactoring process:**
1. **Identify patterns**: Look for repeated UI structures
2. **Extract commonalities**: Find shared properties and behaviors
3. **Design the API**: Create a flexible, intuitive interface
4. **Implement with defaults**: Provide sensible default values
5. **Document thoroughly**: Include examples and use cases
6. **Test extensively**: Ensure the widget works in various contexts
7. **Update existing usage**: Replace old code with new widget
8. **Iterate based on feedback**: Improve the API as needed

#### Example Refactoring Process

**Before refactoring (repeated code):**
```dart
// In multiple files...
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [...],
  ),
  child: Column(
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      SizedBox(height: 8),
      Text(content, style: Theme.of(context).textTheme.bodyMedium),
    ],
  ),
)
```

**After refactoring (reusable widget):**
```dart
// In common_widgets/
class ContentCard extends StatelessWidget {
  final String title;
  final String content;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const ContentCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage in features
ContentCard(
  title: 'Math Problem #1',
  content: 'Solve for x: 2x + 5 = 15',
  trailing: Icon(Icons.more_vert),
  onTap: () => navigateToDetails(),
)
```

### Performance Considerations

#### Widget Optimization Tips
```dart
// ✅ Use const constructors when possible
class StaticWidget extends StatelessWidget {
  const StaticWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static content'); // const is important
  }
}

// ✅ Use keys for better performance in lists
ListView.builder(
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemWidget(
      key: ValueKey(item.id), // Helps Flutter optimize rebuilds
      item: item,
    );
  },
)

// ✅ Separate expensive operations
class ExpensiveWidget extends StatelessWidget {
  final String data;
  
  const ExpensiveWidget({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Separate expensive computation into its own widget
        _ExpensiveComputation(data: data),
        // Other simple widgets...
      ],
    );
  }
}

class _ExpensiveComputation extends StatelessWidget {
  final String data;
  
  const _ExpensiveComputation({required this.data});
  
  @override
  Widget build(BuildContext context) {
    // This will only rebuild when data changes
    final result = expensiveOperation(data);
    return Text(result);
  }
}
```

By following these DRY principles and reusable widget guidelines, you'll create a more maintainable, consistent, and efficient codebase that scales well as the app grows.