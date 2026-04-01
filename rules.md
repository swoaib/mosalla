# Mosalla Architecture Guidelines

This codebase follows a strict decoupling pattern for improved maintainability.

## 1. Project Structure

- **`lib/repositories/`**: This layer is strictly for Data access, such as Firebase / Firestore. **No UI or Provider** should directly invoke `FirebaseFirestore` or `FirebaseAuth`. They must interface through methods exposed by the repository classes.
- **`lib/providers/`**: Handles the app state and business logic using `ChangeNotifier`. Providers inject Repositories via their constructors.
- **`lib/services/`**: Holds independent services (like AI configuration and `flutter_dotenv` initialization).
- **`lib/model/`**: Contains typed data models (e.g., `MosallaData`, `PrayerData`) with static serialization/deserialization logic.
- **`lib/pages/`**: Only contains structural UI. Needs access to `providers` to show state.
- **`lib/widgets/`**: Reusable component UI.

## 2. Core Constraints

1. **API Keys and Secrets**: Secrets MUST be pulled from a `.env` file via `flutter_dotenv`. Never hardcode an API key. 
2. **Subscriptions**: All premium logic and features should be localized dynamically via ARB files through `PremiumService`.
3. **Theming & Layout**: Use `Theme.of(context)` for all text and colors rather than hardcoded `.purple` or `.white` values. Ensure compatibility across Dark Mode.
4. **Stream Management**: A provider listening to snapshot streams from a repository MUST always cleanly cancel `StreamSubscription` objects in its `dispose()` method.
