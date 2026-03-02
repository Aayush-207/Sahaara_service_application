# 🔧 Seed Database Troubleshooting

## Quick Fix Checklist

If the seed buttons are "not working properly", follow this checklist:

### ✅ Step 1: Verify You're Using the Updated Screen

The screen should show:
- **Info card says**: "16 Elite caregiver profiles" (not 8)
- **Info card says**: "21 Service packages" (not 12)
- **Info card mentions**: "Training" service

If not, hot restart the app:
```bash
# Press 'R' in terminal or
flutter run
```

### ✅ Step 2: Check You're Logged In

The seed screen requires authentication:
1. Make sure you're signed in to the app
2. Check profile screen shows your name/email
3. If not logged in, sign in first

### ✅ Step 3: Check Firestore Rules

Your Firestore rules must allow writes:

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

To check/update:
1. Go to Firebase Console
2. Firestore Database → Rules tab
3. Verify rules allow authenticated writes
4. Publish if changed

### ✅ Step 4: Check Internet Connection

- Make sure device has internet
- Check Firebase project is accessible
- Try opening Firebase Console in browser

### ✅ Step 5: Look at the Logs

The seed screen shows logs at the bottom:

**Good logs (working):**
```
🌱 Starting data seeding...
📝 Seeding 16 elite professional dog caregivers...
✅ Seeded 16 caregivers
📝 Seeding 21 premium service packages...
✅ Seeded 21 service packages
✅ Firebase seeding completed successfully!
```

**Bad logs (errors):**
```
❌ Error: [permission-denied] Missing or insufficient permissions
❌ Error: [unavailable] The service is currently unavailable
❌ Error: [deadline-exceeded] Deadline exceeded
```

### ✅ Step 6: Clear and Re-seed

If packages are showing wrong service types:

1. **Clear Old Data**
   - Tap "Clear Seeded Data"
   - Confirm dialog
   - Wait for success

2. **Re-seed**
   - Tap "Seed All Data"
   - Wait 5-10 seconds
   - Check for success message

3. **Verify**
   - Tap "Check Database Status"
   - Should show: Users: 16, Packages: 21

4. **Hot Restart**
   - Stop app completely
   - Run again: `flutter run`

## Common Errors & Solutions

### Error: "Permission denied"

**Cause**: Firestore rules don't allow writes

**Solution**:
1. Go to Firebase Console → Firestore → Rules
2. Update rules to allow authenticated writes (see Step 3 above)
3. Click "Publish"
4. Try seeding again

### Error: "Network error" or "Unavailable"

**Cause**: No internet or Firebase is down

**Solution**:
1. Check device internet connection
2. Try opening Firebase Console in browser
3. Check Firebase Status: https://status.firebase.google.com/
4. Wait and try again

### Error: "Deadline exceeded" or "Timeout"

**Cause**: Operation taking too long

**Solution**:
1. Check internet speed
2. Try again (might be temporary)
3. Clear data first, then seed (smaller operation)

### No Error, But Packages Not Showing

**Cause**: Service type mismatch or cache issue

**Solution**:
1. Clear seeded data
2. Hot restart app (full restart, not hot reload)
3. Re-seed data
4. Check Firebase Console to verify service types

### Seeding Works, But Still See Old Data

**Cause**: App cache or didn't restart

**Solution**:
1. Stop app completely
2. Clear app data (optional)
3. Run `flutter run` again
4. Check again

## Verify in Firebase Console

After seeding, check Firebase Console:

### 1. Check Users Collection
- Go to Firestore → `users` collection
- Should see 16 documents
- IDs like: `caregiver_priya_sharma`, `caregiver_rahul_verma`, etc.
- Each should have:
  - `userType: "caregiver"`
  - `name`, `email`, `rating`, `services`, etc.

### 2. Check Service Packages Collection
- Go to Firestore → `service_packages` collection
- Should see 21 documents
- IDs like: `dw_basic`, `ds_standard`, `dg_premium`, `dt_basic`, `vv_companion`, etc.

### 3. Verify Service Types
Click on any Training package (dt_basic, dt_puppy, etc.):
- Field `serviceType` should be **"Training"**
- NOT "Dog Training"

If you see "Dog Training":
1. You're looking at old data
2. Clear and re-seed
3. Or manually edit in Firebase Console

## Still Not Working?

### Check Flutter Console

Look for error messages in terminal:
```bash
flutter run
# Watch for error messages when tapping buttons
```

Common messages:
- `[ERROR:flutter/...] Unhandled Exception:` - Shows actual error
- `PlatformException` - Usually permission or network issue
- `FirebaseException` - Firebase-specific error

### Enable Debug Logging

Add this to see more details:

```dart
// In admin_seed_screen.dart, add to _seedAllData():
try {
  debugPrint('Starting seed...');
  await _seeder.seedAll();
  debugPrint('Seed completed!');
} catch (e, stackTrace) {
  debugPrint('Error: $e');
  debugPrint('Stack: $stackTrace');  // Add this line
  // ... rest of error handling
}
```

### Check Firebase Quotas

If seeding fails repeatedly:
1. Go to Firebase Console → Usage
2. Check if you've hit any limits:
   - Reads/Writes per day
   - Document count
   - Storage size
3. Upgrade plan if needed (Spark → Blaze)

## Manual Verification Steps

### 1. Test Each Service Type

After seeding, test each service:

```
Home → Dog Walking → Should show 4 packages
Home → Pet Sitting → Should show 4 packages
Home → Grooming → Should show 4 packages
Home → Training → Should show 5 packages
Home → Vet Visit → Should show 4 packages
```

If any service shows 0 packages:
- Check service type in Firebase Console
- Verify exact spelling matches
- Re-seed if needed

### 2. Test Caregiver List

```
Home → Browse Caregivers → Should show 16 caregivers
```

If showing 0 caregivers:
- Check `users` collection in Firebase
- Verify `userType: "caregiver"` field
- Re-seed if needed

### 3. Test Filters

```
Browse Caregivers → Filter by "Training"
Should show caregivers offering Training service
```

If filter shows 0 results:
- Check caregiver `services` array
- Should include "Training" (not "Dog Training")

## Emergency: Start Fresh

If nothing works, start completely fresh:

### 1. Clear Entire Database
```
Admin Seed Screen → ⚠️ CLEAR ENTIRE DATABASE
Confirm the scary dialog
Wait for completion
```

### 2. Re-seed
```
Admin Seed Screen → Seed All Data
Wait for completion
```

### 3. Full App Restart
```bash
# Stop app
flutter clean
flutter pub get
flutter run
```

### 4. Verify Everything
- Check all 5 services
- Check all 21 packages
- Check all 16 caregivers
- Test filters

## Contact Points

If still having issues:

1. **Check logs**: Look at Flutter console output
2. **Check Firebase**: Verify data in Firebase Console
3. **Check rules**: Ensure Firestore rules allow writes
4. **Check auth**: Make sure you're logged in
5. **Check network**: Verify internet connection

## Success Indicators

You'll know it's working when:

✅ Logs show success messages
✅ Green snackbar appears
✅ Status shows "completed successfully"
✅ Check Status shows 16 users, 21 packages
✅ Firebase Console shows data
✅ App displays all services and packages
✅ Filters work correctly

---

**Last Updated**: February 27, 2026
**Need Help?** Check logs first, then Firebase Console
