# Flutter Reference

## Research Queries
- "Flutter best practices 2025 2026"
- "Flutter project structure clean architecture"
- "Flutter state management Riverpod vs Bloc 2025"
- "Flutter design system atomic design"
- "Flutter Material 3 theming"
- "Flutter Cupertino adaptive widgets"

## Package Manager
**Flutter CLI + pub** - Standard Flutter tooling.

```bash
flutter create my_app --org com.example
cd my_app
flutter pub get
```

## Design System Philosophy

Flutter excels at design systems. Structure your UI as:

```
Tokens → Components → Patterns → Features → Screens
```

1. **Tokens**: Colors, typography, spacing, shadows (ThemeData)
2. **Components**: Buttons, inputs, cards (stateless widgets)
3. **Patterns**: Forms, lists, navigation patterns
4. **Features**: Complete feature modules
5. **Screens**: Page-level compositions

## Project Structure

```
lib/
├── main.dart
├── app.dart                        # MaterialApp/CupertinoApp setup
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   └── app_typography.dart
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData configuration
│   │   ├── color_schemes.dart      # Material 3 color schemes
│   │   └── text_theme.dart
│   ├── router/
│   │   └── app_router.dart         # GoRouter setup
│   ├── network/
│   │   └── api_client.dart
│   └── utils/
├── design_system/
│   ├── tokens/
│   │   ├── colors.dart
│   │   ├── spacing.dart
│   │   ├── typography.dart
│   │   └── shadows.dart
│   ├── components/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── icon_button.dart
│   │   ├── inputs/
│   │   │   ├── text_field.dart
│   │   │   └── dropdown.dart
│   │   ├── cards/
│   │   │   ├── base_card.dart
│   │   │   └── info_card.dart
│   │   └── feedback/
│   │       ├── loading.dart
│   │       ├── snackbar.dart
│   │       └── dialog.dart
│   └── patterns/
│       ├── form_field.dart
│       ├── list_tile.dart
│       └── app_bar.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/        # or blocs/
│   └── home/
│       └── ...
└── shared/
    ├── widgets/
    └── extensions/
```

## Essential Libraries

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (choose one)
  flutter_riverpod: ^2.4.0          # Recommended
  # flutter_bloc: ^8.1.0            # Alternative

  # Navigation
  go_router: ^13.0.0

  # Network
  dio: ^5.4.0
  retrofit: ^4.0.0

  # Local Storage
  shared_preferences: ^2.2.0
  hive_flutter: ^1.1.0              # For complex data

  # UI Components
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0                   # Loading states

  # Forms
  reactive_forms: ^16.0.0

  # Utils
  intl: ^0.18.0                     # Formatting
  equatable: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  retrofit_generator: ^8.0.0
  mockito: ^5.4.0
```

## Code Patterns

### Design Tokens
```dart
// design_system/tokens/spacing.dart
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// design_system/tokens/colors.dart
abstract class AppColors {
  // Semantic colors
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);

  // Surface colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
}
```

### Material 3 Theme
```dart
// core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // ... similar customizations
    );
  }

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );
}
```

### Reusable Component
```dart
// design_system/components/buttons/primary_button.dart
import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonSize size;
  final IconData? leadingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }

  double _getHeight() => switch (size) {
    ButtonSize.small => 36,
    ButtonSize.medium => 44,
    ButtonSize.large => 52,
  };
}
```

### Adaptive Platform Widget
```dart
// design_system/components/adaptive/adaptive_scaffold.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: actions != null
              ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
              : null,
        ),
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
```

### Riverpod Provider
```dart
// features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### Screen with Design System
```dart
// features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to continue',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AppTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              const AppTextField(
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: () => _handleLogin(ref),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Setup Commands

```bash
# Create project
flutter create my_app --org com.example --platforms ios,android
cd my_app

# Add dependencies
flutter pub add flutter_riverpod go_router dio
flutter pub add shared_preferences cached_network_image
flutter pub add flutter_svg shimmer equatable intl
flutter pub add dev:flutter_lints dev:mockito dev:build_runner

# Create structure
mkdir -p lib/{core/{constants,theme,router,network,utils},design_system/{tokens,components/{buttons,inputs,cards,feedback},patterns},features/{auth/{data/{repositories,datasources},domain/{entities,repositories,usecases},presentation/{screens,widgets,providers}},home},shared/{widgets,extensions}}

# Run
flutter run
```

## UI Framework Options

### Material 3 (Recommended for Android-first)
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
)
```

### Cupertino (iOS-native feel)
```dart
CupertinoApp(
  theme: const CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
  ),
)
```

### Adaptive (Both platforms)
Use `Platform.isIOS` checks or packages like `flutter_platform_widgets`.

## Key Rules

- ALWAYS use Material 3 (`useMaterial3: true`)
- ALWAYS define design tokens (colors, spacing, typography) as constants
- ALWAYS create reusable components in design_system/
- NEVER hardcode colors, sizes, or strings in widgets
- Use `Theme.of(context)` to access theme values
- Create adaptive widgets for platform-specific UX
- Keep widgets small and composable
- Use Riverpod or Bloc for state management
