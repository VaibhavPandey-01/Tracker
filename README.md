# Safe-to-Spend Expense Tracker

A **production-grade, minimal expense tracker** built with Flutter + Firebase. The core idea is **balance partitioning**: divide your bank balance into Locked (savings) and Spendable (daily use), then track every expense against only the spendable portion.

```
Balance = ₹8,000 → Locked = ₹6,000 → Spendable = ₹2,000
Every expense deducts from Spendable only.
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Android-first, platform-agnostic) |
| State management | Riverpod 2.x |
| Backend | Firebase Firestore + Auth |
| Navigation | GoRouter |
| Charts | fl_chart |
| Typography | Google Fonts (Outfit) |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase config (replace with your project's)
├── core/
│   ├── constants/                 # Colors, text styles, theme
│   └── utils/                    # Currency & date formatters
├── data/
│   ├── datasources/               # FirestoreDatasource (all Firestore calls)
│   └── repositories/              # AuthRepository, FundStateRepository, LedgerRepository
├── domain/
│   ├── enums/                     # EntryType, ExpenseCategory
│   ├── models/                    # FundState, LedgerEntry
│   └── logic/                    # SpendableCalculator (pure, testable)
└── presentation/
    ├── app_router.dart            # GoRouter config with auth-gating
    ├── providers/                 # Riverpod providers
    ├── screens/                   # All screens
    └── widgets/                   # BalanceCard, LedgerListItem
```

---

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → name it (e.g., `safe-to-spend`)
3. Enable Google Analytics (optional)

### 2. Add Android App

1. In Firebase Console → Project Settings → **Add app** → Android
2. Package name: `com.savetospend.trackerApp`
3. Download `google-services.json` → place in `android/app/`

### 3. Enable Firebase Services

In Firebase Console:
- **Authentication** → Sign-in method → Enable **Email/Password** and **Google**
- **Firestore Database** → Create database → Start in **production mode**

### 4. Deploy Security Rules

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login and deploy rules
firebase login
firebase deploy --only firestore:rules
```

### 5. Configure the App

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase project config values (found in Firebase Console → Project Settings → Your Apps).

Or use **FlutterFire CLI** (recommended):

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Auto-configure (overwrites firebase_options.dart with your real values)
flutterfire configure --project=YOUR_PROJECT_ID
```

---

## Running the App

### Prerequisites

- Flutter SDK 3.19+ ([install guide](https://docs.flutter.dev/get-started/install))
- Android SDK / Android Studio
- A Firebase project configured (see above)

### Development

```bash
# Get dependencies
flutter pub get

# Run on connected Android device or emulator
flutter run

# Run with a specific device
flutter run -d <device-id>
```

### Running Tests

```bash
# All tests
flutter test

# Domain unit tests only
flutter test test/domain/spendable_calculator_test.dart

# Widget tests
flutter test test/presentation/add_expense_flow_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Building a Release APK

### 1. Create a Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>
```

Update `android/app/build.gradle` to reference this keystore (see Flutter docs).

### 3. Build

```bash
# Release APK (sideloadable)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Firestore Data Model

```
users/{userId}/
  ├── fund_state/
  │   └── current               # Single document
  │       ├── principalAmount: number
  │       ├── lockedAmount: number
  │       ├── spendableAmount: number (derived, stored for fast reads)
  │       └── lastUpdated: ISO timestamp
  └── ledger_entries/{entryId}
      ├── type: "expense" | "fund_update"
      ├── amount: number
      ├── note: string? (optional)
      ├── category: string? (optional, expenses only)
      ├── timestamp: ISO timestamp
      └── balanceAfter: number  # Spendable snapshot after this entry
```

All writes that touch both `fund_state` and `ledger_entries` use **Firestore batch writes** to prevent balance drift.

---

## Architecture Notes

- **Domain layer** (`domain/`) has zero Flutter or Firebase dependencies — pure Dart. This means the same business logic can be used in a web frontend later.
- **Riverpod providers** are layered: stream providers at the bottom, state notifiers on top. All UI consumes via `ref.watch`.
- **GoRouter** handles auth-gating: unauthenticated users are redirected to login, authenticated users without a fund state are redirected to setup.

---

## Future Web Extension

Because the backend is Firebase/Firestore from day one:
- A React/Next.js web app can log in with the same Firebase Auth credentials
- Read/write the same Firestore collections without any API changes
- The Firestore security rules already scope access correctly per user
- No data migration needed — deploy a web app, point it at the same Firebase project, done.

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `google-services.json` not found | Place it in `android/app/`, not project root |
| Firebase Auth not working | Check that Email/Password is enabled in Firebase Console |
| Firestore permission denied | Deploy `firestore.rules` via Firebase CLI |
| Build fails on Google Fonts offline | Run `flutter pub get` with internet access once |
| `flutterfire configure` fails | Ensure Firebase CLI is installed and you're logged in |

---

## Version History

| Version | Notes |
|---|---|
| 1.0.0 | Initial MVP — balance partitioning, expense tracking, monthly summary |
