import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore Diagnostic Tool
/// Use this to check what data exists in your Firestore database
class FirestoreDiagnostic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check all collections and print their contents
  Future<void> runDiagnostics() async {
    debugPrint('🔍 Running Firestore Diagnostics...\n');
    
    await _checkUsers();
    await _checkServicePackages();
    await _checkBookings();
    await _checkPets();
    
    debugPrint('\n✅ Diagnostics complete!');
  }

  /// Check users collection
  Future<void> _checkUsers() async {
    try {
      debugPrint('📊 Checking USERS collection...');
      
      final snapshot = await _firestore.collection('users').get();
      debugPrint('   Total users: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('   ⚠️  No users found!');
        return;
      }
      
      // Count by user type
      final owners = snapshot.docs.where((doc) => doc.data()['userType'] == 'owner').length;
      final caregivers = snapshot.docs.where((doc) => doc.data()['userType'] == 'caregiver').length;
      
      debugPrint('   - Pet Owners: $owners');
      debugPrint('   - Caregivers: $caregivers');
      
      // List caregiver names
      if (caregivers > 0) {
        debugPrint('   \n   Caregiver List:');
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['userType'] == 'caregiver') {
            debugPrint('   - ${data['name']} (${data['email']})');
          }
        }
      } else {
        debugPrint('   ❌ NO CAREGIVERS FOUND - Need to seed database!');
      }
      
    } catch (e) {
      debugPrint('   ❌ Error checking users: $e');
    }
  }

  /// Check service_packages collection
  Future<void> _checkServicePackages() async {
    try {
      debugPrint('\n📊 Checking SERVICE_PACKAGES collection...');
      
      final snapshot = await _firestore.collection('service_packages').get();
      debugPrint('   Total packages: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('   ❌ NO PACKAGES FOUND - Need to seed database!');
        return;
      }
      
      // Count by service type
      final services = <String, int>{};
      for (final doc in snapshot.docs) {
        final serviceType = doc.data()['serviceType'] as String;
        services[serviceType] = (services[serviceType] ?? 0) + 1;
      }
      
      debugPrint('   Packages by service:');
      services.forEach((service, packageCount) {
        debugPrint('   - $service: $packageCount packages');
      });
      
    } catch (e) {
      debugPrint('   ❌ Error checking packages: $e');
    }
  }

  /// Check bookings collection
  Future<void> _checkBookings() async {
    try {
      debugPrint('\n📊 Checking BOOKINGS collection...');
      
      final snapshot = await _firestore.collection('bookings').get();
      debugPrint('   Total bookings: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('   ℹ️  No bookings yet (this is normal for new setup)');
      }
      
    } catch (e) {
      debugPrint('   ❌ Error checking bookings: $e');
    }
  }

  /// Check pets collection
  Future<void> _checkPets() async {
    try {
      debugPrint('\n📊 Checking PETS collection...');
      
      final snapshot = await _firestore.collection('pets').get();
      debugPrint('   Total pets: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('   ℹ️  No pets yet (this is normal for new setup)');
      }
      
    } catch (e) {
      debugPrint('   ❌ Error checking pets: $e');
    }
  }

  /// Test if we can write to Firestore (check permissions)
  Future<void> testPermissions() async {
    debugPrint('\n🔐 Testing Firestore Permissions...\n');
    
    try {
      // Test write to service_packages
      debugPrint('   Testing write to service_packages...');
      await _firestore.collection('service_packages').doc('test_permission').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('service_packages').doc('test_permission').delete();
      debugPrint('   ✅ service_packages: Write permission OK');
      
    } catch (e) {
      debugPrint('   ❌ service_packages: Write DENIED - $e');
      debugPrint('   → You need to update Firestore rules!');
    }
    
    try {
      // Test write to users
      debugPrint('   Testing write to users...');
      await _firestore.collection('users').doc('test_permission').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('users').doc('test_permission').delete();
      debugPrint('   ✅ users: Write permission OK');
      
    } catch (e) {
      debugPrint('   ❌ users: Write DENIED - $e');
      debugPrint('   → You need to update Firestore rules!');
    }
  }
}
