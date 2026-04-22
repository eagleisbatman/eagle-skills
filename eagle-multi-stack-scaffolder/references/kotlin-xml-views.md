# Kotlin XML Views Reference (Traditional Android)

## Research Queries
- "Android XML Views best practices 2025 2026"
- "Android View Binding vs Data Binding 2025"
- "Android Material Design 3 XML components"
- "Android design system XML implementation"
- "Android custom view component library"

## When to Use XML Views

- Legacy project maintenance
- Complex custom views/animations
- When team is more familiar with XML
- Certain UI patterns easier in XML (ConstraintLayout, MotionLayout)

**Note**: For new projects, consider Jetpack Compose instead.

## Package Manager
**Gradle Version Catalogs** - Required for modern Android projects.

## Design System Philosophy

Structure your UI as a component library:

```
Tokens (resources) → Styles → Components → Layouts → Screens
```

1. **Tokens**: colors.xml, dimens.xml, type.xml
2. **Styles**: Component styles in themes.xml
3. **Components**: Custom views or styled Material components
4. **Layouts**: Reusable layout patterns
5. **Screens**: Activity/Fragment layouts

## Project Structure

```
app/src/main/
├── java/com/example/app/
│   ├── App.kt                           # Application class
│   ├── MainActivity.kt
│   ├── core/
│   │   ├── di/                          # Hilt modules
│   │   ├── network/
│   │   └── database/
│   ├── data/
│   │   ├── model/
│   │   ├── repository/
│   │   └── mapper/
│   ├── domain/
│   │   ├── model/
│   │   ├── repository/
│   │   └── usecase/
│   ├── ui/
│   │   ├── common/
│   │   │   ├── components/              # Custom views
│   │   │   │   ├── PrimaryButton.kt
│   │   │   │   ├── AppTextField.kt
│   │   │   │   └── LoadingView.kt
│   │   │   ├── adapter/
│   │   │   │   └── BaseAdapter.kt
│   │   │   └── extensions/
│   │   │       └── ViewExtensions.kt
│   │   ├── auth/
│   │   │   ├── LoginActivity.kt
│   │   │   ├── LoginViewModel.kt
│   │   │   └── LoginUiState.kt
│   │   └── home/
│   │       ├── HomeFragment.kt
│   │       └── HomeViewModel.kt
│   └── utils/
├── res/
│   ├── values/
│   │   ├── colors.xml                   # Color tokens
│   │   ├── dimens.xml                   # Spacing tokens
│   │   ├── type.xml                     # Typography tokens
│   │   ├── strings.xml
│   │   ├── themes.xml                   # App theme
│   │   ├── styles.xml                   # Component styles
│   │   └── attrs.xml                    # Custom attributes
│   ├── values-night/
│   │   ├── colors.xml                   # Dark mode colors
│   │   └── themes.xml
│   ├── drawable/
│   │   ├── bg_primary_button.xml
│   │   ├── bg_text_field.xml
│   │   └── ic_*.xml
│   ├── layout/
│   │   ├── activity_main.xml
│   │   ├── fragment_home.xml
│   │   ├── item_*.xml                   # RecyclerView items
│   │   └── component_*.xml              # Reusable components
│   └── font/
│       └── *.ttf
└── AndroidManifest.xml
```

## Essential Dependencies

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "1.9.22"
agp = "8.2.2"
material = "1.11.0"
constraintlayout = "2.1.4"
navigation = "2.7.6"
hilt = "2.50"
lifecycle = "2.7.0"
coroutines = "1.7.3"
coil = "2.5.0"

[libraries]
# Material Design 3
material = { group = "com.google.android.material", name = "material", version.ref = "material" }
constraintlayout = { group = "androidx.constraintlayout", name = "constraintlayout", version.ref = "constraintlayout" }

# Navigation
navigation-fragment = { group = "androidx.navigation", name = "navigation-fragment-ktx", version.ref = "navigation" }
navigation-ui = { group = "androidx.navigation", name = "navigation-ui-ktx", version.ref = "navigation" }

# DI
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-compiler", version.ref = "hilt" }

# Lifecycle & ViewModel
lifecycle-viewmodel = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-ktx", version.ref = "lifecycle" }
lifecycle-runtime = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycle" }

# Coroutines
coroutines-core = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-core", version.ref = "coroutines" }
coroutines-android = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-android", version.ref = "coroutines" }

# Images
coil = { group = "io.coil-kt", name = "coil", version.ref = "coil" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
navigation-safeargs = { id = "androidx.navigation.safeargs.kotlin", version.ref = "navigation" }
```

## Design Token Resources

### Colors (Material 3)
```xml
<!-- res/values/colors.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Primary -->
    <color name="md_theme_light_primary">#6750A4</color>
    <color name="md_theme_light_onPrimary">#FFFFFF</color>
    <color name="md_theme_light_primaryContainer">#EADDFF</color>
    <color name="md_theme_light_onPrimaryContainer">#21005D</color>

    <!-- Secondary -->
    <color name="md_theme_light_secondary">#625B71</color>
    <color name="md_theme_light_onSecondary">#FFFFFF</color>
    <color name="md_theme_light_secondaryContainer">#E8DEF8</color>
    <color name="md_theme_light_onSecondaryContainer">#1D192B</color>

    <!-- Error -->
    <color name="md_theme_light_error">#B3261E</color>
    <color name="md_theme_light_onError">#FFFFFF</color>
    <color name="md_theme_light_errorContainer">#F9DEDC</color>

    <!-- Surface -->
    <color name="md_theme_light_surface">#FFFBFE</color>
    <color name="md_theme_light_onSurface">#1C1B1F</color>
    <color name="md_theme_light_surfaceVariant">#E7E0EC</color>
    <color name="md_theme_light_onSurfaceVariant">#49454F</color>

    <!-- Background -->
    <color name="md_theme_light_background">#FFFBFE</color>
    <color name="md_theme_light_onBackground">#1C1B1F</color>

    <!-- Outline -->
    <color name="md_theme_light_outline">#79747E</color>
    <color name="md_theme_light_outlineVariant">#CAC4D0</color>

    <!-- Semantic Colors -->
    <color name="success">#4CAF50</color>
    <color name="warning">#FF9800</color>
    <color name="info">#2196F3</color>
</resources>
```

### Spacing
```xml
<!-- res/values/dimens.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Spacing Scale -->
    <dimen name="spacing_xs">4dp</dimen>
    <dimen name="spacing_sm">8dp</dimen>
    <dimen name="spacing_md">16dp</dimen>
    <dimen name="spacing_lg">24dp</dimen>
    <dimen name="spacing_xl">32dp</dimen>
    <dimen name="spacing_xxl">48dp</dimen>

    <!-- Component Sizes -->
    <dimen name="button_height_small">36dp</dimen>
    <dimen name="button_height_medium">48dp</dimen>
    <dimen name="button_height_large">56dp</dimen>

    <dimen name="input_height">56dp</dimen>
    <dimen name="icon_size_small">16dp</dimen>
    <dimen name="icon_size_medium">24dp</dimen>
    <dimen name="icon_size_large">32dp</dimen>

    <!-- Corner Radius -->
    <dimen name="radius_sm">4dp</dimen>
    <dimen name="radius_md">8dp</dimen>
    <dimen name="radius_lg">12dp</dimen>
    <dimen name="radius_xl">16dp</dimen>
    <dimen name="radius_full">100dp</dimen>
</resources>
```

### Typography
```xml
<!-- res/values/type.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Display -->
    <style name="TextAppearance.App.DisplayLarge" parent="TextAppearance.Material3.DisplayLarge">
        <item name="fontFamily">@font/inter_regular</item>
        <item name="android:textSize">57sp</item>
    </style>

    <!-- Headline -->
    <style name="TextAppearance.App.HeadlineLarge" parent="TextAppearance.Material3.HeadlineLarge">
        <item name="fontFamily">@font/inter_semibold</item>
        <item name="android:textSize">32sp</item>
    </style>

    <style name="TextAppearance.App.HeadlineMedium" parent="TextAppearance.Material3.HeadlineMedium">
        <item name="fontFamily">@font/inter_semibold</item>
        <item name="android:textSize">28sp</item>
    </style>

    <!-- Title -->
    <style name="TextAppearance.App.TitleLarge" parent="TextAppearance.Material3.TitleLarge">
        <item name="fontFamily">@font/inter_medium</item>
        <item name="android:textSize">22sp</item>
    </style>

    <style name="TextAppearance.App.TitleMedium" parent="TextAppearance.Material3.TitleMedium">
        <item name="fontFamily">@font/inter_medium</item>
        <item name="android:textSize">16sp</item>
    </style>

    <!-- Body -->
    <style name="TextAppearance.App.BodyLarge" parent="TextAppearance.Material3.BodyLarge">
        <item name="fontFamily">@font/inter_regular</item>
        <item name="android:textSize">16sp</item>
    </style>

    <style name="TextAppearance.App.BodyMedium" parent="TextAppearance.Material3.BodyMedium">
        <item name="fontFamily">@font/inter_regular</item>
        <item name="android:textSize">14sp</item>
    </style>

    <!-- Label -->
    <style name="TextAppearance.App.LabelLarge" parent="TextAppearance.Material3.LabelLarge">
        <item name="fontFamily">@font/inter_medium</item>
        <item name="android:textSize">14sp</item>
    </style>
</resources>
```

### Theme
```xml
<!-- res/values/themes.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.App" parent="Theme.Material3.Light.NoActionBar">
        <!-- Primary -->
        <item name="colorPrimary">@color/md_theme_light_primary</item>
        <item name="colorOnPrimary">@color/md_theme_light_onPrimary</item>
        <item name="colorPrimaryContainer">@color/md_theme_light_primaryContainer</item>
        <item name="colorOnPrimaryContainer">@color/md_theme_light_onPrimaryContainer</item>

        <!-- Secondary -->
        <item name="colorSecondary">@color/md_theme_light_secondary</item>
        <item name="colorOnSecondary">@color/md_theme_light_onSecondary</item>
        <item name="colorSecondaryContainer">@color/md_theme_light_secondaryContainer</item>
        <item name="colorOnSecondaryContainer">@color/md_theme_light_onSecondaryContainer</item>

        <!-- Error -->
        <item name="colorError">@color/md_theme_light_error</item>
        <item name="colorOnError">@color/md_theme_light_onError</item>
        <item name="colorErrorContainer">@color/md_theme_light_errorContainer</item>

        <!-- Surface -->
        <item name="colorSurface">@color/md_theme_light_surface</item>
        <item name="colorOnSurface">@color/md_theme_light_onSurface</item>
        <item name="colorSurfaceVariant">@color/md_theme_light_surfaceVariant</item>
        <item name="colorOnSurfaceVariant">@color/md_theme_light_onSurfaceVariant</item>

        <!-- Background -->
        <item name="android:colorBackground">@color/md_theme_light_background</item>
        <item name="colorOnBackground">@color/md_theme_light_onBackground</item>

        <!-- Component Styles -->
        <item name="materialButtonStyle">@style/Widget.App.Button</item>
        <item name="textInputStyle">@style/Widget.App.TextInputLayout</item>
        <item name="materialCardViewStyle">@style/Widget.App.CardView</item>
    </style>
</resources>
```

### Component Styles
```xml
<!-- res/values/styles.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Primary Button -->
    <style name="Widget.App.Button" parent="Widget.Material3.Button">
        <item name="android:minHeight">@dimen/button_height_medium</item>
        <item name="cornerRadius">@dimen/radius_lg</item>
        <item name="android:textAppearance">@style/TextAppearance.App.LabelLarge</item>
    </style>

    <style name="Widget.App.Button.Secondary" parent="Widget.Material3.Button.OutlinedButton">
        <item name="android:minHeight">@dimen/button_height_medium</item>
        <item name="cornerRadius">@dimen/radius_lg</item>
    </style>

    <style name="Widget.App.Button.Text" parent="Widget.Material3.Button.TextButton">
        <item name="android:minHeight">@dimen/button_height_medium</item>
    </style>

    <!-- Text Input -->
    <style name="Widget.App.TextInputLayout" parent="Widget.Material3.TextInputLayout.FilledBox">
        <item name="boxCornerRadiusTopStart">@dimen/radius_lg</item>
        <item name="boxCornerRadiusTopEnd">@dimen/radius_lg</item>
        <item name="boxCornerRadiusBottomStart">@dimen/radius_lg</item>
        <item name="boxCornerRadiusBottomEnd">@dimen/radius_lg</item>
    </style>

    <!-- Card -->
    <style name="Widget.App.CardView" parent="Widget.Material3.CardView.Filled">
        <item name="cardCornerRadius">@dimen/radius_lg</item>
        <item name="cardElevation">0dp</item>
        <item name="contentPadding">@dimen/spacing_md</item>
    </style>
</resources>
```

## Custom View Component
```kotlin
// ui/common/components/PrimaryButton.kt
class PrimaryButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : MaterialButton(context, attrs, defStyleAttr) {

    private var isLoading = false

    init {
        context.theme.obtainStyledAttributes(attrs, R.styleable.PrimaryButton, 0, 0).apply {
            try {
                isLoading = getBoolean(R.styleable.PrimaryButton_isLoading, false)
            } finally {
                recycle()
            }
        }
        updateLoadingState()
    }

    fun setLoading(loading: Boolean) {
        isLoading = loading
        updateLoadingState()
    }

    private fun updateLoadingState() {
        isEnabled = !isLoading
        // Could add a progress indicator here
    }
}
```

```xml
<!-- res/values/attrs.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <declare-styleable name="PrimaryButton">
        <attr name="isLoading" format="boolean" />
    </declare-styleable>
</resources>
```

## Layout with Design System
```xml
<!-- res/layout/fragment_login.xml -->
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="@dimen/spacing_lg">

    <TextView
        android:id="@+id/titleText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/login_title"
        android:textAppearance="@style/TextAppearance.App.HeadlineLarge"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toTopOf="@id/subtitleText"
        app:layout_constraintVertical_chainStyle="packed" />

    <TextView
        android:id="@+id/subtitleText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="@dimen/spacing_sm"
        android:text="@string/login_subtitle"
        android:textAppearance="@style/TextAppearance.App.BodyLarge"
        android:textColor="?colorOnSurfaceVariant"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/titleText"
        app:layout_constraintBottom_toTopOf="@id/emailInput" />

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/emailInput"
        style="@style/Widget.App.TextInputLayout"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginTop="@dimen/spacing_xxl"
        android:hint="@string/email"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/subtitleText"
        app:layout_constraintBottom_toTopOf="@id/passwordInput">

        <com.google.android.material.textfield.TextInputEditText
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="textEmailAddress" />
    </com.google.android.material.textfield.TextInputLayout>

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/passwordInput"
        style="@style/Widget.App.TextInputLayout"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginTop="@dimen/spacing_md"
        android:hint="@string/password"
        app:endIconMode="password_toggle"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/emailInput"
        app:layout_constraintBottom_toTopOf="@id/loginButton">

        <com.google.android.material.textfield.TextInputEditText
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="textPassword" />
    </com.google.android.material.textfield.TextInputLayout>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/loginButton"
        style="@style/Widget.App.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginTop="@dimen/spacing_lg"
        android:text="@string/sign_in"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/passwordInput" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

## ViewModel Pattern
```kotlin
// ui/auth/LoginViewModel.kt
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            loginUseCase(email, password)
                .onSuccess { user ->
                    _uiState.update { it.copy(isLoading = false, isLoggedIn = true) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false, error = error.message) }
                }
        }
    }
}

data class LoginUiState(
    val isLoading: Boolean = false,
    val isLoggedIn: Boolean = false,
    val error: String? = null
)
```

## Fragment with ViewBinding
```kotlin
// ui/auth/LoginFragment.kt
@AndroidEntryPoint
class LoginFragment : Fragment(R.layout.fragment_login) {

    private var _binding: FragmentLoginBinding? = null
    private val binding get() = _binding!!

    private val viewModel: LoginViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentLoginBinding.bind(view)

        setupUI()
        observeState()
    }

    private fun setupUI() {
        binding.loginButton.setOnClickListener {
            val email = binding.emailInput.editText?.text.toString()
            val password = binding.passwordInput.editText?.text.toString()
            viewModel.login(email, password)
        }
    }

    private fun observeState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.uiState.collectLatest { state ->
                binding.loginButton.isEnabled = !state.isLoading
                state.error?.let { showError(it) }
                if (state.isLoggedIn) navigateToHome()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

## Key Rules

- ALWAYS use Material 3 theme and components
- ALWAYS define colors, dimensions, typography in resources
- ALWAYS use styles for component customization
- NEVER hardcode values in layouts
- Use ViewBinding (not findViewById or synthetic)
- Use ConstraintLayout for complex layouts
- Keep resources organized (colors, dimens, styles separate)
- Follow Material Design 3 guidelines
