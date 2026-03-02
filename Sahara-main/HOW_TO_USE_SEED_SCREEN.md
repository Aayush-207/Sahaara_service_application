# 🌱 How to Use the Seed Database Screen

## Access the Seed Screen

1. Open your app
2. Go to **Profile** tab (bottom navigation)
3. Scroll down to find **"Seed Database"** option
4. Tap on it to open the Admin Seed Screen

## What the Screen Does

The Admin Seed Screen provides 4 main functions:

### 1. 🌱 Seed All Data
**What it does:**
- Adds 16 elite caregiver profiles across 7 major Indian cities
- Adds 21 service packages across 5 service types
- Uses market-researched pricing (₹150-2,500)
- Includes professional credentials & certifications

**When to use:**
- First time setup
- After clearing data
- To refresh with latest seed data

**What gets added:**
- **16 Caregivers**: Pune (7), Bangalore (3), Hyderabad (2), Mumbai (2), Delhi NCR (2)
- **21 Packages**: Dog Walking (4), Pet Sitting (4), Grooming (4), Training (5), Vet Visit (4)

### 2. 📊 Check Database Status
**What it does:**
- Shows count of all documents in database
- Displays: Users, Pets, Bookings, Packages, Reviews, Chats

**When to use:**
- To verify seeding worked
- To check current database state
- Before clearing data

**Output example:**
```
👥 Users: 16 (Owners: 0, Caregivers: 16)
🐾 Pets: 0
📅 Bookings: 0
📦 Service Packages: 21
⭐ Reviews: 0
💬 Chats: 0 (Messages: 0)

📊 TOTAL DOCUMENTS: 37
```

### 3. 🗑️ Clear Seeded Data
**What it does:**
- Removes ONLY seeded caregivers (userType == 'caregiver')
- Removes ONLY service packages
- Keeps all user data (owners, pets, bookings, chats)

**When to use:**
- To remove old seed data before re-seeding
- To clean up test data
- When service types need updating

**Safe to use:** ✅ Won't delete your real user data

### 4. ⚠️ CLEAR ENTIRE DATABASE
**What it does:**
- Deletes EVERYTHING in Firestore
- Removes ALL users (owners AND caregivers)
- Removes ALL pets, bookings, chats, reviews, packages

**When to use:**
- Complete database reset
- Starting fresh in development
- NEVER in production!

**Dangerous:** ⚠️ Cannot be undone!

## Step-by-Step: Fix Service Types Issue

Since you already seeded with the old "Dog Training" service type, follow these steps:

### Step 1: Clear Old Data
1. Open Admin Seed Screen
2. Tap **"Clear Seeded Data"**
3. Confirm the dialog
4. Wait for success message

### Step 2: Re-seed with Correct Types
1. Tap **"Seed All Data"**
2. Wait for completion (takes 5-10 seconds)
3. You'll see success message

### Step 3: Verify
1. Tap **"Check Database Status"**
2. Should show:
   - Users: 16
   - Service Packages: 21
3. Go back to home screen
4. Check all 5 services show packages

## Troubleshooting

### "Not working properly" - What to check:

#### 1. Check Logs Section
The screen shows logs at the bottom. Look for:
- ✅ Success messages (green)
- ❌ Error messages (red)

Common errors:
- **Permission denied**: Check Firestore rules
- **Network error**: Check internet connection
- **Timeout**: Database might be slow, try again

#### 2. Check Firebase Console
Go to Firebase Console → Firestore Database:
- Should see `users` collection with 16 documents
- Should see `service_packages` collection with 21 documents

#### 3. Verify Service Types
In Firebase Console → `service_packages`:
- Check any Training package (dt_basic, dt_puppy, etc.)
- Field `serviceType` should be **"Training"** (not "Dog Training")

#### 4. Hot Restart App
After seeding, do a full restart:
- Stop the app completely
- Run `flutter run` again
- Or press 'R' in terminal

### Still Not Working?

**Check Firestore Rules:**

Your rules should allow authenticated writes:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Check Authentication:**

Make sure you're logged in:
- The seed screen requires authentication
- Sign in before accessing the screen

**Check Console Logs:**

Look for error messages in:
- Flutter console (terminal)
- Firebase Console → Firestore → Usage tab
- Chrome DevTools (if running on web)

## Expected Behavior

### Successful Seeding:
1. Button becomes disabled during seeding
2. Progress indicator shows
3. Logs appear in real-time:
   ```
   🌱 Starting data seeding...
   📝 Seeding 16 elite professional dog caregivers...
   ✅ Seeded 16 caregivers
   📝 Seeding 21 premium service packages...
   ✅ Seeded 21 service packages
   ✅ Firebase seeding completed successfully!
   ```
4. Green success snackbar appears
5. Status shows "Seeding completed successfully!"

### Successful Clearing:
1. Confirmation dialog appears
2. After confirming, progress indicator shows
3. Logs show:
   ```
   🗑️  Clearing all data...
   ✅ Cleared caregivers
   ✅ Cleared service packages
   ✅ All data cleared successfully!
   ```
4. Orange success snackbar appears

## What Changed (Latest Update)

### ✅ Fixed Issues:
1. **Service Type Mismatch**: Changed "Dog Training" → "Training"
2. **Missing Training Service**: Added to frontend (now shows 5 services)
3. **Using Old Seeder**: Updated to use `FirebaseSeederIndia` (enhanced version)
4. **Outdated Info**: Updated info card to show correct counts (16 caregivers, 21 packages)

### ✅ Now Includes:
- 16 caregivers (was 8)
- 21 packages (was 12)
- 5 service types (was 4)
- Training service with 5 packages
- Correct service type names

## Quick Reference

| Button | Action | Safe? | Time |
|--------|--------|-------|------|
| Seed All Data | Add 16 caregivers + 21 packages | ✅ Yes | 5-10s |
| Check Status | View database counts | ✅ Yes | 2-3s |
| Clear Seeded | Remove caregivers + packages only | ✅ Yes | 3-5s |
| Clear Entire DB | Delete EVERYTHING | ⚠️ NO | 10-30s |

## After Seeding Successfully

You should see in your app:

### Home Screen:
- 5 service cards (Dog Walking, Pet Sitting, Grooming, Training, Vet Visit)

### Service Selection:
- All 5 services listed with pricing

### Package Selection:
- Dog Walking: 4 packages
- Pet Sitting: 4 packages
- Grooming: 4 packages
- Training: 5 packages
- Vet Visit: 4 packages

### Caregiver List:
- 16 caregivers with photos, ratings, locations
- Filter by service type works
- All caregivers have realistic bios

---

**Last Updated**: February 27, 2026
**Status**: Fixed & Ready ✅
**Version**: 2.0 Enhanced
