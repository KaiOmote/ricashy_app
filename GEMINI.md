# Project: Finance Tracking App

## 1. Project Overview

*   **Purpose**: A desktop-first finance tracking application built with Flutter. It is designed for users who want to meticulously track their finances through a simple, intuitive, and non-overwhelming user interface.
*   **Target Audience**: Users who seek detailed financial tracking and insights without a steep learning curve.
*   **Core Features**:
    *   Expense and Income tracking (both recurring and non-recurring).
    *   Budget creation and management.
    *   Transaction categorization.
    *   Monthly spending comparisons by category.
    *   Multiple reporting options with various visuals (e.g., pie charts, bar graphs, line graphs).

## 2. Technical Stack

*   **Framework**: [Flutter](https://flutter.dev/) - A cross-platform UI toolkit for building natively compiled applications.
*   **Language**: [Dart](https://dart.dev/)
*   **State Management**: [Riverpod](https://riverpod.dev/) - A reactive state management and dependency injection framework for Dart and Flutter applications.
*   **Key Packages**:
    *   `flutter_riverpod`: The core package for using Riverpod with Flutter.
    *   `fl_chart`: A powerful library for creating charts and graphs.
    *   `intl`: For internationalization and localization, including date and number formatting.
    *   `path_provider`: To locate standard filesystem locations.
    *   `drift`: For local database storage.

## 3. Project Structure

The project will follow a feature-based architecture to ensure scalability and maintainability.

```
finance_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── src/
│   │   ├── common_widgets/         # Reusable UI components
│   │   ├── features/               # Feature-based modules
│   │   │   ├── budgeting/
│   │   │   ├── dashboard/
│   │   │   ├── reports/
│   │   │   └── transactions/
│   │   ├── data/                   # Data layer (database, repositories)
│   │   │   ├── local_database/
│   │   │   └── repositories/
│   │   ├── domain/                 # Business logic and entities
│   │   │   ├── models/             # Data models
│   │   │   └── providers/          # Riverpod providers
│   │   └── routing/                # Navigation and routing logic
│   └── utils/                      # Utility functions and constants
├── test/                           # Automated tests
├── pubspec.yaml                    # Project dependencies
├── README.md
├── PRD.md                          # Product Requirements Document
├── PLAN.md                         # Detailed development plan
└── GEMINI.md                       # Core project knowledge base
```

## 4. Coding Conventions & Best Practices

*   **State Management**: All application state will be managed using Riverpod. We will follow the official best practices, such as defining providers in the `lib/src/domain/providers` directory and keeping them immutable.
*   **File Naming**: All files will use `snake_case.dart` (e.g., `home_screen.dart`).
*   **Code Formatting**: Code will be formatted using `dart format .` to ensure consistency with the official Dart style guide.
*   **UI Design**: The application will follow the detailed guidelines in the "UI/UX Style Guide" section of this document. The core principles are ease of use, clarity, and accessibility.
*   **Immutability**: Data models and states will be immutable to ensure predictability and prevent side effects.
*   **Testing**: The project will include a suite of automated tests, including unit tests for business logic (in providers) and widget tests for UI components.
*   **Iterative Development**: After each significant step or task, the project must be tested to ensure it runs correctly. This involves running the app using `flutter run` and executing any relevant automated tests to verify that no regressions have been introduced.

## 5. UI/UX Style Guide

### 5.1. Adaptive Layouts & Responsiveness
*   **Multi-Pane Layout**: The app's primary screens must utilize multi-pane layouts to take advantage of wide desktop screens. For example, a transactions screen should have a left-hand list pane and a right-hand detail pane.
*   **Resizing**: The UI must be fully responsive to window resizing, with no overflow errors. Layouts should be dynamic and adjust gracefully to different aspect ratios and resolutions.
*   **Breakpoints**: The app should be designed with specific breakpoints (e.g., narrow, medium, wide) to adjust the layout and component visibility. The design should prioritize usability at each breakpoint.

### 5.2. Color System
*   **Light & Dark Themes**: The application must support both a light and a dark theme, allowing the user to switch manually.
*   **System Theme Integration**: The app must respect the user's system-level theme preference (light or dark mode) on Windows, macOS, and Linux by default.
*   **Defined Palettes**: A clear primary and secondary color palette must be defined to ensure visual consistency across all components.

### 5.3. Typography
*   **Font Family**: A consistent and highly readable sans-serif font must be used for all text. The font should be clear on various desktop monitors.
*   **Scaling**: Text sizes must be defined using the Material 3 typography system and should scale with the user's system-level text scaling settings for accessibility.

### 5.4. Component Design & Interaction
*   **Visual Density**: Components should have a less dense visual layout compared to mobile designs, with more padding and spacing to accommodate mouse clicks and reduce visual clutter.
*   **Tooltips**: All icons and less obvious UI elements must have tooltips that appear on mouse hover, providing clear information on their function.
*   **Navigation**: Primary navigation should use a NavigationRail or a similar component on the left side of the screen for persistence and easy access.
*   **Input Modalities**: The app must be fully functional using both mouse and keyboard controls. This includes:
    *   **Focus**: Clear focus states for buttons and text fields.
    *   **Shortcuts**: Keyboard shortcuts for common actions (e.g., Ctrl+S to save, Ctrl+T to add a new transaction).

### 5.5. Accessibility
*   **Color Contrast**: All text and UI elements must meet WCAG 2.1 AA standards for color contrast.
*   **Screen Reader Support**: All interactive and informational elements must have semantic labels to be properly read by screen readers.

## 6. Important Links

*   [Flutter Documentation](https://docs.flutter.dev/)
*   [Dart Documentation](https://dart.dev/guides)
*   [Riverpod Documentation](https://riverpod.dev/)
*   [Effective Dart Style Guide](https://dart.dev/effective-dart)
*   [Material Design 3](https://m3.material.io/)