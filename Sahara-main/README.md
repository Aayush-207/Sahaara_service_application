# Sahara Pet Care Application

A comprehensive Flutter application for pet care services, connecting pet owners with professional caregivers.

## 🐾 Features

### For Pet Owners
- **Find Caregivers**: Browse and search for verified pet caregivers
- **Book Services**: Dog walking, pet sitting, grooming, training, and vet visits
- **Real-time Chat**: Communicate with caregivers
- **Track Bookings**: Monitor service status and history
- **Manage Pets**: Add and manage multiple pets
- **Favorites**: Save your preferred caregivers
- **Reviews & Ratings**: Read and write caregiver reviews

### For Caregivers
- **Profile Management**: Showcase services and expertise
- **Service Packages**: Offer customized service packages
- **Booking Management**: Accept and manage bookings
- **Chat with Clients**: Direct communication with pet owners
- **Ratings & Reviews**: Build reputation through client feedback

## 🏗️ Architecture

### Frontend
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **UI**: Material Design 3 with custom theme
- **Navigation**: Custom navigation helper with consistent transitions

### Backend
- **Authentication**: Firebase Auth (Email/Password, Google Sign-In)
- **Database**: Cloud Firestore
- **Storage**: Cloudinary (images)
- **Notifications**: Firebase Cloud Messaging
- **Maps**: Google Maps Flutter

## 📁 Project Structure

```
lib/
├── config/              # App configuration
│   └── app_config.dart  # Environment variables
├── models/              # Data models (10 files)
│   ├── user_model.dart
│   ├── booking_model.dart
│   ├── pet_model.dart
│   └── ...
├── providers/           # State management (6 providers)
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   └── ...
├── screens/             # UI screens (31 screens)
│   ├── home_screen.dart
│   ├── login_screen_enhanced.dart
│   └── ...
├── services/            # Business logic (10 services)
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── ...
├── theme/               # UI theme
│   ├── app_colors.dart
│   └── app_theme.dart
├── utils/               # Utilities
│   ├── navigation_helper.dart
│   ├── validators.dart
│   └── ...
├── widgets/             # Reusable components (15+ widgets)
│   ├── custom_button.dart
│   ├── booking_card.dart
│   └── ...
├── firebase_options.dart
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Firebase account
- Cloudinary account
- Google Cloud Console account (for Maps API)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Sahara-main
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Update `.env` with your credentials:
   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_upload_preset
   SUPPORT_EMAIL=support@yourdomain.com
   SUPPORT_PHONE=+91 XXXXX XXXXX
   PRIVACY_EMAIL=privacy@yourdomain.com
   COMPANY_ADDRESS=Your Company Address
   ```

4. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android, iOS, and Web apps
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Run: `flutterfire configure` (or update `lib/firebase_options.dart` manually)

5. **Configure Google Maps**
   - Get API keys from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android, iOS, and JavaScript
   - Update API keys in:
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/Info.plist` and `ios/Runner/AppDelegate.swift`
     - Web: `web/index.html`
   
   See `GOOGLE_MAPS_SETUP_GUIDE.md` for detailed instructions.

6. **Run the app**
   ```bash
   flutter run
   ```

### Seed Test Data

To populate the database with test caregivers and service packages:

1. Run the app
2. Navigate to Profile → Admin Seed Screen
3. Tap "Seed All Data"
4. Wait for completion

This will add 8 caregivers and 21 service packages to your Firestore database.

## 📱 Screens & Navigation

### Authentication Flow
```
Splash → Permissions (first launch) → Onboarding → Login/Signup → Home
```

### Main Navigation (Bottom Tabs)
- **Home**: Browse caregivers, services, and quick actions
- **Bookings**: View and manage bookings
- **Messages**: Chat with caregivers
- **Profile**: User settings and preferences

### Booking Flow
```
Service Selection → Caregiver Selection → Package Selection → Confirmation
```

## 🔧 Configuration

### Environment Variables
All configurable values are in `.env`:
- Cloudinary credentials
- Contact information
- App branding

### Firebase Security Rules
Deploy security rules:
```bash
firebase deploy --only firestore:rules --project your-project-id
```

## 🔐 Security

### ⚠️ Before Production Deployment

1. **Rotate all API keys** (Firebase, Google Maps, Cloudinary)
2. **Configure API key restrictions** in Google Cloud Console
3. **Deploy Firebase Security Rules** (`firestore.rules`)
4. **Enable Firebase App Check**
5. **Remove `.env` from version control**
6. **Implement backend server** for sensitive operations

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📦 Dependencies

### Core
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`
- `provider` - State management
- `google_sign_in` - Google authentication

### UI
- `google_fonts` - Typography
- `cached_network_image` - Image caching

### Location & Maps
- `geolocator`, `geocoding`, `google_maps_flutter`

### Media
- `image_picker`, `cloudinary_public`, `audioplayers`

### Utilities
- `flutter_dotenv`, `shared_preferences`, `intl`, `uuid`

See `pubspec.yaml` for complete list.

## 📚 Documentation

- `COMPLETE_SETUP_GUIDE.md` - Detailed setup instructions
- `GOOGLE_MAPS_SETUP_GUIDE.md` - Google Maps configuration
- `BOOKING_FIX_GUIDE.md` - Booking system and data seeding guide

## 🐛 Known Issues

### Fixed
- ✅ Google Maps Android crash (Apache HTTP library)
- ✅ Hardcoded contact information (now configurable)
- ✅ Booking status automation
- ✅ Real-time tracking feature
- ✅ Active bookings tab

### In Progress
- ⚠️ Payment integration (coming soon)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Development Team - Initial work

## 🙏 Acknowledgments

- Firebase for backend services
- Cloudinary for image hosting
- Google Maps for location services
- Flutter community for excellent packages

## 📞 Support

For support, email support@sahara.com or visit our Help & Support section in the app.

---

**Version**: 1.0.0  
**Last Updated**: March 11, 2026  
**Status**: Development Ready (Not Production Ready - See Security section)
