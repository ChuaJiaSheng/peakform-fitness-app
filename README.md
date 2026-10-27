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

## Reproduce on Android

### 1. Install the prerequisites

Use Git, Flutter with Dart compatible with `^3.5.3`, Android Studio/Android SDK tools, and an Android device or emulator. The app declares `minSdk = 23`; newer dependencies may impose a higher requirement, so retain `pubspec.lock` for the initial attempt. The repository records Flutter stable revision `603104015dd692ea3403755b55d07813d5cf8965` in `.metadata`, but does not pin an installed toolchain manager configuration.

Run `flutter doctor -v` and resolve Android toolchain/device problems before building the app. iOS additionally requires macOS/Xcode, Apple signing configuration, and iOS Firebase registration; the Android procedure below does not complete that separate setup.

```sh
git clone https://github.com/ChuaJiaSheng/peakform-fitness-app.git
cd peakform-fitness-app
flutter --version
flutter doctor -v
flutter pub get
```

### 2. Configure your own Firebase project

Install the [Firebase CLI](https://firebase.google.com/docs/cli) and the FlutterFire CLI. From this repository's root:

```sh
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Select your Firebase project and **Android**. The Android application ID in this source is `com.example.fitness`. Confirm that the generated Firebase Android app matches it. If the FlutterFire executable is not found, add Dart's global executable directory to PATH and reopen the terminal.

Confirm that `lib/firebase_options.dart` and `android/app/google-services.json` exist. If the Android JSON is absent, download it from that Firebase Android app's settings and save it at the path above. Follow the [official Flutter setup guide](https://firebase.google.com/docs/flutter/setup) for platform configuration.

In Firebase Console:

1. Enable **Authentication → Email/Password**, which is the provider used by `LoginScreen`.
2. Create a Cloud Firestore database for the project.
3. Configure rules for the collection ownership used by the app. The following starting rules restrict profile documents by document ID and the three record collections by their `userId` field. Publish them in the rules editor for your own demo project, then verify access with your test accounts. They do not provide full field/type validation.

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /fitnessUsers/{uid} {
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;
    }
    match /{collection}/{id} {
      function recordCollection() {
        return collection in ['exercises', 'water_intake', 'workoutPlans'];
      }
      allow read, delete: if recordCollection() && request.auth != null
                         && resource.data.userId == request.auth.uid;
      allow create: if recordCollection() && request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update: if recordCollection() && request.auth != null
                    && resource.data.userId == request.auth.uid
                    && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

The water-intake query combines `userId` equality with a `timestamp` range. If Firestore returns an index-required error, follow its index-creation link for your project, create the requested composite index, and wait until it is ready before retrying. The repository does not include a pre-deployed database or index configuration.

### 3. Configure the fitness APIs

Obtain access to the RapidAPI fitness and workout-planner endpoints named in `lib/utilities/api_calls.dart` and `lib/utilities/workout_planner_api.dart`. API access and any provider subscription are managed in your own account.

```sh
cp config/api-keys.example.json config/api-keys.local.json
```

On PowerShell, `Copy-Item config/api-keys.example.json config/api-keys.local.json` is equivalent. Edit the new file:

```json
{
  "FITNESS_API_KEY": "YOUR_FITNESS_API_KEY",
  "WORKOUT_API_KEY": "YOUR_WORKOUT_API_KEY"
}
```

Replace both placeholders. The API host headers are already in the source. Authentication/exercise storage and provider-dependent BMI/workout generation are separate capabilities; a valid Firebase setup does not grant API access.

### 4. Run and check the result

Start an emulator or connect a device with USB debugging, then:

```sh
flutter devices
flutter run --dart-define-from-file=config/api-keys.local.json
```

Choose the Android device if prompted, or add `-d DEVICE_ID` using an ID from `flutter devices`.

**Expected first-run flow:** a sign-in/registration interface appears. Register a test email/password, complete the display-name/profile prompts, and enter the fitness details. Saving API-dependent profile information requires the fitness endpoint to respond successfully.

**Functional checks:** add Running for 45 minutes; its stored exercise should have duration `45` and the source's simple calorie estimate `315`. Log `250` ml of water and check that the displayed total increases by 250. Confirm that new documents in Firestore have the signed-in account's `userId`. Try generating a workout plan only after API access is configured. Sign out and use another test account to check that the first account's records are not readable.

### Troubleshooting

| Symptom | Check |
| --- | --- |
| Missing `firebase_options.dart` or Google services JSON | Re-run FlutterFire configuration for the intended Firebase project and Android app |
| Authentication provider disabled | Enable Email/Password in Firebase Authentication |
| Firestore permission denied | Confirm sign-in, document ownership fields, database, and rules |
| Index-required error | Create the index identified by the Firestore error and wait for it to be ready |
| API 401/403 or generation error | Check the correct key, endpoint access, host header, and provider response |
| No Android device | Start the emulator/connect the device, then re-run `flutter devices` |
| SDK/Gradle/package incompatibility | Compare the installed Flutter/Java/Android tools with the recorded project configuration; retain the lockfile before changing dependency versions |

The source and these setup steps are not a guarantee that historical external endpoints remain available. A provider endpoint/model change may require a corresponding code update.

## Stored data and services

The source uses Firestore collections including `fitnessUsers`, `exercises`, `water_intake`, and `workoutPlans`. Review the model and query fields before creating data or writing rules. Firebase project configuration must be generated locally.

The two external integrations use RapidAPI fitness and workout-planner endpoints. API keys embedded in a mobile client can be extracted from a built app; local ignored files keep them out of Git but are not a production secret-storage design.

## Team

Chua Jia Sheng and Pyie Sone.
