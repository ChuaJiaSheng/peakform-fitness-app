# PeakForm Fitness App

A Flutter fitness-tracking coursework app combining user profiles, exercise records, water-intake logging, fitness information, and workout planning. Firebase provides authentication and stored user data; external APIs supply fitness and workout-plan responses.

**Stack:** Flutter/Dart · Firebase Authentication · Cloud Firestore · HTTP APIs · `fl_chart`

## Features

- Sign-in/registration interface and editable fitness profiles.
- Exercise records with add, list, and deletion flows.
- Water-intake entries.
- Workout-plan requests, saved plans, and plan display.
- Home-screen summaries and animated/chart-based widgets.
- BMI and other fitness information obtained through the original fitness integration.

## Source guide

| Location | Responsibility |
| --- | --- |
| [lib/main.dart](lib/main.dart) | Application startup and Firebase initialisation |
| [lib/screens/](lib/screens/) | Login, home, profile, exercise, water, and workout screens |
| [lib/models/](lib/models/) | Fitness user, BMI, exercise, water, and workout data |
| [lib/utilities/](lib/utilities/) | HTTP requests and Firestore helpers |
| [lib/widgets/](lib/widgets/), [lib/theme/](lib/theme/) | Shared navigation, styling, and UI elements |
| [config/api-keys.example.json](config/api-keys.example.json) | Local API configuration template |
| `android/`, `ios/` | Native platform projects |

The Dart package name is `fitness`.

## Local setup

1. Use a Flutter SDK compatible with the Dart constraint `^3.5.3` in [pubspec.yaml](pubspec.yaml), plus the Android or iOS development tools needed for your device.
2. Run `flutter pub get` from the repository root.
3. Configure **your own Firebase project** for the selected platforms. Generate `lib/firebase_options.dart` and the platform Firebase configuration files; they are deliberately omitted and ignored here.
4. Enable the authentication providers required by your setup and configure Firestore rules that restrict each user's data appropriately. No deployed ruleset is supplied by this repository.
5. Copy the API template:

   ```sh
   cp config/api-keys.example.json config/api-keys.local.json
   ```

   On PowerShell, use `Copy-Item` instead of `cp` if needed.

6. Fill in `FITNESS_API_KEY` and `WORKOUT_API_KEY` with your own service values, then run:

   ```sh
   flutter run --dart-define-from-file=config/api-keys.local.json
   ```

The values are read with `String.fromEnvironment`; they are build-time Dart definitions, not automatically loaded runtime environment variables.

## Stored data and services

The source uses Firestore collections including `fitnessUsers`, `exercises`, `water_intake`, and `workoutPlans`. Review the model and query fields before creating data or writing rules. Firebase project configuration must be generated locally.

The two external integrations use RapidAPI fitness and workout-planner endpoints. API keys embedded in a mobile client can be extracted from a built app; local ignored files keep them out of Git but are not a production secret-storage design.

## Team

Chua Jia Sheng and Pyie Sone.
