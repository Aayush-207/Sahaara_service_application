# 🚀 Complete Setup Guide - Sahara Pet Care App

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Cloudinary Setup](#cloudinary-setup)
4. [Google Maps Setup](#google-maps-setup)
5. [Environment Configuration](#environment-configuration)
6. [Platform-Specific Setup](#platform-specific-setup)
7. [Running the App](#running-the-app)
8. [Testing & Deployment](#testing--deployment)

---

## 1. Prerequisites

### Required Software
- ✅ Flutter SDK 3.41.2+ (Already installed)
- ✅ Dart 3.0+ (Already installed)
- Git
- Android Studio (for Android development)
- Xcode (for iOS development - macOS only)
- Visual Studio 2022 (for Windows development)

### Verify Installation
```bash
flutter doctor -v
```

---

## 2. Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `sahara-pet-care`
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Enable Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable the following providers:
   - ✅ Email/Password
   - ✅ Google Sign-In
3. For Google Sign-In:
   - Add your app's SHA-1 fingerprint (Android)
   - Download updated `google-services.json`

### Step 3: Create Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Production mode** (we have security rules)
3. Select your region (closest to your users)
4. Click **Enable**

### Step 4: Deploy Firestore Rules & Indexes
```bash
cd Sahaara_service_application/Sahara-main

# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (select existing project)
firebase init

# Deploy rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Step 5: Enable Cloud Messaging
1. Go to **Cloud Messaging** in Firebase Console
2. Note your **Server Key** and **Sender ID**
3. Enable Cloud Messaging API in Google Cloud Console

### Step 6: Add Firebase to Your Apps

#### Android
1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.sahara`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### iOS
1. In Firebase Console, click **Add app** → **iOS**
2. Enter bundle ID: `com.example.sahara`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

#### Web
1. In Firebase Console, click **Add app** → **Web**
2. Register app name: `Sahara Web`
3. Copy the Firebase config
4. Update `lib/firebase_options.dart` (already generated via FlutterFire CLI)

### Step 7: Generate Firebase Options
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for all platforms
flutterfire configure
```

---

## 3. Cloudinary Setup

### Step 1: Create Cloudinary Account
1. Go to [Cloudinary](https://cloudinary.com/)
2. Sign up for a free account
3. Verify your email

### Step 2: Get Credentials
1. Go to **Dashboard**
2. Note your:
   - **Cloud Name** (e.g., `dxxxxx`)
   - **API Key**
   - **API Secret**

### Step 3: Create Upload Preset
1. Go to **Settings** → **Upload**
2. Scroll to **Upload presets**
3. Click **Add upload preset**
4. Configure:
   - **Preset name**: `sahara_uploads`
   - **Signing Mode**: `Unsigned`
   - **Folder**: `sahara/pets` (optional)
   - **Access Mode**: `Public`
5. Save preset

### Step 4: Update .env File
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_UPLOAD_PRESET=sahara_uploads
```

---

## 4. Google Maps Setup

### Step 1: Enable Google Maps API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** → **Library**
4. Enable the following APIs:
   - ✅ Maps SDK for Android
   - ✅ Maps SDK for iOS
   - ✅ Maps JavaScript API
   - ✅ Geocoding API
   - ✅ Places API

### Step 2: Create API Keys

#### Android API Key
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Restrict key:
   - **Application restrictions**: Android apps
   - **Add package name**: `com.example.sahara`
   - **Add SHA-1 fingerprint**
4. Copy the API key

#### iOS API Key
1. Create another API key
2. Restrict key:
   - **Application restrictions**: iOS apps
   - **Add bundle ID**: `com.example.sahara`
3. Copy the API key

#### Web API Key
1. Create another API key
2. Restrict key:
   - **Application restrictions**: HTTP referrers
   - **Add referrer**: `localhost:*`, `your-domain.com/*`
3. Copy the API key

### Step 3: Add API Keys to Project

#### Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_API_KEY"/>
    </application>
</manifest>
```

#### iOS
Edit `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Web
Edit `web/index.html`:
```html
<head>
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY"></script>
</head>
```

---

## 5. Environment Configuration

### Update .env File
Edit `Sahaara_service_application/Sahara-main/.env`:
```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_UPLOAD_PRESET=sahara_uploads

# App Configuration
APP_NAME=Sahara Pet Care
APP_PRIMARY_COLOR=#1A2332

# Optional: Add Google Maps API keys here for easy reference
# GOOGLE_MAPS_ANDROID_KEY=your_android_key
# GOOGLE_MAPS_IOS_KEY=your_ios_key
# GOOGLE_MAPS_WEB_KEY=your_web_key
```

---

## 6. Platform-Specific Setup

### Android Setup

#### 1. Update Gradle Files
`android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

#### 2. Get SHA-1 Fingerprint
```bash
cd android
./gradlew signingReport
```

#### 3. Add SHA-1 to Firebase
1. Copy SHA-1 from output
2. Go to Firebase Console → Project Settings → Your Android App
3. Add SHA-1 fingerprint
4. Download new `google-services.json`

#### 4. Permissions
Already configured in `AndroidManifest.xml`:
- Internet
- Location (Fine & Coarse)
- Camera
- Storage

### iOS Setup

#### 1. Update Info.plist
`ios/Runner/Info.plist` (already configured):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby caregivers</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take pet photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select pet photos</string>
```

#### 2. Install Pods
```bash
cd ios
pod install
cd ..
```

### Windows Setup

#### Enable Developer Mode
1. Press `Win + I` to open Settings
2. Go to **Privacy & Security** → **For developers**
3. Enable **Developer Mode**
4. Restart if prompted

OR run:
```powershell
start ms-settings:developers
```

### Web Setup

#### 1. Create Firebase Service Worker
Create `web/firebase-messaging-sw.js`:
```javascript
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();
```

#### 2. Update index.html
Ensure Google Maps script is added (see Google Maps Setup above)

---

## 7. Running the App

### Install Dependencies
```bash
cd Sahaara_service_application/Sahara-main
flutter pub get
```

### Run on Different Platforms

#### Android
```bash
# Connect Android device or start emulator
flutter devices
flutter run -d <device-id>
```

#### iOS (macOS only)
```bash
# Connect iOS device or start simulator
flutter devices
flutter run -d <device-id>
```

#### Web
```bash
flutter run -d chrome
# OR
flutter run -d edge
```

#### Windows
```bash
flutter run -d windows
```

### Hot Reload
While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## 8. Testing & Deployment

### Testing

#### Run Tests
```bash
flutter test
```

#### Check for Issues
```bash
flutter analyze
```

### Build for Production

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Then open Xcode to archive and upload
```

#### Web
```bash
flutter build web --release
# Output: build/web/
```

#### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

---

## 9. Database Seeding (Optional)

### Seed Sample Data
The app includes a database seeding feature for testing:

1. Run the app
2. Go to **Profile** → **Settings**
3. Scroll to **Developer Options**
4. Tap **Seed Database**
5. Wait for completion

This will create:
- 10 sample caregivers
- 5 sample dogs for adoption
- Sample reviews and ratings

### Manual Seeding
```bash
# Run the seed script
flutter run lib/scripts/seed_database.dart
```

---

## 10. Troubleshooting

### Common Issues

#### Issue: Firebase not initialized
**Solution**: Ensure `firebase_options.dart` exists and run `flutterfire configure`

#### Issue: Google Maps not showing
**Solution**: 
- Verify API keys are correct
- Check if APIs are enabled in Google Cloud Console
- Ensure billing is enabled (required for Maps API)

#### Issue: Image upload failing
**Solution**:
- Verify Cloudinary credentials in `.env`
- Ensure upload preset is set to "Unsigned"
- Check internet connection

#### Issue: Location permission denied
**Solution**:
- Check device settings
- Ensure permissions are declared in AndroidManifest.xml / Info.plist
- Request permissions at runtime

#### Issue: Build fails on Windows
**Solution**:
- Enable Developer Mode
- Run as Administrator
- Check Visual Studio 2022 is installed with C++ tools

---

## 11. Production Checklist

Before deploying to production:

### Security
- [ ] Update Firestore security rules
- [ ] Restrict API keys by platform
- [ ] Enable App Check in Firebase
- [ ] Remove debug logs
- [ ] Obfuscate code: `flutter build --obfuscate --split-debug-info=/<directory>`

### Performance
- [ ] Enable caching for images
- [ ] Optimize asset sizes
- [ ] Test on low-end devices
- [ ] Monitor Firebase usage

### App Store Requirements
- [ ] Update app icons
- [ ] Create screenshots
- [ ] Write app description
- [ ] Set up privacy policy
- [ ] Configure app signing

### Testing
- [ ] Test all user flows
- [ ] Test on multiple devices
- [ ] Test offline functionality
- [ ] Test payment integration (if added)
- [ ] Beta test with real users

---

## 12. Next Steps & Enhancements

### Recommended Features to Add
1. **Payment Integration**
   - Stripe or Razorpay
   - In-app wallet
   - Booking deposits

2. **Advanced Features**
   - Video calls with caregivers
   - Live GPS tracking during walks
   - Automated booking reminders
   - Loyalty points system

3. **Analytics**
   - Firebase Analytics
   - Crashlytics for error tracking
   - User behavior tracking

4. **Marketing**
   - Push notification campaigns
   - Referral system
   - Promotional codes

---

## 📞 Support

For issues or questions:
- Check documentation in `docs/` folder
- Review Firebase Console logs
- Check Flutter DevTools for debugging

---

## 🎉 Congratulations!

Your Sahara Pet Care app is now fully configured and ready for development and deployment!

**Happy Coding! 🐾**
