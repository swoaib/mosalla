---
name: mosalla-splash-manager
description: Manage and update splash screen assets for the Mosalla app. Use this skill when updating the app logos or splash screens to ensure consistent sizing (768x768) and proper native splash generation.
---

# Mosalla Splash Manager

This skill documents the correct workflow and sizing for updating the splash screen in the Mosalla project.

## Logo Sizing

- **Target Size**: 768x768 pixels.
- **Original Logos**: `assets/icon/logo.png` (Light) and `assets/icon/logo_dark.png` (Dark).
- **Splash Logos**: `assets/icon/logo_splash.png` and `assets/icon/logo_dark_splash.png`.

## Update Workflow

Follow these steps when the main logos are updated or when the splash screen needs to be refreshed:

1.  **Sync Logos**: Copy the main logos to the splash logo files.
    ```bash
    cp assets/icon/logo.png assets/icon/logo_splash.png
    cp assets/icon/logo_dark.png assets/icon/logo_dark_splash.png
    ```

2.  **Resize for Splash**: Resize the splash logos to the project-standard 768x768 size using `sips`.
    ```bash
    sips -z 768 768 assets/icon/logo_splash.png assets/icon/logo_dark_splash.png
    ```

3.  **Regenerate Native Splash**: Run the `flutter_native_splash` generation command.
    ```bash
    /opt/homebrew/bin/flutter pub run flutter_native_splash:create
    ```

## Configuration Note

The `flutter_native_splash.yaml` file is configured to use the `_splash.png` versions for both standard splash and Android 12 icons to ensure consistency and proper centering.
