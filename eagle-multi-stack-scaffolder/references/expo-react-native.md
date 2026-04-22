# Expo React Native Reference

## Research Queries
- "Expo SDK 52 new features 2025 2026"
- "React Native best practices 2025"
- "Expo Router file-based routing"
- "NativeWind vs Tamagui vs Gluestack 2025"
- "React Native design system implementation"
- "React Native Material Design 3"
- "React Native component library comparison 2025"

## Package Manager
**Bun** - 10-25x faster installs, deterministic lockfile.

```bash
bunx create-expo-app@latest {app-name} --template tabs
cd {app-name}
bun install
```

## Design System Philosophy

Build your UI as a component library following atomic design:

```
Tokens → Primitives → Components → Patterns → Features → Screens
```

1. **Tokens**: Colors, typography, spacing, shadows (theme configuration)
2. **Primitives**: Box, Text, Pressable wrappers with theme support
3. **Components**: Buttons, inputs, cards (built from primitives)
4. **Patterns**: Forms, lists, navigation patterns
5. **Features**: Complete feature modules
6. **Screens**: Page-level compositions

## Project Structure

```
{app-name}/
├── app/                          # Expo Router pages
│   ├── _layout.tsx               # Root layout with providers
│   ├── index.tsx                 # Home (/)
│   ├── (tabs)/                   # Tab group
│   │   ├── _layout.tsx
│   │   ├── index.tsx
│   │   └── profile.tsx
│   ├── (auth)/                   # Auth group
│   │   ├── _layout.tsx
│   │   ├── login.tsx
│   │   └── register.tsx
│   └── [id].tsx                  # Dynamic route
├── src/
│   ├── design-system/
│   │   ├── tokens/
│   │   │   ├── colors.ts         # Color palette
│   │   │   ├── spacing.ts        # Spacing scale
│   │   │   ├── typography.ts     # Font styles
│   │   │   ├── shadows.ts        # Shadow presets
│   │   │   └── index.ts
│   │   ├── theme/
│   │   │   ├── theme.ts          # Theme configuration
│   │   │   ├── ThemeProvider.tsx
│   │   │   └── useTheme.ts
│   │   ├── primitives/
│   │   │   ├── Box.tsx           # Themed View
│   │   │   ├── Text.tsx          # Themed Text
│   │   │   └── Pressable.tsx     # Themed Pressable
│   │   ├── components/
│   │   │   ├── buttons/
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── IconButton.tsx
│   │   │   │   └── index.ts
│   │   │   ├── inputs/
│   │   │   │   ├── TextField.tsx
│   │   │   │   ├── Select.tsx
│   │   │   │   └── index.ts
│   │   │   ├── feedback/
│   │   │   │   ├── Toast.tsx
│   │   │   │   ├── Loading.tsx
│   │   │   │   └── index.ts
│   │   │   ├── cards/
│   │   │   │   ├── Card.tsx
│   │   │   │   └── index.ts
│   │   │   └── index.ts          # Barrel export
│   │   └── patterns/
│   │       ├── FormField.tsx
│   │       ├── ListItem.tsx
│   │       └── ScreenContainer.tsx
│   ├── features/
│   │   └── {feature}/
│   │       ├── components/
│   │       ├── hooks/
│   │       └── services/
│   ├── lib/
│   │   ├── api/
│   │   ├── storage/
│   │   └── i18n/
│   ├── hooks/
│   ├── stores/                   # Zustand stores
│   └── types/
├── assets/
├── app.json
├── eas.json
├── tailwind.config.js            # If using NativeWind
└── package.json
```

## UI Framework Options

### Option 1: NativeWind (Tailwind for React Native) - Recommended

Best for teams familiar with Tailwind CSS.

```bash
bun add nativewind tailwindcss
bunx tailwindcss init
```

```javascript
// tailwind.config.js
module.exports = {
  content: ["./app/**/*.{js,tsx}", "./src/**/*.{js,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          500: '#8b5cf6',
          600: '#7c3aed',
          700: '#6d28d9',
        },
        surface: {
          DEFAULT: '#ffffff',
          variant: '#f5f5f5',
        },
      },
      spacing: {
        'xs': '4px',
        'sm': '8px',
        'md': '16px',
        'lg': '24px',
        'xl': '32px',
      },
    },
  },
}
```

```tsx
// Usage
<View className="bg-surface rounded-xl p-md shadow-md">
  <Text className="text-lg font-semibold text-gray-900">Hello</Text>
  <Pressable className="bg-primary-600 px-lg py-sm rounded-lg active:bg-primary-700">
    <Text className="text-white font-medium">Button</Text>
  </Pressable>
</View>
```

### Option 2: Tamagui (Performance + Design System)

Best for complex apps needing performance and full design system.

```bash
bun add tamagui @tamagui/config
```

```tsx
// tamagui.config.ts
import { createTamagui } from 'tamagui'
import { config } from '@tamagui/config/v3'

export const tamaguiConfig = createTamagui(config)
```

### Option 3: Gluestack UI v2 (Material/Cupertino)

Best for Material Design 3 or iOS-native look.

```bash
bun add @gluestack-ui/themed @gluestack-style/react
```

### Option 4: React Native Paper (Material Design 3)

Best for Material Design purists.

```bash
bun add react-native-paper react-native-safe-area-context
```

```tsx
import { MD3LightTheme, PaperProvider } from 'react-native-paper';

const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#6750A4',
    secondary: '#625B71',
  },
};

export default function App() {
  return (
    <PaperProvider theme={theme}>
      <Navigation />
    </PaperProvider>
  );
}
```

## Design System Implementation

### Design Tokens
```typescript
// src/design-system/tokens/colors.ts
export const colors = {
  // Primary palette
  primary: {
    50: '#f5f3ff',
    100: '#ede9fe',
    200: '#ddd6fe',
    300: '#c4b5fd',
    400: '#a78bfa',
    500: '#8b5cf6',
    600: '#7c3aed',
    700: '#6d28d9',
    800: '#5b21b6',
    900: '#4c1d95',
  },

  // Neutral palette
  neutral: {
    50: '#fafafa',
    100: '#f5f5f5',
    200: '#e5e5e5',
    300: '#d4d4d4',
    400: '#a3a3a3',
    500: '#737373',
    600: '#525252',
    700: '#404040',
    800: '#262626',
    900: '#171717',
  },

  // Semantic colors
  semantic: {
    success: '#22c55e',
    warning: '#f59e0b',
    error: '#ef4444',
    info: '#3b82f6',
  },

  // Surface colors
  surface: {
    primary: '#ffffff',
    secondary: '#f5f5f5',
    tertiary: '#e5e5e5',
  },

  // Text colors
  text: {
    primary: '#171717',
    secondary: '#525252',
    tertiary: '#a3a3a3',
    inverse: '#ffffff',
  },
} as const;

// src/design-system/tokens/spacing.ts
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  '2xl': 48,
  '3xl': 64,
} as const;

// src/design-system/tokens/typography.ts
export const typography = {
  fontFamily: {
    regular: 'Inter-Regular',
    medium: 'Inter-Medium',
    semibold: 'Inter-SemiBold',
    bold: 'Inter-Bold',
  },
  fontSize: {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
  },
  lineHeight: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
  },
} as const;

// src/design-system/tokens/shadows.ts
import { Platform } from 'react-native';

export const shadows = {
  sm: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.05,
      shadowRadius: 2,
    },
    android: { elevation: 2 },
  }),
  md: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.1,
      shadowRadius: 6,
    },
    android: { elevation: 4 },
  }),
  lg: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 8 },
      shadowOpacity: 0.15,
      shadowRadius: 12,
    },
    android: { elevation: 8 },
  }),
} as const;
```

### Theme Provider
```tsx
// src/design-system/theme/theme.ts
import { colors, spacing, typography, shadows } from '../tokens';

export const lightTheme = {
  colors: {
    primary: colors.primary[600],
    primaryContainer: colors.primary[100],
    onPrimary: colors.text.inverse,
    onPrimaryContainer: colors.primary[900],

    secondary: colors.neutral[600],
    secondaryContainer: colors.neutral[100],

    background: colors.surface.primary,
    surface: colors.surface.primary,
    surfaceVariant: colors.surface.secondary,

    error: colors.semantic.error,
    success: colors.semantic.success,
    warning: colors.semantic.warning,

    text: colors.text.primary,
    textSecondary: colors.text.secondary,
    textTertiary: colors.text.tertiary,

    border: colors.neutral[200],
    borderFocused: colors.primary[500],
  },
  spacing,
  typography,
  shadows,
  borderRadius: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
    full: 9999,
  },
};

export const darkTheme = {
  ...lightTheme,
  colors: {
    ...lightTheme.colors,
    primary: colors.primary[400],
    background: colors.neutral[900],
    surface: colors.neutral[800],
    surfaceVariant: colors.neutral[700],
    text: colors.text.inverse,
    textSecondary: colors.neutral[300],
    border: colors.neutral[700],
  },
};

export type Theme = typeof lightTheme;

// src/design-system/theme/ThemeProvider.tsx
import React, { createContext, useContext, useState } from 'react';
import { useColorScheme } from 'react-native';
import { lightTheme, darkTheme, Theme } from './theme';

const ThemeContext = createContext<{
  theme: Theme;
  isDark: boolean;
  toggleTheme: () => void;
}>({
  theme: lightTheme,
  isDark: false,
  toggleTheme: () => {},
});

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const systemColorScheme = useColorScheme();
  const [isDark, setIsDark] = useState(systemColorScheme === 'dark');

  const theme = isDark ? darkTheme : lightTheme;

  return (
    <ThemeContext.Provider value={{ theme, isDark, toggleTheme: () => setIsDark(!isDark) }}>
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => useContext(ThemeContext);
```

### Reusable Button Component
```tsx
// src/design-system/components/buttons/Button.tsx
import React from 'react';
import { Pressable, Text, ActivityIndicator, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps {
  label: string;
  onPress?: () => void;
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  isDisabled?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
}

export function Button({
  label,
  onPress,
  variant = 'primary',
  size = 'md',
  isLoading = false,
  isDisabled = false,
  leftIcon,
  rightIcon,
  fullWidth = false,
}: ButtonProps) {
  const { theme } = useTheme();

  const getBackgroundColor = (pressed: boolean): string => {
    if (isDisabled) return theme.colors.surfaceVariant;
    switch (variant) {
      case 'primary':
        return pressed ? theme.colors.primaryContainer : theme.colors.primary;
      case 'secondary':
        return pressed ? theme.colors.secondaryContainer : theme.colors.secondary;
      case 'outline':
      case 'ghost':
        return pressed ? theme.colors.surfaceVariant : 'transparent';
      default:
        return theme.colors.primary;
    }
  };

  const getTextColor = (): string => {
    if (isDisabled) return theme.colors.textTertiary;
    switch (variant) {
      case 'primary':
        return theme.colors.onPrimary;
      case 'secondary':
        return theme.colors.onPrimary;
      case 'outline':
      case 'ghost':
        return theme.colors.primary;
      default:
        return theme.colors.onPrimary;
    }
  };

  const getHeight = (): number => {
    switch (size) {
      case 'sm': return 36;
      case 'md': return 44;
      case 'lg': return 52;
    }
  };

  const getPadding = (): number => {
    switch (size) {
      case 'sm': return theme.spacing.sm;
      case 'md': return theme.spacing.md;
      case 'lg': return theme.spacing.lg;
    }
  };

  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled || isLoading}
      style={({ pressed }) => [
        styles.container,
        {
          backgroundColor: getBackgroundColor(pressed),
          height: getHeight(),
          paddingHorizontal: getPadding(),
          borderRadius: theme.borderRadius.lg,
          borderWidth: variant === 'outline' ? 1 : 0,
          borderColor: theme.colors.primary,
        },
        fullWidth && styles.fullWidth,
      ]}
    >
      {isLoading ? (
        <ActivityIndicator color={getTextColor()} size="small" />
      ) : (
        <>
          {leftIcon}
          <Text style={[
            styles.label,
            {
              color: getTextColor(),
              fontSize: theme.typography.fontSize.base,
              fontFamily: theme.typography.fontFamily.semibold,
              marginLeft: leftIcon ? theme.spacing.sm : 0,
              marginRight: rightIcon ? theme.spacing.sm : 0,
            },
          ]}>
            {label}
          </Text>
          {rightIcon}
        </>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  fullWidth: {
    width: '100%',
  },
  label: {
    textAlign: 'center',
  },
});
```

### TextField Component
```tsx
// src/design-system/components/inputs/TextField.tsx
import React, { useState } from 'react';
import { View, TextInput, Text, StyleSheet, TextInputProps } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';

interface TextFieldProps extends TextInputProps {
  label?: string;
  error?: string;
  hint?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export function TextField({
  label,
  error,
  hint,
  leftIcon,
  rightIcon,
  ...props
}: TextFieldProps) {
  const { theme } = useTheme();
  const [isFocused, setIsFocused] = useState(false);

  const borderColor = error
    ? theme.colors.error
    : isFocused
    ? theme.colors.borderFocused
    : theme.colors.border;

  return (
    <View style={styles.container}>
      {label && (
        <Text style={[
          styles.label,
          {
            color: theme.colors.textSecondary,
            fontSize: theme.typography.fontSize.sm,
            fontFamily: theme.typography.fontFamily.medium,
            marginBottom: theme.spacing.xs,
          },
        ]}>
          {label}
        </Text>
      )}
      <View style={[
        styles.inputContainer,
        {
          backgroundColor: theme.colors.surfaceVariant,
          borderRadius: theme.borderRadius.lg,
          borderWidth: 2,
          borderColor,
          paddingHorizontal: theme.spacing.md,
        },
      ]}>
        {leftIcon && <View style={{ marginRight: theme.spacing.sm }}>{leftIcon}</View>}
        <TextInput
          style={[
            styles.input,
            {
              color: theme.colors.text,
              fontSize: theme.typography.fontSize.base,
              fontFamily: theme.typography.fontFamily.regular,
            },
          ]}
          placeholderTextColor={theme.colors.textTertiary}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          {...props}
        />
        {rightIcon && <View style={{ marginLeft: theme.spacing.sm }}>{rightIcon}</View>}
      </View>
      {(error || hint) && (
        <Text style={[
          styles.helperText,
          {
            color: error ? theme.colors.error : theme.colors.textTertiary,
            fontSize: theme.typography.fontSize.xs,
            marginTop: theme.spacing.xs,
          },
        ]}>
          {error || hint}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  label: {},
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 52,
  },
  input: {
    flex: 1,
    paddingVertical: 12,
  },
  helperText: {},
});
```

## Platform-Specific UI

### Adaptive Components (iOS Cupertino / Android Material)
```tsx
// src/design-system/components/adaptive/AdaptiveButton.tsx
import React from 'react';
import { Platform, Pressable, Text, StyleSheet } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';

interface AdaptiveButtonProps {
  label: string;
  onPress?: () => void;
}

export function AdaptiveButton({ label, onPress }: AdaptiveButtonProps) {
  const { theme } = useTheme();

  if (Platform.OS === 'ios') {
    // Cupertino-style button
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.iosButton,
          {
            backgroundColor: theme.colors.primary,
            opacity: pressed ? 0.8 : 1,
            borderRadius: 10, // iOS standard
          },
        ]}
      >
        <Text style={[styles.label, { color: theme.colors.onPrimary }]}>{label}</Text>
      </Pressable>
    );
  }

  // Material-style button
  return (
    <Pressable
      onPress={onPress}
      android_ripple={{ color: theme.colors.primaryContainer }}
      style={[
        styles.androidButton,
        {
          backgroundColor: theme.colors.primary,
          borderRadius: 20, // Material rounded
        },
      ]}
    >
      <Text style={[styles.label, { color: theme.colors.onPrimary }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  iosButton: {
    paddingVertical: 14,
    paddingHorizontal: 20,
    alignItems: 'center',
  },
  androidButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: 'center',
    elevation: 2,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
  },
});
```

## Essential Libraries

```bash
# UI Framework (choose one)
bun add nativewind tailwindcss              # Tailwind approach
# bun add react-native-paper                # Material Design 3
# bun add @gluestack-ui/themed              # Flexible UI kit

# State Management
bun add zustand @tanstack/react-query axios

# Forms & Validation
bun add react-hook-form zod @hookform/resolvers

# Navigation (built into Expo)
# expo-router is included

# Images & Icons
bun add expo-image                          # Optimized images
bun add @expo/vector-icons                  # Icon library
bun add lucide-react-native                 # Modern icons

# Animations
bun add react-native-reanimated moti        # Animations

# UI Utilities
bun add @gorhom/bottom-sheet                # Bottom sheets
bun add burnt                               # Native toasts
bun add react-native-gesture-handler        # Gestures

# Storage
bun add @react-native-async-storage/async-storage
bun add expo-secure-store                   # Secure storage
```

## Screen Example with Design System
```tsx
// app/(auth)/login.tsx
import { View, ScrollView } from 'react-native';
import { Stack } from 'expo-router';
import { useTheme } from '@/src/design-system/theme/ThemeProvider';
import { Text, Button, TextField, ScreenContainer } from '@/src/design-system/components';

export default function LoginScreen() {
  const { theme } = useTheme();

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <ScreenContainer>
        <ScrollView
          contentContainerStyle={{
            flexGrow: 1,
            padding: theme.spacing.lg,
            justifyContent: 'center',
          }}
        >
          <View style={{ marginBottom: theme.spacing.xl }}>
            <Text variant="h1" style={{ textAlign: 'center' }}>
              Welcome Back
            </Text>
            <Text variant="body" color="secondary" style={{ textAlign: 'center', marginTop: theme.spacing.sm }}>
              Sign in to continue
            </Text>
          </View>

          <View style={{ gap: theme.spacing.md }}>
            <TextField
              label="Email"
              placeholder="you@example.com"
              keyboardType="email-address"
              autoCapitalize="none"
            />
            <TextField
              label="Password"
              placeholder="Enter your password"
              secureTextEntry
            />
          </View>

          <Button
            label="Sign In"
            onPress={() => {}}
            fullWidth
            style={{ marginTop: theme.spacing.lg }}
          />

          <Button
            label="Create Account"
            variant="ghost"
            onPress={() => {}}
            fullWidth
            style={{ marginTop: theme.spacing.sm }}
          />
        </ScrollView>
      </ScreenContainer>
    </>
  );
}
```

## Setup Commands

```bash
# Create app
bunx create-expo-app@latest my-app --template tabs
cd my-app

# NativeWind setup
bun add nativewind tailwindcss
bunx tailwindcss init

# State & API
bun add zustand @tanstack/react-query axios

# Forms
bun add react-hook-form zod @hookform/resolvers

# UI essentials
bun add @gorhom/bottom-sheet burnt lucide-react-native
bun add react-native-reanimated react-native-gesture-handler

# Create design system structure
mkdir -p src/design-system/{tokens,theme,primitives,components/{buttons,inputs,cards,feedback},patterns}
mkdir -p src/features src/lib/{api,storage} src/hooks src/stores src/types

# Run
bun start
```

## Key Rules

1. **ALWAYS implement a design system** - Don't scatter styles across components
2. **ALWAYS use design tokens** - Never hardcode colors, spacing, or typography
3. **ALWAYS create reusable components** - Build once, use everywhere
4. **Choose ONE UI framework** - NativeWind, Paper, Tamagui, or custom
5. **Consider platform differences** - iOS and Android have different UX conventions
6. **Use proper component variants** - primary, secondary, outline, ghost, etc.
7. **Support dark mode from day one** - Build it into your theme
8. **Keep components small and composable** - Single responsibility principle
