# 🗺️ Google Maps Setup Guide - Step by Step

## Complete Guide to Setting Up Google Maps for Sahara Pet Care

**Time Required**: 20-30 minutes
**Cost**: FREE ($200 monthly credit, more than enough for development)

---

## 📋 What You'll Need

- Google account
- Credit card (for verification only - you won't be charged)
- Your Firebase project (it auto-creates a Google Cloud project)

---

## 🎯 Step-by-Step Instructions

### STEP 1: Access Google Cloud Console (2 minutes)

1. **Open Google Cloud Console**
   - Go to: https://conscdole.cloud.google.com/
   - Sign in with your Google account

2. **Select Your Project**
   - At the top of the page, click the project dropdown
   - You should see your Firebase project name (e.g., "sahara-pet-care")
   - Click on it to select it
   - If you don't see it, it means you haven't created Firebase project yet

---

### STEP 2: Enable Billing (5 minutes) ⚠️ REQUIRED

**Why**: Google Maps requires billing enabled, but you get $200 FREE credit every month!

1. **Go to Billing**
   - Click the hamburger menu (☰) in top-left
   - Click "Billing"
   - If you see "This project has no billing account", continue below

2. **Create Billing Account**
   - Click "Link a billing account"
   - Click "Create billing account"
   - Enter your details:
     - Country
     - Name
     - Address
   - Click "Continue"

3. **Add Payment Method**
   - Click "Add credit or debit card"
   - Enter card details (for verification only)
   - Click "Start my free trial"
   
   ✅ **You get $300 free trial + $200/month ongoing credit**
   ✅ **You won't be charged unless you explicitly upgrade**

4. **Link to Project**
   - Select your billing account
   - Click "Set account"

---

### STEP 3: Enable Required APIs (5 minutes)

You need to enable 5 different APIs:

1. **Go to API Library**
   - Click hamburger menu (☰)
   - Click "APIs & Services"
   - Click "Library"

2. **Enable Maps SDK for Android**
   - In search box, type: "Maps SDK for Android"
   - Click on "Maps SDK for Android"
   - Click "Enable" button
   - Wait for it to enable (10-20 seconds)

3. **Enable Maps SDK for iOS**
   - Click "Library" again (in left menu)
   - Search: "Maps SDK for iOS"
   - Click on it
   - Click "Enable"

4. **Enable Maps JavaScript API**
   - Click "Library" again
   - Search: "Maps JavaScript API"
   - Click on it
   - Click "Enable"

5. **Enable Geocoding API**
   - Click "Library" again
   - Search: "Geocoding API"
   - Click on it
   - Click "Enable"

6. **Enable Places API**
   - Click "Library" again
   - Search: "Places API"
   - Click on it
   - Click "Enable"

✅ **All 5 APIs should now show as "Enabled"**

---

### STEP 4: Create API Keys (10 minutes)

You need 3 separate API keys (one for each platform):

#### 4A. Create Web API Key

1. **Go to Credentials**
   - Click "APIs & Services" in left menu
   - Click "Credentials"

2. **Create Key**
   - Click "Create Credentials" at top
   - Select "API key"
   - A popup shows your key (starts with "AIza...")
   - **COPY THIS KEY** - save it in a text file

3. **Restrict the Key**
   - Click "Restrict Key" in the popup (or click the key name)
   - Change name to: `Sahara Web Key`
   
4. **Set Application Restrictions**
   - Under "Application restrictions"
   - Select "HTTP referrers (web sites)"
   - Click "Add an item"
   - Enter: `localhost:*`
   - Click "Add an item" again
   - Enter: `127.0.0.1:*`
   - (Later add your production domain like: `yourdomain.com/*`)

5. **Set API Restrictions**
   - Under "API restrictions"
   - Select "Restrict key"
   - Check these 3 APIs:
     - ✅ Maps JavaScript API
     - ✅ Geocoding API
     - ✅ Places API
   - Click "Save"

✅ **Web API Key Created!**

#### 4B. Create Android API Key

1. **Create Another Key**
   - Click "Create Credentials" → "API key"
   - **COPY THIS KEY**

2. **Restrict the Key**
   - Click "Restrict Key"
   - Change name to: `Sahara Android Key`

3. **Set Application Restrictions**
   - Select "Android apps"
   - Click "Add an item"
   - Package name: `com.example.sahara`
   - SHA-1 fingerprint: (we'll get this in next section)
   - For now, leave SHA-1 empty and click "Done"

4. **Set API Restrictions**
   - Select "Restrict key"
   - Check these 3 APIs:
     - ✅ Maps SDK for Android
     - ✅ Geocoding API
     - ✅ Places API
   - Click "Save"

✅ **Android API Key Created!**

#### 4C. Create iOS API Key

1. **Create Another Key**
   - Click "Create Credentials" → "API key"
   - **COPY THIS KEY**

2. **Restrict the Key**
   - Click "Restrict Key"
   - Change name to: `Sahara iOS Key`

3. **Set Application Restrictions**
   - Select "iOS apps"
   - Click "Add an item"
   - Bundle ID: `com.example.sahara`
   - Click "Done"

4. **Set API Restrictions**
   - Select "Restrict key"
   - Check these 3 APIs:
     - ✅ Maps SDK for iOS
     - ✅ Geocoding API
     - ✅ Places API
   - Click "Save"

✅ **iOS API Key Created!**

---

### STEP 5: Add Keys to Your Project (5 minutes)

Now let's add these keys to your Flutter project:

#### 5A. Add Web Key

1. **Open web/index.html**
   - Location: `Sahaara_service_application/Sahara-main/web/index.html`

2. **Find the Google Maps script tag** (around line 30-40)
   - Look for: `<script src="https://maps.googleapis.com/maps/api/js`

3. **Replace with your key**
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY_HERE"></script>
   ```
   
   Example:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"></script>
   ```

4. **Save the file**

#### 5B. Add Android Key

1. **Open AndroidManifest.xml**
   - Location: `Sahaara_service_application/Sahara-main/android/app/src/main/AndroidManifest.xml`

2. **Find the `<application>` tag**

3. **Add this inside `<application>` tag** (before the closing `</application>`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ANDROID_API_KEY_HERE"/>
   ```
   
   Example:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"/>
   ```

4. **Save the file**

#### 5C. Add iOS Key (macOS only)

1. **Open AppDelegate.swift**
   - Location: `Sahaara_service_application/Sahara-main/ios/Runner/AppDelegate.swift`

2. **Add import at the top**:
   ```swift
   import GoogleMaps
   ```

3. **Add this inside the `application` function** (before `return`):
   ```swift
   GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
   ```
   
   Full example:
   ```swift
   import UIKit
   import Flutter
   import GoogleMaps

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       GMSServices.provideAPIKey("AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

4. **Save the file**

---

### STEP 6: Get Android SHA-1 Fingerprint (Optional - for Android)

If you want to run on Android, you need to add SHA-1 fingerprint:

1. **Open Terminal/PowerShell**

2. **Navigate to android folder**:
   ```bash
   cd Sahaara_service_application/Sahara-main/android
   ```

3. **Run signing report**:
   ```bash
   # On Windows
   .\gradlew signingReport
   
   # On macOS/Linux
   ./gradlew signingReport
   ```

4. **Copy the SHA-1**
   - Look for "SHA1:" under "Variant: debug"
   - Copy the long string (looks like: `A1:B2:C3:D4:...`)

5. **Add to Google Cloud Console**
   - Go back to Google Cloud Console
   - APIs & Services → Credentials
   - Click on "Sahara Android Key"
   - Under "Android apps", click "Edit"
   - Paste the SHA-1 fingerprint
   - Click "Done"
   - Click "Save"

6. **Also add to Firebase**
   - Go to Firebase Console
   - Project Settings → Your Android app
   - Scroll to "SHA certificate fingerprints"
   - Click "Add fingerprint"
   - Paste SHA-1
   - Download new `google-services.json`
   - Replace the old one in `android/app/`

---

### STEP 7: Test the Setup (5 minutes)

1. **Run the app**:
   ```bash
   cd Sahaara_service_application/Sahara-main
   flutter run -d chrome
   ```

2. **Check the home screen**
   - You should see a map
   - The map should show your location (after granting permission)
   - If you see "For development purposes only" watermark, that's normal for testing

3. **Check browser console** (F12)
   - Should NOT see any Google Maps errors
   - If you see errors, check your API key

---

## ✅ Verification Checklist

- [ ] Billing enabled in Google Cloud Console
- [ ] 5 APIs enabled (Maps Android, Maps iOS, Maps JavaScript, Geocoding, Places)
- [ ] 3 API keys created (Web, Android, iOS)
- [ ] Web key added to `web/index.html`
- [ ] Android key added to `AndroidManifest.xml`
- [ ] iOS key added to `AppDelegate.swift` (if using iOS)
- [ ] SHA-1 added to Android key (if using Android)
- [ ] App runs and shows map on home screen

---

## 🐛 Troubleshooting

### Issue: "This page can't load Google Maps correctly"

**Solution 1**: Check API key in `web/index.html`
- Make sure you copied the full key
- Make sure there are no extra spaces
- Make sure the key is between quotes

**Solution 2**: Check API restrictions
- Go to Google Cloud Console → Credentials
- Click on your Web key
- Make sure "Maps JavaScript API" is checked
- Make sure `localhost:*` is in HTTP referrers

**Solution 3**: Wait a few minutes
- API keys can take 5-10 minutes to activate
- Try refreshing the page

### Issue: "For development purposes only" watermark

**This is normal!** It means:
- Your API key is working
- You're in development mode
- The watermark will disappear when you:
  - Add billing (if not done)
  - Deploy to production domain
  - Add production domain to HTTP referrers

### Issue: Map shows but is gray/blank

**Solution**: Enable billing
- Maps require billing to be enabled
- Even with free credits, billing must be active

### Issue: "API key not valid" error

**Solution**: Check restrictions
- Make sure API key restrictions match your platform
- Web key should have HTTP referrers
- Android key should have package name
- iOS key should have bundle ID

### Issue: Map not showing on Android

**Solution 1**: Check SHA-1
- Make sure you added SHA-1 to both:
  - Google Cloud Console (API key)
  - Firebase Console (Android app)

**Solution 2**: Check package name
- Must be exactly: `com.example.sahara`
- Check in `android/app/build.gradle.kts`

### Issue: "Billing not enabled" error

**Solution**: Enable billing
1. Go to Google Cloud Console
2. Click "Billing" in menu
3. Link a billing account
4. Add payment method
5. Wait 5-10 minutes for activation

---

## 💰 Cost Information

### Free Tier (More than enough for development!)

**Monthly Free Credits**:
- $200 in free usage every month
- Resets on the 1st of each month

**What $200 Gets You**:
- ~28,000 map loads
- ~40,000 geocoding requests
- ~100,000 static map requests

**For Development**:
- You'll likely use less than $5/month
- You won't be charged anything

**For Production** (estimated):
- Small app (100 users): ~$0-10/month
- Medium app (1000 users): ~$10-50/month
- Large app (10,000 users): ~$50-200/month

**Billing Protection**:
- Set up budget alerts in Google Cloud Console
- You can set spending limits
- You'll get email alerts before charges

---

## 📱 Platform-Specific Notes

### Web
- ✅ Easiest to setup
- ✅ Works immediately after adding key
- ✅ No additional configuration needed

### Android
- ⚠️ Requires SHA-1 fingerprint
- ⚠️ Requires `google-services.json`
- ⚠️ May need to rebuild app after adding key

### iOS (macOS only)
- ⚠️ Requires CocoaPods installation
- ⚠️ Requires `GoogleService-Info.plist`
- ⚠️ Must add import and initialization code

### Windows
- ⚠️ Maps may not work perfectly on Windows
- ✅ Web view should work
- ⚠️ Consider using web version for Windows

---

## 🎯 Quick Reference

### Your API Keys Location

Save these in a safe place:

```
Web API Key: AIzaSyB________________________
Android API Key: AIzaSyB________________________
iOS API Key: AIzaSyB________________________
```

### Files to Update

```
✅ web/index.html (line ~35)
✅ android/app/src/main/AndroidManifest.xml (inside <application>)
✅ ios/Runner/AppDelegate.swift (inside application function)
```

### Commands to Remember

```bash
# Get Android SHA-1
cd android && ./gradlew signingReport

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d <device-id>

# Clean and rebuild
flutter clean && flutter pub get
```

---

## 🎉 Success!

If you can see a map on your home screen with your location, you're done! 

The map should:
- ✅ Load without errors
- ✅ Show your current location (blue dot)
- ✅ Be interactive (zoom, pan)
- ✅ Show caregiver markers (after seeding database)

---

## 📞 Still Need Help?

### Check These Resources:
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)

### Common Links:
- Enable APIs: https://console.cloud.google.com/apis/library
- Manage Keys: https://console.cloud.google.com/apis/credentials
- Billing: https://console.cloud.google.com/billing

---

**You're all set! The maps should now work perfectly in your app! 🗺️**

**Next Steps**: Setup Firebase and Cloudinary, then you're ready to go! 🚀
