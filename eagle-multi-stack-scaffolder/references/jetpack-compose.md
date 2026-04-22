# Jetpack Compose Reference

## Research Queries
- "Jetpack Compose best practices 2025 2026"
- "Jetpack Compose design system implementation"
- "Android Material 3 custom theme"
- "Jetpack Compose component library"
- "Android app architecture guide official"
- "Jetpack Compose project structure clean architecture"
- "Android version catalogs dependency management"

## Package Manager
**Gradle Version Catalogs** - Required for modern Android projects.

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.0.0"
compose-bom = "2025.01.00"
hilt = "2.51"
material3 = "1.2.0"

[libraries]
compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }
compose-ui = { group = "androidx.compose.ui", name = "ui" }
compose-material3 = { group = "androidx.compose.material3", name = "material3" }
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }

[plugins]
android-application = { id = "com.android.application", version = "8.3.0" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
```

## Design System Philosophy

Build your UI as a component library following Material 3:

```
Tokens → Theme → Components → Patterns → Features → Screens
```

1. **Tokens**: Colors, typography, shapes defined in theme
2. **Theme**: MaterialTheme customization
3. **Components**: Reusable composables
4. **Patterns**: Common UI patterns (forms, lists)
5. **Features**: Complete feature modules
6. **Screens**: Full screen compositions

## Project Structure

```
app/src/main/java/com/example/{app}/
├── MainActivity.kt
├── {App}Application.kt
├── designsystem/
│   ├── theme/
│   │   ├── Color.kt                 # Color tokens
│   │   ├── Type.kt                  # Typography
│   │   ├── Shape.kt                 # Shape definitions
│   │   └── Theme.kt                 # MaterialTheme setup
│   ├── components/
│   │   ├── buttons/
│   │   │   ├── PrimaryButton.kt
│   │   │   ├── SecondaryButton.kt
│   │   │   └── IconButton.kt
│   │   ├── inputs/
│   │   │   ├── AppTextField.kt
│   │   │   └── SearchField.kt
│   │   ├── cards/
│   │   │   ├── BaseCard.kt
│   │   │   └── InfoCard.kt
│   │   └── feedback/
│   │       ├── LoadingIndicator.kt
│   │       └── SnackbarHost.kt
│   └── patterns/
│       ├── FormField.kt
│       └── ListItem.kt
├── core/
│   ├── di/
│   ├── network/
│   └── database/
├── data/
│   ├── model/
│   ├── repository/
│   └── mapper/
├── domain/
│   ├── model/
│   ├── repository/
│   └── usecase/
└── presentation/
    ├── navigation/
    │   └── AppNavigation.kt
    └── screens/
        ├── home/
        │   ├── HomeScreen.kt
        │   ├── HomeViewModel.kt
        │   └── HomeUiState.kt
        └── auth/
            ├── LoginScreen.kt
            └── LoginViewModel.kt
```

## Design Token Implementation

### Colors (Material 3)
```kotlin
// designsystem/theme/Color.kt
package com.example.app.designsystem.theme

import androidx.compose.ui.graphics.Color

// Primary palette
val Primary10 = Color(0xFF21005D)
val Primary20 = Color(0xFF381E72)
val Primary30 = Color(0xFF4F378B)
val Primary40 = Color(0xFF6750A4)
val Primary80 = Color(0xFFD0BCFF)
val Primary90 = Color(0xFFEADDFF)
val Primary100 = Color(0xFFFFFFFF)

// Secondary palette
val Secondary10 = Color(0xFF1D192B)
val Secondary20 = Color(0xFF332D41)
val Secondary30 = Color(0xFF4A4458)
val Secondary40 = Color(0xFF625B71)
val Secondary80 = Color(0xFFCCC2DC)
val Secondary90 = Color(0xFFE8DEF8)

// Tertiary palette
val Tertiary10 = Color(0xFF31111D)
val Tertiary20 = Color(0xFF492532)
val Tertiary40 = Color(0xFF7D5260)
val Tertiary80 = Color(0xFFEFB8C8)
val Tertiary90 = Color(0xFFFFD8E4)

// Error palette
val Error10 = Color(0xFF410E0B)
val Error20 = Color(0xFF601410)
val Error40 = Color(0xFFB3261E)
val Error80 = Color(0xFFF2B8B5)
val Error90 = Color(0xFFF9DEDC)

// Neutral palette
val Neutral10 = Color(0xFF1C1B1F)
val Neutral20 = Color(0xFF313033)
val Neutral90 = Color(0xFFE6E1E5)
val Neutral95 = Color(0xFFF4EFF4)
val Neutral99 = Color(0xFFFFFBFE)

// Semantic colors
val Success = Color(0xFF4CAF50)
val Warning = Color(0xFFFF9800)
val Info = Color(0xFF2196F3)
```

### Typography
```kotlin
// designsystem/theme/Type.kt
package com.example.app.designsystem.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.example.app.R

val InterFontFamily = FontFamily(
    Font(R.font.inter_regular, FontWeight.Normal),
    Font(R.font.inter_medium, FontWeight.Medium),
    Font(R.font.inter_semibold, FontWeight.SemiBold),
    Font(R.font.inter_bold, FontWeight.Bold)
)

val AppTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 57.sp,
        lineHeight = 64.sp,
    ),
    displayMedium = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 45.sp,
        lineHeight = 52.sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 28.sp,
        lineHeight = 36.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = InterFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
    ),
)
```

### Shapes & Spacing
```kotlin
// designsystem/theme/Shape.kt
package com.example.app.designsystem.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

val AppShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(24.dp)
)

// Spacing tokens
object Spacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 16.dp
    val lg = 24.dp
    val xl = 32.dp
    val xxl = 48.dp
}
```

### Theme Setup
```kotlin
// designsystem/theme/Theme.kt
package com.example.app.designsystem.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = Primary40,
    onPrimary = Primary100,
    primaryContainer = Primary90,
    onPrimaryContainer = Primary10,
    secondary = Secondary40,
    onSecondary = Secondary100,
    secondaryContainer = Secondary90,
    onSecondaryContainer = Secondary10,
    tertiary = Tertiary40,
    onTertiary = Tertiary100,
    tertiaryContainer = Tertiary90,
    onTertiaryContainer = Tertiary10,
    error = Error40,
    onError = Error100,
    errorContainer = Error90,
    onErrorContainer = Error10,
    background = Neutral99,
    onBackground = Neutral10,
    surface = Neutral99,
    onSurface = Neutral10,
    surfaceVariant = Neutral90,
    onSurfaceVariant = Neutral30,
    outline = Neutral50,
    outlineVariant = Neutral80,
)

private val DarkColorScheme = darkColorScheme(
    primary = Primary80,
    onPrimary = Primary20,
    primaryContainer = Primary30,
    onPrimaryContainer = Primary90,
    secondary = Secondary80,
    onSecondary = Secondary20,
    secondaryContainer = Secondary30,
    onSecondaryContainer = Secondary90,
    tertiary = Tertiary80,
    onTertiary = Tertiary20,
    tertiaryContainer = Tertiary30,
    onTertiaryContainer = Tertiary90,
    error = Error80,
    onError = Error20,
    errorContainer = Error30,
    onErrorContainer = Error90,
    background = Neutral10,
    onBackground = Neutral90,
    surface = Neutral10,
    onSurface = Neutral90,
    surfaceVariant = Neutral30,
    onSurfaceVariant = Neutral80,
    outline = Neutral60,
    outlineVariant = Neutral30,
)

@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.surface.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = AppTypography,
        shapes = AppShapes,
        content = content
    )
}
```

## Component Implementation

### Primary Button
```kotlin
// designsystem/components/buttons/PrimaryButton.kt
package com.example.app.designsystem.components.buttons

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.app.designsystem.theme.Spacing

enum class ButtonSize { Small, Medium, Large }

@Composable
fun PrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    isLoading: Boolean = false,
    size: ButtonSize = ButtonSize.Medium,
    leadingIcon: @Composable (() -> Unit)? = null,
) {
    val height = when (size) {
        ButtonSize.Small -> 36.dp
        ButtonSize.Medium -> 44.dp
        ButtonSize.Large -> 52.dp
    }

    Button(
        onClick = onClick,
        modifier = modifier.height(height),
        enabled = enabled && !isLoading,
        shape = MaterialTheme.shapes.medium,
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary,
            contentColor = MaterialTheme.colorScheme.onPrimary,
            disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant,
            disabledContentColor = MaterialTheme.colorScheme.onSurfaceVariant,
        ),
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(20.dp),
                color = MaterialTheme.colorScheme.onPrimary,
                strokeWidth = 2.dp,
            )
        } else {
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                leadingIcon?.invoke()
                Text(
                    text = text,
                    style = MaterialTheme.typography.labelLarge,
                )
            }
        }
    }
}

@Composable
fun SecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(44.dp),
        enabled = enabled,
        shape = MaterialTheme.shapes.medium,
        colors = ButtonDefaults.outlinedButtonColors(
            contentColor = MaterialTheme.colorScheme.primary,
        ),
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelLarge,
        )
    }
}

@Composable
fun GhostButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    TextButton(
        onClick = onClick,
        modifier = modifier.height(44.dp),
        enabled = enabled,
        colors = ButtonDefaults.textButtonColors(
            contentColor = MaterialTheme.colorScheme.primary,
        ),
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelLarge,
        )
    }
}
```

### App TextField
```kotlin
// designsystem/components/inputs/AppTextField.kt
package com.example.app.designsystem.components.inputs

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import com.example.app.designsystem.theme.Spacing

@Composable
fun AppTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    errorMessage: String? = null,
    isPassword: Boolean = false,
    keyboardType: KeyboardType = KeyboardType.Text,
    leadingIcon: @Composable (() -> Unit)? = null,
    trailingIcon: @Composable (() -> Unit)? = null,
    singleLine: Boolean = true,
) {
    var passwordVisible by remember { mutableStateOf(false) }

    Column(modifier = modifier) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(bottom = Spacing.xs),
        )

        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            placeholder = {
                Text(
                    text = placeholder,
                    style = MaterialTheme.typography.bodyLarge,
                )
            },
            leadingIcon = leadingIcon,
            trailingIcon = trailingIcon ?: if (isPassword) {
                {
                    IconButton(onClick = { passwordVisible = !passwordVisible }) {
                        Icon(
                            imageVector = if (passwordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                            contentDescription = if (passwordVisible) "Hide password" else "Show password",
                        )
                    }
                }
            } else null,
            visualTransformation = if (isPassword && !passwordVisible) {
                PasswordVisualTransformation()
            } else {
                VisualTransformation.None
            },
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            singleLine = singleLine,
            isError = errorMessage != null,
            shape = MaterialTheme.shapes.medium,
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.surface,
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                errorBorderColor = MaterialTheme.colorScheme.error,
            ),
        )

        if (errorMessage != null) {
            Text(
                text = errorMessage,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(top = Spacing.xs, start = Spacing.md),
            )
        }
    }
}
```

### Card Component
```kotlin
// designsystem/components/cards/BaseCard.kt
package com.example.app.designsystem.components.cards

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.app.designsystem.theme.Spacing

@Composable
fun BaseCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    if (onClick != null) {
        Card(
            onClick = onClick,
            modifier = modifier,
            shape = MaterialTheme.shapes.large,
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface,
            ),
            elevation = CardDefaults.cardElevation(
                defaultElevation = 1.dp,
            ),
        ) {
            content()
        }
    } else {
        Card(
            modifier = modifier,
            shape = MaterialTheme.shapes.large,
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface,
            ),
            elevation = CardDefaults.cardElevation(
                defaultElevation = 1.dp,
            ),
        ) {
            content()
        }
    }
}
```

## Architecture: Clean + MVVM

### ViewModel
```kotlin
// presentation/screens/auth/LoginViewModel.kt
package com.example.app.presentation.screens.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val isLoggedIn: Boolean = false,
)

sealed interface LoginEvent {
    data class EmailChanged(val email: String) : LoginEvent
    data class PasswordChanged(val password: String) : LoginEvent
    data object Login : LoginEvent
    data object ClearError : LoginEvent
}

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    val isFormValid: Boolean
        get() = _uiState.value.email.isNotBlank() &&
                _uiState.value.password.isNotBlank() &&
                _uiState.value.email.contains("@")

    fun onEvent(event: LoginEvent) {
        when (event) {
            is LoginEvent.EmailChanged -> {
                _uiState.update { it.copy(email = event.email, error = null) }
            }
            is LoginEvent.PasswordChanged -> {
                _uiState.update { it.copy(password = event.password, error = null) }
            }
            is LoginEvent.Login -> login()
            is LoginEvent.ClearError -> {
                _uiState.update { it.copy(error = null) }
            }
        }
    }

    private fun login() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            loginUseCase(_uiState.value.email, _uiState.value.password)
                .onSuccess {
                    _uiState.update { it.copy(isLoading = false, isLoggedIn = true) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false, error = error.message) }
                }
        }
    }
}
```

### Screen with Design System
```kotlin
// presentation/screens/auth/LoginScreen.kt
package com.example.app.presentation.screens.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.app.designsystem.components.buttons.GhostButton
import com.example.app.designsystem.components.buttons.PrimaryButton
import com.example.app.designsystem.components.inputs.AppTextField
import com.example.app.designsystem.theme.Spacing

@Composable
fun LoginScreen(
    onNavigateToSignUp: () -> Unit,
    onLoginSuccess: () -> Unit,
    viewModel: LoginViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState.isLoggedIn) {
        if (uiState.isLoggedIn) {
            onLoginSuccess()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(Spacing.lg),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(modifier = Modifier.height(Spacing.xxl))

        // Header
        Text(
            text = "Welcome Back",
            style = MaterialTheme.typography.headlineLarge,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(modifier = Modifier.height(Spacing.sm))
        Text(
            text = "Sign in to continue",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Form
        AppTextField(
            value = uiState.email,
            onValueChange = { viewModel.onEvent(LoginEvent.EmailChanged(it)) },
            label = "Email",
            placeholder = "you@example.com",
            keyboardType = KeyboardType.Email,
            leadingIcon = {
                Icon(Icons.Outlined.Email, contentDescription = null)
            },
            errorMessage = if (uiState.error != null && uiState.email.isEmpty()) "Email required" else null,
        )

        Spacer(modifier = Modifier.height(Spacing.md))

        AppTextField(
            value = uiState.password,
            onValueChange = { viewModel.onEvent(LoginEvent.PasswordChanged(it)) },
            label = "Password",
            placeholder = "Enter your password",
            isPassword = true,
            leadingIcon = {
                Icon(Icons.Outlined.Lock, contentDescription = null)
            },
            errorMessage = if (uiState.error != null && uiState.password.isEmpty()) "Password required" else null,
        )

        Spacer(modifier = Modifier.height(Spacing.lg))

        // Actions
        PrimaryButton(
            text = "Sign In",
            onClick = { viewModel.onEvent(LoginEvent.Login) },
            modifier = Modifier.fillMaxWidth(),
            isLoading = uiState.isLoading,
            enabled = viewModel.isFormValid,
        )

        Spacer(modifier = Modifier.height(Spacing.sm))

        GhostButton(
            text = "Create Account",
            onClick = onNavigateToSignUp,
            modifier = Modifier.fillMaxWidth(),
        )

        // Error display
        uiState.error?.let { error ->
            Spacer(modifier = Modifier.height(Spacing.md))
            Text(
                text = error,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error,
            )
        }
    }
}
```

## Essential Libraries

| Category | Package | Notes |
|----------|---------|-------|
| DI | Hilt | Google recommended |
| Networking | Retrofit + OkHttp | Industry standard |
| Images | Coil | Kotlin-first, Compose support |
| Database | Room | Official |
| Navigation | Navigation Compose | Official |
| State | StateFlow | Kotlin native |

## Setup Commands

```bash
# Via Android Studio:
# File > New > New Project > Empty Activity (Compose)

# After creation, add version catalog:
mkdir -p gradle
touch gradle/libs.versions.toml

# Create design system structure:
# - designsystem/theme/
# - designsystem/components/buttons/
# - designsystem/components/inputs/
# - designsystem/components/cards/
# - designsystem/patterns/
# - presentation/screens/{feature}/
```

## Key Rules

1. **ALWAYS use Material 3** - MaterialTheme with custom color scheme
2. **ALWAYS define design tokens** - Colors, typography, shapes in theme
3. **ALWAYS create reusable components** - Buttons, text fields, cards
4. **Composables: `PascalCase`** - UserProfileCard
5. **ViewModels: `{Feature}ViewModel`** - LoginViewModel
6. **UI State: `{Feature}UiState`** - LoginUiState
7. **Use `collectAsStateWithLifecycle()`** for flows
8. **Stateless composables preferred** - State hoisting
9. **Modifier always last parameter** with default `Modifier`
10. **Support dark mode** - Use colorScheme semantic colors
