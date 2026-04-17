---
name: flutter-ios-widget
description: Comprehensive workflow and troubleshooting guide for building and integrating native iOS widgets (Home Screen & Lock Screen) in a Flutter application. Use this skill whenever a user requests adding or debugging iOS widgets, home_widget integration, Xcode build cycle errors, or iOS 16/17/18 widget specific compilation bugs.
---

# Flutter iOS Widget Guide

Creating a native iOS widget in a Flutter app using the `home_widget` plugin is fraught with highly specific Xcode and Swift compiler bugs. Follow these instructions precisely to avoid crippling build errors.

## 1. Flutter Setup (`home_widget`)
1. Add `home_widget` to `pubspec.yaml`.
2. Configure your Flutter state (e.g. Provider) to push data to UserDefaults using `HomeWidget.saveWidgetData` and `HomeWidget.updateWidget()`.
3. **CRITICAL:** You must configure an App Group. In your `main.dart` inside `main()`, ensure you call `HomeWidget.setAppGroupId('group.<your_bundle_id>');` before `runApp()`.

## 2. Xcode Initial Setup
1. Open `ios/Runner.xcworkspace` in Xcode.
2. In the Runner Target > Signing & Capabilities, add the **App Groups** capability and create `group.<your_bundle_id>`.
3. Go to File > New > Target... > **Widget Extension**.
4. Important: Uncheck **"Include Configuration App Intent"** and **"Include Live Activity"** unless explicitly asked.
5. In the new Widget Target > Signing & Capabilities, add the **App Groups** capability and select the exact same `group.<your_bundle_id>`.

## 3. Resolving Xcode & Compilation Bugs (The "Gotchas")

### Bug A: Duplicate `@main` error
Modern Xcode creates a `{WidgetName}Bundle.swift` file containing the `@main` attribute. If you provide a single `.swift` file with your Widget code that also includes `@main`, compilation will fail.
**Fix:** Remove the `@main` annotation from your custom Widget struct file, leaving it ONLY in the `Bundle.swift` file.

### Bug B: "buildExpressions are only available in iOS 18"
1. **Control Widget issue:** Xcode 16 generates an iOS 18-exclusive `{WidgetName}Control.swift` file for Control Center widgets. If your deployment target is iOS 16/17, this file will crash the compiler.
**Fix:** Empty the contents of `{WidgetName}Control.swift` completely (leaving a blank file so Xcode doesn't complain about a missing file), and remove the reference to `WidgetControl()` inside the `{WidgetName}Bundle.swift`.
2. **ViewBuilder confusion:** If Swift fails to parse an `if/else` statement regarding `@Environment(\.widgetFamily)`, it will incorrectly throw this iOS 18 error. 
**Fix:** Break your views into distinct explicit variables (`var lockScreenView: some View`, etc) rather than complex nested conditionals inside the main `body`.

### Bug C: Cycle inside Runner (CocoaPods)
When adding the Widget Extension, Xcode places the new build phase in the wrong order, breaking CocoaPods.
**Fix:** In Xcode, go to the Runner target > Build Phases. Drag **Embed Foundation Extensions** (or Embed App Extensions) UP so it is ABOVE `Thin Binary` and all `[CP]` CocoaPods scripts.

### Bug D: "Timed out waiting for CONFIGURATION_BUILD_DIR to update"
Flutter CLI has a famous bug where `flutter run` times out when installing an iOS app containing a new App Extension.
**Fix:** You **MUST** install the app using the Play button directly inside Xcode for the very first time. Xcode handles the complex provisioning profile sync that the Flutter CLI fails at. Once installed via Xcode, VSCode/Flutter CLI will work normally for hot reloads.

### Bug E: "The widget background view is missing / containerBackground"
Starting in iOS 17, Apple heavily enforces that *all* widgets (even transparent Lock Screen widgets) use `.containerBackground(for: .widget)`. If you use a `ZStack` background, it will render blank or broken.
**Fix:** Implement a backwards-compatible View extension:
```swift
extension View {
    @ViewBuilder
    func widgetBackground<V: View>(_ backgroundView: V) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            self.background(backgroundView)
        }
    }
}
```
Apply `.widgetBackground(Color.clear)` to your Lock Screen view, and `.widgetBackground(Color(UIColor.systemBackground))` to your Home Screen view.

## 4. UI Design Rules & Limitations
- **Circular Lock Screen Widgets** (`.accessoryCircular`): When using `ProgressView(timerInterval:...)`, Apple rigidly locks the center of the circle to the live ticking countdown string. You **cannot** seamlessly inject custom text (like names or exact times) inside the center of the circle without creating an illegible overlapping mess. If a user wants text strictly inside the circle, you must switch to a static `Gauge` widget, but you will lose the butter-smooth 60fps ticking countdown animation.
- **Preview Crashes:** Always include `.systemMedium` (or other standard sizes) in `.supportedFamilies([...])` if you haven't written explicit fallback logic, because Xcode's default run/preview script often attempts to forcefully launch a Medium widget. If the system rejects it because it's missing from `supportedFamilies`, the simulator launch will crash.
