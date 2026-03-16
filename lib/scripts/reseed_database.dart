import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';
import '../utils/firebase_seeder_2026_india.dart';

/// Re-seed Database Script
/// 
/// This script will:
/// 1. Clear all existing seeded data (caregivers and service packages)
/// 2. Re-seed with 2026 India research-based data
/// 
/// Run this to seed the database with fresh data
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final seeder = FirebaseSeeder2026India();
  
  debugPrint('\n📊 Current database status:');
  await seeder.checkDatabaseStatus();
  
  debugPrint('\n🗑️  Clearing old seeded data...');
  await seeder.clearAllData();
  
  debugPrint('\n🌱 Re-seeding with corrected service types...');
  await seeder.seedAll();
  
  debugPrint('\n✅ Re-seeding complete!');
  debugPrint('\n📊 New database status:');
  await seeder.checkDatabaseStatus();
  
  debugPrint('\n🎉 Done! Service types are now correct:');
  debugPrint('   - Dog Walking ✅');
  debugPrint('   - Pet Sitting ✅');
  debugPrint('   - Grooming ✅');
  debugPrint('   - Training ✅');
  debugPrint('   - Vet Visit ✅');
  debugPrint('\n📊 Seeded 15 caregivers + 30 service packages');
}
