# Sahara Pet Care - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- ✅ Flutter installed
- ✅ Android Studio / VS Code
- ✅ Android Emulator or Physical Device
- ✅ Firebase project configured

---

## Step 1: Install Dependencies

```bash
cd Sahara
flutter pub get
```

---

## Step 2: Configure Environment

Make sure your `.env` file exists with Firebase configuration:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=sahara-a72
FIREBASE_STORAGE_BUCKET=your_storage_bucket

# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_maps_api_key
```

---

## Step 3: Run the App

```bash
flutter run
```

The app will launch on your connected device/emulator.

---

## Step 4: Seed Initial Data

### Option A: Using Admin Seed Screen (Recommended)

1. Launch the app
2. Sign up or log in
3. Go to Profile → Settings
4. Look for "Admin Seed" option (if available)
5. Tap "Seed Products" button
6. Tap "Seed Caregivers" button

### Option B: Manual Seeding via Code

Add this to your `main.dart` after Firebase initialization:

```dart
// In main() function, after Firebase.initializeApp()
Future<void> seedInitialData() async {
  final productService = ProductService();
  await productService.seedProducts();
  debugPrint('✅ Products seeded');
}

// Call it once
seedInitialData();
```

Then run the app once, and remove the code.

### Option C: Firebase Console

1. Go to https://console.firebase.google.com/project/sahara-a72/firestore
2. Create collections manually:
   - `products` - Add product documents
   - `users` (caregivers) - Add caregiver profiles
   - `adoptable_pets` - Add pets for adoption

---

## Step 5: Test Core Features

### 1. Authentication
- ✅ Sign up with email/password
- ✅ Log in
- ✅ Google Sign-In (if configured)

### 2. Profile Setup
- ✅ Edit profile
- ✅ Upload profile photo
- ✅ Add pets

### 3. Browse Caregivers
- ✅ View caregiver list
- ✅ Search by service
- ✅ Filter by location
- ✅ View caregiver details

### 4. Book a Service
- ✅ Select caregiver
- ✅ Choose service
- ✅ Select package
- ✅ Pick date/time
- ✅ Confirm booking

### 5. Shop for Products
- ✅ Browse products
- ✅ Filter by category
- ✅ Search products
- ✅ Add to cart
- ✅ Checkout (COD)
- ✅ View orders

### 6. Track Service
- ✅ Go to Tracking tab
- ✅ View live location
- ✅ See service timeline
- ✅ Contact caregiver

### 7. Adopt a Pet
- ✅ Browse adoptable pets
- ✅ View pet details
- ✅ Submit enquiry

### 8. Chat with Caregiver
- ✅ Go to Messages
- ✅ Select chat
- ✅ Send messages
- ✅ Edit/delete messages

---

## 🎯 Quick Feature Tour

### Home Screen
- Dashboard with quick actions
- Top-rated caregivers
- Recent bookings
- Quick service access

### Caregivers Tab
- Browse all caregivers
- Search and filter
- View profiles
- Book services

### Bookings Tab
- View all bookings
- Filter by status (Pending, Confirmed, In Progress, Completed, Cancelled)
- Cancel bookings
- View booking details

### Messages Tab
- Chat with caregivers
- Real-time messaging
- Edit/delete messages
- View chat history

### Shop Tab
- Browse products
- Categories: Food, Toys, Accessories, Healthcare, Grooming
- Shopping cart
- Checkout and orders

### Tracking Tab
- Live location tracking
- Service timeline
- Caregiver contact
- Multiple active bookings

### Profile Tab
- Edit profile
- Manage pets
- View favorites
- Settings
- Help & support

---

## 🔧 Troubleshooting

### App Won't Build
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### Google Maps Not Showing
- Check if API key is configured in `AndroidManifest.xml`
- Enable Maps SDK in Google Cloud Console
- Verify billing is enabled

### Firebase Errors
- Check `google-services.json` is in `android/app/`
- Verify Firebase project configuration
- Check internet connection

### No Products Showing
- Run product seeding (see Step 4)
- Check Firestore rules allow read access
- Verify internet connection

### Location Not Working
- Grant location permissions when prompted
- Enable GPS on device
- Check location services in device settings

---

## 📱 Test Accounts

### Owner Account
- Email: `owner@test.com`
- Password: `test123`
- Role: Pet Owner

### Caregiver Account
- Email: `caregiver@test.com`
- Password: `test123`
- Role: Caregiver

*(Create these accounts via Sign Up screen)*

---

## 🎨 Demo Data

### Dummy Bookings
The app includes dummy bookings for demonstration:
- Active booking (in progress)
- Completed booking
- Upcoming booking

### Dummy Reviews
Caregiver profiles show generated reviews based on their rating.

### Simulated Tracking
Live tracking uses simulated caregiver location near your current location.

---

## 📊 Firebase Collections Structure

### `users`
```json
{
  "uid": "user_id",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "owner",
  "photoUrl": "https://...",
  "phone": "+1234567890",
  "location": "Mumbai, India",
  "createdAt": "timestamp"
}
```

### `products`
```json
{
  "name": "Premium Dog Food",
  "description": "High-quality dog food...",
  "price": 999.0,
  "category": "Food",
  "images": ["https://..."],
  "rating": 4.5,
  "stock": 50,
  "isAvailable": true
}
```

### `bookings`
```json
{
  "ownerId": "user_id",
  "caregiverId": "caregiver_id",
  "petId": "pet_id",
  "serviceType": "Dog Walking",
  "packageName": "Premium Walk",
  "scheduledDate": "timestamp",
  "status": "confirmed",
  "price": 499
}
```

### `orders`
```json
{
  "userId": "user_id",
  "items": [...],
  "totalAmount": 1499.0,
  "deliveryAddress": {...},
  "paymentMethod": "COD",
  "status": "pending",
  "createdAt": "timestamp"
}
```

---

## 🔐 Security Notes

### Before Production:
1. Configure Firestore Security Rules
2. Enable App Check
3. Set up proper authentication
4. Implement rate limiting
5. Add input validation
6. Enable HTTPS only
7. Secure API keys
8. Implement proper error handling

### Firestore Rules Example:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Products are read-only for users
    match /products/{productId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
    
    // Bookings
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.ownerId 
                  || request.auth.uid == resource.data.caregiverId;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.ownerId 
                    || request.auth.uid == resource.data.caregiverId;
    }
  }
}
```

---

## 📞 Support

### Issues?
- Check console logs for errors
- Verify Firebase configuration
- Ensure all dependencies are installed
- Check internet connection
- Review error messages

### Common Solutions:
- **Build errors**: Run `flutter clean`
- **Dependency conflicts**: Update `pubspec.yaml`
- **Firebase errors**: Check `google-services.json`
- **Map errors**: Verify API key
- **Permission errors**: Grant required permissions

---

## 🎉 You're All Set!

The app is now ready to use. Explore all features and enjoy the Sahara Pet Care experience!

### Next Steps:
1. ✅ Test all features
2. ✅ Customize branding
3. ✅ Add real data
4. ✅ Configure production Firebase
5. ✅ Set up payment gateway (optional)
6. ✅ Deploy to Play Store/App Store

---

**Happy Coding! 🐾**

