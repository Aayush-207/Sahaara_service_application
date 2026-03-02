# 🌱 How to Seed Firebase Data

Quick guide to populate your Firebase database with realistic test data.

## Quick Start

### Option 1: From Main App (Recommended for Testing)

Add a temporary button in your app to trigger seeding:

```dart
// In any screen (e.g., settings_screen.dart or a debug screen)
import 'package:sahara/utils/firebase_seeder_india.dart';

ElevatedButton(
  onPressed: () async {
    final seeder = FirebaseSeederIndia();
    await seeder.seedAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Database seeded successfully!')),
    );
  },
  child: Text('Seed Database'),
)
```

### Option 2: From main.dart (One-Time Setup)

```dart
// In lib/main.dart, add after Firebase initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  
  // 🌱 SEED DATA (Remove after first run!)
  // final seeder = FirebaseSeederIndia();
  // await seeder.seedAll();
  
  runApp(MyApp());
}
```

### Option 3: Standalone Script

Create `lib/scripts/seed_database.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../utils/firebase_seeder_india.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final seeder = FirebaseSeederIndia();
  
  print('🌱 Starting database seeding...');
  await seeder.seedAll();
  print('✅ Seeding complete!');
  
  print('\n📊 Checking database status...');
  await seeder.checkDatabaseStatus();
}
```

Run with: `flutter run lib/scripts/seed_database.dart`

## What Gets Seeded?

### 16 Professional Caregivers
- 7 in Pune (Koregaon Park, Baner, Kalyani Nagar, etc.)
- 3 in Bangalore (Jayanagar, Koramangala, HSR Layout)
- 2 in Hyderabad (Jubilee Hills, Banjara Hills)
- 2 in Mumbai (Malad West, Juhu)
- 2 in Delhi NCR (Gurgaon, Hauz Khas)

### 21 Service Packages
- 4 Dog Walking packages (₹150-650)
- 4 Pet Sitting packages (₹350-1,200)
- 4 Grooming packages (₹400-1,500)
- 5 Training packages (₹600-2,500)
- 4 Vet Visit packages (₹300-1,000)

## Useful Commands

### Check Database Status
```dart
final seeder = FirebaseSeederIndia();
await seeder.checkDatabaseStatus();
```

Output:
```
📊 DATABASE STATUS CHECK

👥 Users: 16 (Owners: 0, Caregivers: 16)
🐾 Pets: 0
📅 Bookings: 0
📦 Service Packages: 21
⭐ Reviews: 0
💬 Chats: 0 (Messages: 0)

📊 TOTAL DOCUMENTS: 37
```

### Clear Seeded Data Only
```dart
final seeder = FirebaseSeederIndia();
await seeder.clearAllData();
```

This removes:
- All caregivers (userType == 'caregiver')
- All service packages

This keeps:
- Pet owners
- Pets
- Bookings
- Reviews
- Chats

### ⚠️ Clear Entire Database (DANGER!)
```dart
final seeder = FirebaseSeederIndia();
await seeder.clearEntireDatabase();
```

This removes EVERYTHING:
- All users (owners AND caregivers)
- All pets
- All bookings
- All service packages
- All reviews
- All chats and messages

## Firestore Collections

After seeding, you'll have:

### `users` collection
```
users/
  ├── caregiver_priya_sharma/
  ├── caregiver_rahul_verma/
  ├── caregiver_anjali_patel/
  └── ... (13 more)
```

### `service_packages` collection
```
service_packages/
  ├── dw_quick/
  ├── dw_basic/
  ├── dw_standard/
  ├── dw_premium/
  ├── ds_basic/
  └── ... (16 more)
```

## Firestore Security Rules

Make sure your Firestore rules allow writes:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow seeding in development
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Verification

After seeding, verify in Firebase Console:

1. Go to Firebase Console → Firestore Database
2. Check `users` collection → Should have 16 documents
3. Check `service_packages` collection → Should have 21 documents
4. Verify caregiver profiles have:
   - Realistic names and locations
   - Services array
   - Rating between 4.6-4.9
   - Completed bookings count
   - Bio and experience

## Troubleshooting

### "Permission denied" error
- Make sure you're authenticated
- Check Firestore security rules
- Verify Firebase project is initialized

### "Collection not found" error
- Collections are created automatically on first write
- No need to create them manually

### Duplicate data
- Run `clearAllData()` first
- Then run `seedAll()` again

### Want to re-seed
```dart
final seeder = FirebaseSeederIndia();
await seeder.clearAllData();  // Remove old data
await seeder.seedAll();        // Add fresh data
```

## Best Practices

1. **Development Only**: Don't seed production databases
2. **Remove After Use**: Comment out seeding code after initial setup
3. **Version Control**: Don't commit seeding triggers in main.dart
4. **Test First**: Seed a test Firebase project first
5. **Backup**: Export existing data before clearing

## Files

- `lib/utils/firebase_seeder_india.dart` - Main seeder (recommended)
- `lib/utils/firebase_seeder.dart` - Alternative seeder (same data)
- `SEED_DATA_SUMMARY.md` - Detailed data documentation

## Support

For issues or questions:
1. Check Firebase Console for errors
2. Verify Firestore rules
3. Check Flutter console for debug messages
4. Review `SEED_DATA_SUMMARY.md` for data details

---

**Last Updated**: February 27, 2026
**Status**: Production Ready ✅
