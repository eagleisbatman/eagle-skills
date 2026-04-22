# SwiftUI Reference

## Research Queries
- "SwiftUI best practices 2025 2026"
- "SwiftUI design system implementation"
- "SwiftUI custom component library"
- "SwiftUI project structure large apps"
- "SwiftUI recommended architecture MVVM TCA"
- "Swift Package Manager vs CocoaPods 2025"

## Package Manager
**Swift Package Manager (SPM)** - Always preferred unless library only supports CocoaPods.

## Design System Philosophy

Build your UI as a component library:

```
Tokens → Styles → Components → Patterns → Features → Screens
```

1. **Tokens**: Colors, typography, spacing (extensions on SwiftUI types)
2. **Styles**: ViewModifiers and ButtonStyles
3. **Components**: Reusable View structs
4. **Patterns**: Common UI patterns (forms, lists)
5. **Features**: Complete feature modules
6. **Screens**: Full screen compositions

## Project Structure

```
{AppName}/
├── App/
│   ├── {AppName}App.swift
│   └── ContentView.swift
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift            # Color extensions
│   │   ├── Typography.swift        # Font styles
│   │   ├── Spacing.swift           # Spacing constants
│   │   └── Shadows.swift           # Shadow definitions
│   ├── Theme/
│   │   ├── Theme.swift             # Theme configuration
│   │   └── ThemeManager.swift      # Theme provider
│   ├── Styles/
│   │   ├── ButtonStyles.swift      # Custom button styles
│   │   ├── TextFieldStyles.swift   # Custom text field styles
│   │   └── ViewModifiers.swift     # Reusable modifiers
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── IconButton.swift
│   │   ├── Inputs/
│   │   │   ├── AppTextField.swift
│   │   │   └── SearchField.swift
│   │   ├── Cards/
│   │   │   ├── BaseCard.swift
│   │   │   └── InfoCard.swift
│   │   └── Feedback/
│   │       ├── LoadingView.swift
│   │       └── ToastView.swift
│   └── Patterns/
│       ├── FormField.swift
│       └── ListRow.swift
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   └── Components/
│   │   ├── ViewModels/
│   │   │   └── HomeViewModel.swift
│   │   └── Models/
│   ├── Auth/
│   │   └── ...
│   └── Settings/
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   └── Endpoints.swift
│   ├── Storage/
│   │   └── KeychainManager.swift
│   └── Services/
├── Shared/
│   ├── Extensions/
│   ├── Utilities/
│   └── Models/
├── Resources/
│   └── Assets.xcassets
└── Tests/
```

## Design Token Implementation

### Colors
```swift
// DesignSystem/Tokens/Colors.swift
import SwiftUI

extension Color {
    // Primary palette
    static let primaryLight = Color(hex: "#F5F3FF")
    static let primary100 = Color(hex: "#EDE9FE")
    static let primary500 = Color(hex: "#8B5CF6")
    static let primary600 = Color(hex: "#7C3AED")
    static let primary700 = Color(hex: "#6D28D9")

    // Semantic colors
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    static let info = Color(hex: "#3B82F6")

    // Surface colors
    static let surfacePrimary = Color(hex: "#FFFFFF")
    static let surfaceSecondary = Color(hex: "#F5F5F5")
    static let surfaceTertiary = Color(hex: "#E5E5E5")

    // Text colors
    static let textPrimary = Color(hex: "#171717")
    static let textSecondary = Color(hex: "#525252")
    static let textTertiary = Color(hex: "#A3A3A3")

    // Dark mode variants
    static let darkSurface = Color(hex: "#1C1C1E")
    static let darkSurfaceSecondary = Color(hex: "#2C2C2E")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### Spacing
```swift
// DesignSystem/Tokens/Spacing.swift
import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Convenience extension
extension View {
    func padding(_ spacing: CGFloat) -> some View {
        self.padding(spacing)
    }
}
```

### Typography
```swift
// DesignSystem/Tokens/Typography.swift
import SwiftUI

enum AppFont {
    static let displayLarge = Font.system(size: 57, weight: .regular)
    static let displayMedium = Font.system(size: 45, weight: .regular)
    static let headlineLarge = Font.system(size: 32, weight: .semibold)
    static let headlineMedium = Font.system(size: 28, weight: .semibold)
    static let titleLarge = Font.system(size: 22, weight: .medium)
    static let titleMedium = Font.system(size: 16, weight: .medium)
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let caption = Font.system(size: 12, weight: .regular)
}

// Text style modifier
struct AppTextStyle: ViewModifier {
    enum Style {
        case displayLarge, displayMedium
        case headlineLarge, headlineMedium
        case titleLarge, titleMedium
        case bodyLarge, bodyMedium
        case labelLarge, labelMedium
        case caption
    }

    let style: Style
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }

    private var font: Font {
        switch style {
        case .displayLarge: return AppFont.displayLarge
        case .displayMedium: return AppFont.displayMedium
        case .headlineLarge: return AppFont.headlineLarge
        case .headlineMedium: return AppFont.headlineMedium
        case .titleLarge: return AppFont.titleLarge
        case .titleMedium: return AppFont.titleMedium
        case .bodyLarge: return AppFont.bodyLarge
        case .bodyMedium: return AppFont.bodyMedium
        case .labelLarge: return AppFont.labelLarge
        case .labelMedium: return AppFont.labelMedium
        case .caption: return AppFont.caption
        }
    }
}

extension View {
    func textStyle(_ style: AppTextStyle.Style, color: Color = .textPrimary) -> some View {
        modifier(AppTextStyle(style: style, color: color))
    }
}
```

## Component Implementation

### Primary Button
```swift
// DesignSystem/Components/Buttons/PrimaryButton.swift
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var size: ButtonSize = .medium
    var fullWidth: Bool = false

    enum ButtonSize {
        case small, medium, large

        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.sm
            case .medium: return Spacing.md
            case .large: return Spacing.lg
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(AppFont.labelLarge)
                        .foregroundColor(.white)
                }
            }
            .frame(height: size.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, size.horizontalPadding)
            .background(isDisabled ? Color.textTertiary : Color.primary600)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

// Button styles for more flexibility
struct PrimaryButtonStyle: ButtonStyle {
    var size: PrimaryButton.ButtonSize = .medium

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.labelLarge)
            .foregroundColor(.white)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(configuration.isPressed ? Color.primary700 : Color.primary600)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.labelLarge)
            .foregroundColor(.primary600)
            .padding(.horizontal, Spacing.md)
            .frame(height: 44)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary600, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.labelLarge)
            .foregroundColor(.primary600)
            .padding(.horizontal, Spacing.md)
            .frame(height: 44)
            .background(configuration.isPressed ? Color.primary100 : Color.clear)
            .cornerRadius(12)
    }
}
```

### App TextField
```swift
// DesignSystem/Components/Inputs/AppTextField.swift
import SwiftUI

struct AppTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var leadingIcon: Image? = nil
    var trailingIcon: Image? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Label
            Text(label)
                .font(AppFont.labelMedium)
                .foregroundColor(.textSecondary)

            // Input field
            HStack(spacing: Spacing.sm) {
                if let icon = leadingIcon {
                    icon
                        .foregroundColor(.textTertiary)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(AppFont.bodyLarge)
                .foregroundColor(.textPrimary)

                if let icon = trailingIcon {
                    icon
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: 52)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
            )
            .focused($isFocused)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(AppFont.caption)
                    .foregroundColor(.error)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return .error
        }
        return isFocused ? .primary600 : .clear
    }
}
```

### Card Component
```swift
// DesignSystem/Components/Cards/BaseCard.swift
import SwiftUI

struct BaseCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.md

    init(padding: CGFloat = Spacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.surfacePrimary)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
```

## View Modifiers
```swift
// DesignSystem/Styles/ViewModifiers.swift
import SwiftUI

// Card style modifier
struct CardModifier: ViewModifier {
    var padding: CGFloat = Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfacePrimary)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(padding: CGFloat = Spacing.md) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

// Screen container modifier
struct ScreenContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.surfaceSecondary)
    }
}

extension View {
    func screenContainer() -> some View {
        modifier(ScreenContainerModifier())
    }
}
```

## Architecture: MVVM

### ViewModel
```swift
// Features/Auth/ViewModels/LoginViewModel.swift
import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case success
        case error(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published var email: String = ""
    @Published var password: String = ""

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    func login() async {
        state = .loading
        do {
            try await authService.login(email: email, password: password)
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

### Screen with Design System
```swift
// Features/Auth/Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("Welcome Back")
                        .textStyle(.headlineLarge)
                    Text("Sign in to continue")
                        .textStyle(.bodyLarge, color: .textSecondary)
                }
                .padding(.top, Spacing.xxl)

                // Form
                VStack(spacing: Spacing.md) {
                    AppTextField(
                        label: "Email",
                        text: $viewModel.email,
                        placeholder: "you@example.com",
                        keyboardType: .emailAddress,
                        leadingIcon: Image(systemName: "envelope")
                    )

                    AppTextField(
                        label: "Password",
                        text: $viewModel.password,
                        placeholder: "Enter your password",
                        isSecure: true,
                        leadingIcon: Image(systemName: "lock")
                    )
                }
                .padding(.top, Spacing.lg)

                // Actions
                VStack(spacing: Spacing.sm) {
                    PrimaryButton(
                        title: "Sign In",
                        action: { Task { await viewModel.login() } },
                        isLoading: viewModel.state == .loading,
                        isDisabled: !viewModel.isFormValid,
                        fullWidth: true
                    )

                    Button("Create Account") {
                        // Navigate to signup
                    }
                    .buttonStyle(GhostButtonStyle())
                }
                .padding(.top, Spacing.lg)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
        }
        .screenContainer()
        .navigationBarHidden(true)
    }
}
```

## Essential Libraries

| Category | Package | Notes |
|----------|---------|-------|
| Networking | Alamofire or URLSession | Prefer native for simple apps |
| Images | Kingfisher | SwiftUI native |
| DI | Factory | Lightweight |
| Database | SwiftData (iOS 17+) | Apple native |
| Analytics | Firebase | Industry standard |
| Async | Swift Concurrency | Native async/await |

## Setup Commands

```bash
# Via Xcode:
# File > New > Project > iOS > App > SwiftUI

# Create design system structure in Xcode:
# - DesignSystem/Tokens/
# - DesignSystem/Theme/
# - DesignSystem/Styles/
# - DesignSystem/Components/Buttons/
# - DesignSystem/Components/Inputs/
# - DesignSystem/Components/Cards/
# - DesignSystem/Patterns/
# - Features/{feature}/Views/
# - Features/{feature}/ViewModels/

# Add packages:
# File > Add Package Dependencies > Enter GitHub URL
```

## Key Rules

1. **ALWAYS implement design tokens** - Colors, spacing, typography as constants
2. **ALWAYS create reusable components** - Buttons, text fields, cards
3. **ALWAYS use ViewModifiers** - For common styling patterns
4. **ALWAYS use ButtonStyle** - For consistent button appearances
5. **Views end with `View`**: HomeView, LoginView
6. **ViewModels end with `ViewModel`**: HomeViewModel
7. **Use `@StateObject` for owned state**, `@ObservedObject` for passed state
8. **Extract subviews as computed properties** or separate components
9. **Use `.task { }` for async loading**
10. **Support dark mode** - Use semantic colors
