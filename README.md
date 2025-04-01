# Expense Tracker App

A comprehensive Flutter application for managing personal expenses with Firebase integration, authentication, and detailed analytics.

## Features

### Authentication

- Multiple sign-in options:
  - Email/Password authentication
  - Google Sign-in
- Secure user data management

### Expense Management

- Add, edit, and delete expenses
- Categorize transactions
- Add notes and descriptions
- Date selection for transactions
- Real-time data synchronization with Firebase

### Transaction History

- Chronological list of all transactions
- Filter transactions by date range
- Sort by amount, date, or category
- Search functionality
- Edit or delete past transactions

### Category Management

- Predefined expense categories
- Custom category creation
- Category-wise expense tracking
- Color coding for different categories

### Analytics & Reports

- Monthly expense summaries
- Category-wise spending analysis
- Visual charts and graphs using fl_chart
- Expense trends over time
- Export data to CSV format

## Technical Details

### Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.4
  cloud_firestore: ^5.6.6
  firebase_auth: ^5.5.2
  firebase_core: ^3.13.0
  intl: ^0.17.0
  uuid: ^4.5.1
  fl_chart: ^0.70.2
  csv: ^6.0.0
  google_sign_in: ^6.3.0
  flutter_facebook_auth: ^7.1.1
```

### Requirements Analysis

✅ User Interface Design

- Clean and intuitive UI implemented
- Material Design principles followed
- Responsive layout for different screen sizes

✅ Expense Input Feature

- Complete expense input form
- Data validation implemented
- Real-time updates

✅ Transaction History Feature

- Comprehensive transaction list
- Sorting and filtering options
- Edit/delete functionality

✅ Category Management Feature

- Predefined categories available
- Custom category support
- Category-based organization

✅ Summary Reports Feature

- Visual charts and graphs
- Monthly spending trends
- Category-wise analysis
- Data export functionality

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)
4. Run `flutter run` to start the app

### Platform Support

- Android
- iOS

## Project Structure

```
expense_tracker/
├── lib/
│   ├── models/
│   │   ├── expense.dart
│   │   └── user.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── budget_provider.dart
│   │   └── expense_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── email_verification_screen.dart
│   │   ├── add_expense_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── budget_screen.dart
│   │   ├── history_screen.dart
│   │   ├── home_screen.dart
│   │   ├── profile_edit_screen.dart
│   │   └── reports_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── expense_service.dart
│   │   └── export_service.dart
│   ├── widgets/
│   │   ├── expense_tile.dart
│   │   ├── main_drawer.dart
│   │   └── safe_stream_builder.dart
│   ├── firebase_options.dart
│   └── main.dart
├── android/
│   └── google-services.json
├── ios/
│   └── GoogleService-Info.plist
├── pubspec.yaml
└── README.md
```

The project follows a well-organized structure:

- **lib/**: Contains all Dart source code

  - **models/**: Data models and entities
  - **providers/**: State management using Provider
  - **screens/**: UI screens and pages
  - **services/**: Business logic and API interactions
  - **widgets/**: Reusable UI components

- **android/**: Android-specific configurations
- **ios/**: iOS-specific configurations
