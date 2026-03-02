# 🗄️ Database Management Guide

## Overview

This guide explains how to manage your Firestore database, including seeding data and clearing the database.

---

## 🎯 Accessing Database Management

### In the App:
1. Open the app
2. Go to **Profile** screen (bottom navigation)
3. Scroll down to find the **"🔧 Seed Database"** button
4. Tap it to open the **Admin Seed Screen**

---

## 🛠️ Available Operations

### 1. Seed All Data ✅
**What it does:**
- Creates 10 professional caregiver profiles
- Creates 12 service packages (4 services × 3 tiers)
- All data follows industry standards

**When to use:**
- First time setup
- After clearing the database
- When you need sample data for testing

**How to use:**
1. Tap **"Seed All Data"** button
2. Wait 10-20 seconds
3. Check logs for confirmation

---

### 2. Check Database Status 📊
**What it does:**
- Shows count of all documents in database:
  - Users (Owners & Caregivers)
  - Pets
  - Bookings
  - Service Packages
  - Reviews
  - Chats & Messages
- Displays total document count

**When to use:**
- Before clearing database (to see what will be deleted)
- After seeding (to verify data was created)
- To monitor database growth

**How to use:**
1. Tap **"Check Database Status"** button
2. View counts in the logs section

**Example Output:**
```
📊 DATABASE STATUS CHECK

👥 Users: 15 (Owners: 5, Caregivers: 10)
🐾 Pets: 8
📅 Bookings: 12
📦 Service Packages: 12
⭐ Reviews: 5
💬 Chats: 3 (Messages: 45)

📊 TOTAL DOCUMENTS: 100
```

---

### 3. Clear Seeded Data 🗑️
**What it does:**
- Deletes ONLY seeded caregivers
- Deletes ONLY service packages
- Keeps user accounts, pets, bookings, chats

**When to use:**
- Want to re-seed with fresh data
- Remove sample caregivers
- Keep your personal data intact

**How to use:**
1. Tap **"Clear Seeded Data"** button
2. Confirm the action
3. Wait for completion

**⚠️ Warning:** This cannot be undone!

---

### 4. ⚠️ CLEAR ENTIRE DATABASE 🚨
**What it does:**
- Deletes **EVERYTHING** in the database:
  - ❌ ALL users (owners AND caregivers)
  - ❌ ALL pets
  - ❌ ALL bookings
  - ❌ ALL chats and messages
  - ❌ ALL reviews
  - ❌ ALL service packages

**When to use:**
- Complete database reset
- Starting fresh from scratch
- Testing purposes only
- **NEVER in production!**

**How to use:**
1. Tap **"⚠️ CLEAR ENTIRE DATABASE"** button (red button)
2. Read the warning dialog carefully
3. Confirm by tapping **"YES, DELETE EVERYTHING"**
4. Wait for completion (may take 30-60 seconds)

**🚨 EXTREME CAUTION:**
- This action is **IRREVERSIBLE**
- You will lose **ALL DATA**
- You will need to create a new account
- You will need to re-seed the database

---

## 📋 Common Workflows

### First Time Setup
```
1. Sign up in the app
2. Go to Profile → Seed Database
3. Tap "Seed All Data"
4. Wait for completion
5. Start using the app
```

### Reset and Start Fresh
```
1. Go to Profile → Seed Database
2. Tap "Check Database Status" (optional - to see what you have)
3. Tap "⚠️ CLEAR ENTIRE DATABASE"
4. Confirm the action
5. Close the app
6. Sign up with a new account
7. Tap "Seed All Data"
8. Start fresh
```

### Re-seed Caregivers Only
```
1. Go to Profile → Seed Database
2. Tap "Clear Seeded Data"
3. Tap "Seed All Data"
4. Your personal data remains intact
```

### Check What's in Database
```
1. Go to Profile → Seed Database
2. Tap "Check Database Status"
3. View counts in logs
```

---

## 🔍 Understanding the Logs

The logs section shows real-time progress:

### Seeding Logs:
```
12:34:56 - 🌱 Starting data seeding...
12:34:57 - 📝 Seeding caregivers...
12:34:58 - ✅ Seeded 10 caregivers
12:34:59 - 📝 Seeding service packages...
12:35:00 - ✅ Seeded 12 service packages
12:35:01 - ✅ Firebase seeding completed successfully!
```

### Status Check Logs:
```
12:36:00 - 📊 Checking database status...
12:36:01 - 👥 Users: 15 (Owners: 5, Caregivers: 10)
12:36:01 - 🐾 Pets: 8
12:36:01 - 📅 Bookings: 12
12:36:01 - 📦 Service Packages: 12
12:36:01 - ⭐ Reviews: 5
12:36:01 - 💬 Chats: 3 (Messages: 45)
12:36:01 - 📊 TOTAL DOCUMENTS: 100
12:36:02 - ✅ Status check completed!
```

### Clearing Logs:
```
12:37:00 - 🚨 WARNING: Clearing ENTIRE database...
12:37:01 - 🗑️  Deleting users collection...
12:37:02 -    Deleted 15 documents from users
12:37:02 -    ✅ Total deleted from users: 15
12:37:03 - 🗑️  Deleting pets collection...
12:37:04 -    Deleted 8 documents from pets
12:37:04 -    ✅ Total deleted from pets: 8
... (continues for all collections)
12:37:10 - ✅ ENTIRE DATABASE CLEARED!
12:37:10 - 📊 Total documents deleted: 100
12:37:10 - 🎉 Database is now completely empty!
```

---

## ⚠️ Important Notes

### Security
- These operations require authentication
- Only authenticated users can access this screen
- Firestore security rules must allow these operations

### Performance
- **Seeding:** Takes 10-20 seconds
- **Status Check:** Takes 2-5 seconds
- **Clear Seeded Data:** Takes 5-10 seconds
- **Clear Entire Database:** Takes 30-60 seconds (depends on data size)

### Limitations
- Batch operations limited to 500 documents at a time
- Large databases may take longer to clear
- Network speed affects operation time

### Best Practices
1. **Always check status before clearing**
2. **Use "Clear Seeded Data" instead of "Clear Entire Database" when possible**
3. **Never use "Clear Entire Database" in production**
4. **Backup important data before clearing**
5. **Test on a development database first**

---

## 🐛 Troubleshooting

### "Permission Denied" Error / "Clearing Failed"
**This is the most common issue!**

**Problem:** Firestore rules are too restrictive. Users can only delete their own data, but the clear function needs to delete ALL data.

**Solution:** Update Firestore security rules to development mode.

**Quick Fix:**
1. Open Firebase Console: https://console.firebase.google.com/
2. Go to **Firestore Database** → **Rules** tab
3. Copy rules from **FIRESTORE_RULES_DEVELOPMENT.txt**
4. Paste in Firebase Console
5. Click **Publish**
6. Wait 1-2 minutes for rules to propagate
7. Try clearing again in the app

**Detailed Instructions:** See **FIRESTORE_RULES_FIX.md** for complete guide.

**⚠️ Important:** Use development rules only for testing. Switch to production rules (FIRESTORE_RULES_FINAL.txt) before deploying to users.

### "Operation Timeout"
**Solution:** 
- Check internet connection
- Try again with fewer documents
- Clear collections one at a time

### "No Caregivers Showing After Seeding"
**Solution:**
1. Check logs for errors
2. Run "Check Database Status"
3. Restart the app
4. Try seeding again

### "Clear Operation Incomplete"
**Solution:**
1. Run "Check Database Status" to see what remains
2. Run the clear operation again
3. Check Firestore Console for manual cleanup

---

## 📊 Database Structure

### Collections:
- **users** - User accounts (owners & caregivers)
- **pets** - Pet profiles
- **bookings** - Service bookings
- **service_packages** - Service offerings
- **reviews** - Caregiver reviews
- **chats** - Chat conversations
  - **messages** (subcollection) - Chat messages

### Seeded Data:
- **10 Caregivers** with realistic profiles
- **12 Service Packages** across 4 service types:
  - Dog Walking (3 packages)
  - Pet Sitting (3 packages)
  - Grooming (3 packages)
  - Vet Visit (3 packages)

---

## 🔐 Security Considerations

### Production Environment:
- **DISABLE** the "Clear Entire Database" button
- **RESTRICT** access to admin screen
- **IMPLEMENT** role-based access control
- **LOG** all database operations
- **BACKUP** database regularly

### Development Environment:
- Use freely for testing
- Clear and re-seed as needed
- Test different scenarios

---

## 📞 Support

### Issues?
1. Check logs for error messages
2. Verify internet connection
3. Check Firebase Console for quota limits
4. Review Firestore security rules

### Need Help?
- See [SETUP_GUIDE.md](SETUP_GUIDE.md) for Firebase setup
- See [BUG_FIXES_APPLIED.md](BUG_FIXES_APPLIED.md) for known issues
- Check Firebase Console for backend errors

---

## ✅ Quick Reference

| Operation | Time | Reversible | Data Affected |
|-----------|------|------------|---------------|
| Seed All Data | 10-20s | Yes (can clear) | Adds caregivers & packages |
| Check Status | 2-5s | N/A | Read-only |
| Clear Seeded Data | 5-10s | No | Caregivers & packages only |
| Clear Entire Database | 30-60s | **NO** | **EVERYTHING** |

---

**Remember:** Always check database status before clearing, and use the appropriate clear operation for your needs!

**Last Updated:** February 26, 2026
