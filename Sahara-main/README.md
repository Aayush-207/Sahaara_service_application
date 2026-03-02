# Sahara - Dog Care Booking App

A Flutter mobile application for booking professional dog care services.

## Features

- User authentication (Email/Password & Google Sign-In)
- Browse and search dog caregivers
- Book dog care services with package selection
- Manage multiple dogs
- Real-time messaging with caregivers
- Booking management and history
- User profile with photo upload
- Push notifications
- Location-based caregiver search

## Tech Stack

- **Frontend**: Flutter 3.41.2
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Image Storage**: Cloudinary
- **State Management**: Provider
- **Platform**: Android, iOS, Web, Windows, macOS

## Project Structure

```
lib/
├── config/          # App configuration
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic & API calls
├── theme/           # App theming
├── utils/           # Helper utilities
└── widgets/         # Reusable widgets
```

## Setup

1. Install Flutter SDK (3.41.2 or higher)
2. Clone the repository
3. Copy `.env.example` to `.env` and configure:
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_upload_preset
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Configure Firebase:
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)
6. Deploy Firestore rules and indexes:
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```

## Run

```bash
flutter run
```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Firebase Collections

- `users` - User profiles (owners & caregivers)
- `pets` - Dog profiles
- `bookings` - Service bookings
- `messages` - Chat messages
- `reviews` - Caregiver reviews
- `favorites` - Saved caregivers

## Key Screens

- Splash & Onboarding
- Login & Signup
- Home (Browse caregivers)
- Caregiver Details
- Package Selection
- Booking Confirmation
- My Dogs
- Bookings
- Messages
- Profile & Settings

## Status

✅ All core features implemented and tested
✅ No compilation errors or warnings
✅ Clean codebase with proper architecture
✅ Ready for production deployment

## License

Proprietary - All rights reserved
