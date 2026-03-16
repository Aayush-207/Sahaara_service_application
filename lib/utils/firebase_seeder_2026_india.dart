import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/service_package_model.dart';

/// 🇮🇳 PREMIUM Firebase Data Seeder 2026 - India Edition
/// 
/// Research-Based Data for Indian Pet Care Marketplace
/// 
/// 📊 MARKET RESEARCH (2024-2026):
/// - India's pet care market: USD 7B by 2028, USD 25B by 2032
/// - 32 million households own dogs (2024)
/// - 68% of pet owners choose dogs as companions
/// - 20% CAGR growth in pet care industry
/// 
/// 💰 PRICING RESEARCH (India 2024-2026):
/// Based on BringFido, Petboro, DeePet Services, Vetic, MaxPetZ
/// 
/// Dog Walking:
/// - Quick Walk (15-20 min): ₹150-250
/// - Standard Walk (30-45 min): ₹300-450
/// - Extended Walk (1 hour): ₹500-650
/// - Premium Trail (1.5-2 hrs): ₹800-1200
/// 
/// Pet Sitting:
/// - Basic (4-6 hrs): ₹400-600
/// - Day Care (8-10 hrs): ₹700-1000
/// - Overnight (24 hrs): ₹1200-1800
/// - Extended Stay (per day): ₹1000-1500
/// 
/// Dog Grooming:
/// - Bath & Brush: ₹500-800
/// - Full Grooming: ₹800-1200
/// - Premium Spa: ₹1200-1800
/// - Luxury Treatment: ₹1800-2500
/// 
/// Dog Training:
/// - Basic Obedience (1 session): ₹800-1200
/// - Advanced Training (1 session): ₹1200-1800
/// - Behavior Modification: ₹1500-2500
/// - 5-Session Package: ₹5000-8000
/// - 10-Session Program: ₹9000-15000
/// 
/// Vet Companion:
/// - Transport Only: ₹300-500
/// - Vet Visit Companion: ₹500-800
/// - Emergency Support: ₹800-1200
/// - Full Day Care: ₹1200-2000
/// 
/// 🏙️ TOP PET-FRIENDLY CITIES IN INDIA:
/// 1. Mumbai - Maximum pet services, clinics, parks
/// 2. Bangalore - Tech hub with modern pet care
/// 3. Pune - Growing pet care market
/// 4. Delhi/NCR - Large pet owner base
/// 5. Hyderabad - Emerging pet-friendly city
/// 6. Chennai - Strong veterinary network
/// 
/// 🐕 MOST POPULAR DOG BREEDS IN INDIA (2024-2026):
/// International: Labrador (63%), Golden Retriever, German Shepherd, Beagle, Pug, Shih Tzu
/// Indian Native: Indian Pariah, Rajapalayam, Mudhol Hound, Kombai, Chippiparai
/// 
/// Usage:
/// ```dart
/// final seeder = FirebaseSeeder2026India();
/// await seeder.clearAllData(); // Clear existing data first
/// await seeder.seedAll(); // Seed fresh data
/// ```
class FirebaseSeeder2026India {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clear ALL data from Firebase (use with caution!)
  Future<void> clearAllData() async {
    debugPrint('🗑️  Starting complete Firebase data cleanup...');
    
    try {
      // Clear users collection (caregivers only, not real users)
      await _clearCollection('users', whereField: 'userType', whereValue: 'caregiver');
      
      // Clear service packages
      await _clearCollection('service_packages');
      
      // Clear adoptable pets
      await _clearCollection('adoptable_pets');
      
      // Clear bookings
      await _clearCollection('bookings');
      
      // Clear reviews
      await _clearCollection('reviews');
      
      debugPrint('✅ Firebase cleanup completed successfully!');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Clear ENTIRE database - ALL collections (DANGER!)
  Future<void> clearEntireDatabase() async {
    debugPrint('🚨 WARNING: Clearing ENTIRE database...');
    
    int successCount = 0;
    int errorCount = 0;
    
    // List of all collections to clear
    final collections = [
      'chats',
      'chat_rooms', 
      'users',
      'pets',
      'bookings',
      'service_packages',
      'adoptable_pets',
      'reviews',
      'messages',
      'favorites',
      'user_favorites',
      'reports',
    ];
    
    for (final collectionName in collections) {
      try {
        if (collectionName == 'chats') {
          await _clearChatsWithMessages();
        } else {
          await _clearCollection(collectionName);
        }
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('  ⚠️  Skipping $collectionName: $e');
        // Continue with other collections even if one fails
      }
    }
    
    debugPrint('✅ Database clearing completed!');
    debugPrint('   Success: $successCount collections');
    if (errorCount > 0) {
      debugPrint('   Skipped: $errorCount collections (may not exist or permission denied)');
    }
  }

  /// Clear chats collection with messages subcollections
  Future<void> _clearChatsWithMessages() async {
    debugPrint('  Clearing chats with messages...');
    
    try {
      final chatsSnapshot = await _firestore.collection('chats').get();
      
      if (chatsSnapshot.docs.isEmpty) {
        debugPrint('  ✓ chats collection is already empty');
        return;
      }
      
      int totalDeleted = 0;
      
      // Delete messages subcollection for each chat
      for (var chatDoc in chatsSnapshot.docs) {
        final messagesSnapshot = await chatDoc.reference.collection('messages').get();
        
        if (messagesSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var messageDoc in messagesSnapshot.docs) {
            batch.delete(messageDoc.reference);
            totalDeleted++;
          }
          await batch.commit();
          debugPrint('    Deleted ${messagesSnapshot.docs.length} messages from chat ${chatDoc.id}');
        }
        
        // Delete the chat document itself
        await chatDoc.reference.delete();
        totalDeleted++;
      }
      
      debugPrint('  ✓ Cleared ${chatsSnapshot.docs.length} chats with their messages (total: $totalDeleted documents)');
    } catch (e) {
      debugPrint('  ✗ Error clearing chats: $e');
      rethrow;
    }
  }

  /// Helper method to clear a collection
  Future<void> _clearCollection(String collectionName, {String? whereField, dynamic whereValue}) async {
    debugPrint('  Clearing $collectionName...');
    
    try {
      Query query = _firestore.collection(collectionName);
      
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('  ✓ $collectionName is already empty');
        return;
      }
      
      // Delete in batches of 500 (Firestore limit)
      final batch = _firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;
        
        if (count >= 500) {
          await batch.commit();
          count = 0;
        }
      }
      
      if (count > 0) {
        await batch.commit();
      }
      
      debugPrint('  ✓ Cleared ${snapshot.docs.length} documents from $collectionName');
    } catch (e) {
      debugPrint('  ✗ Error clearing $collectionName: $e');
      rethrow;
    }
  }

  /// Seed all data (caregivers, packages, pets, bookings, reviews)
  Future<void> seedAll() async {
    debugPrint('🌱 Starting Firebase data seeding with 2026 India research data...');
    
    try {
      await seedCaregivers();
      await seedServicePackages();
      await seedAdoptablePets();
      await seedSampleBookings();
      await seedSampleReviews();
      
      debugPrint('✅ Firebase seeding completed successfully!');
      debugPrint('📊 Seeded: 15 caregivers + 30 packages + 10 pets + 15 bookings + 25 reviews');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  /// Seed 15 elite professional caregivers across major Indian cities
  /// 
  /// Cities covered: Mumbai (4), Bangalore (3), Pune (3), Delhi (2), Hyderabad (2), Chennai (1)
  /// Specializations: Training, Walking, Grooming, Behavior, Vet Care, Native Breeds
  Future<void> seedCaregivers() async {
    debugPrint('📝 Seeding 15 elite professional caregivers across India...');

    final caregivers = [
      // MUMBAI - Maximum Pet Services Hub (4 caregivers)
      UserModel(
        uid: 'caregiver_priya_mumbai',
        email: 'priya.sharma@sahara.app',
        name: 'Priya Sharma',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/1.jpg',
        rating: 4.9,
        completedBookings: 342,
        createdAt: DateTime.now().subtract(const Duration(days: 950)),
        bio: '🏆 Certified Professional Dog Trainer (CPDT-KA) with 10+ years in Mumbai. Specialized in positive reinforcement, obedience, and behavioral modification. Successfully trained 600+ dogs including Labradors, Golden Retrievers, and Indian Pariah dogs. Member of Association of Professional Dog Trainers (APDT). Pet First Aid & CPR certified. Featured trainer at Mumbai Pet Expo 2025. Offer in-home sessions, group classes, and virtual consultations.',
        services: ['Dog Walking', 'Pet Sitting', 'Dog Training', 'Grooming', 'Vet Visit'],
        hourlyRate: null,
        location: 'Bandra West, Mumbai, Maharashtra',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43210',
      ),
      UserModel(
        uid: 'caregiver_rahul_mumbai',
        email: 'rahul.verma@sahara.app',
        name: 'Rahul Verma',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/71.jpg',
        rating: 4.8,
        completedBookings: 298,
        createdAt: DateTime.now().subtract(const Duration(days: 820)),
        bio: '🐕 Professional Dog Walker & Pet Sitter with 8 years experience in Mumbai. Specialized in high-energy breeds and senior dog care. Completed 5000+ walks across Marine Drive, Juhu Beach, and Powai Lake. Certified in Pet First Aid. Expert in handling multiple dogs simultaneously. Available for early morning and late evening walks. Trusted by 150+ families in Mumbai.',
        services: ['Dog Walking', 'Pet Sitting', 'Vet Visit'],
        hourlyRate: null,
        location: 'Powai, Mumbai, Maharashtra',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43211',
      ),
      UserModel(
        uid: 'caregiver_anjali_mumbai',
        email: 'anjali.patel@sahara.app',
        name: 'Anjali Patel',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/11.jpg',
        rating: 4.9,
        completedBookings: 415,
        createdAt: DateTime.now().subtract(const Duration(days: 1100)),
        bio: '✨ Master Pet Groomer with 12 years experience. Certified by National Dog Groomers Association of India (NDGAI). Specialized in breed-specific grooming, spa treatments, and creative styling. Expert in handling anxious pets. Use only premium, pet-safe products. Completed 3000+ grooming sessions. Winner of Best Groomer Award Mumbai 2024. Mobile grooming van available.',
        services: ['Grooming', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Andheri East, Mumbai, Maharashtra',
        yearsOfExperience: 12,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43212',
      ),
      UserModel(
        uid: 'caregiver_vikram_mumbai',
        email: 'vikram.singh@sahara.app',
        name: 'Vikram Singh',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/46.jpg',
        rating: 4.7,
        completedBookings: 256,
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
        bio: '🎓 Certified Animal Behaviorist with 9 years experience. Specialized in aggression management, anxiety disorders, and rescue dog rehabilitation. Worked with 400+ dogs including street rescues and Indian native breeds. Certified in Applied Animal Behavior. Conduct behavior assessments and customized training plans. Available for home visits and emergency consultations.',
        services: ['Dog Training', 'Pet Sitting', 'Vet Visit'],
        hourlyRate: null,
        location: 'Thane West, Mumbai, Maharashtra',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43213',
      ),

      // BANGALORE - Tech Hub with Modern Pet Care (3 caregivers)
      UserModel(
        uid: 'caregiver_meera_bangalore',
        email: 'meera.reddy@sahara.app',
        name: 'Meera Reddy',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/25.jpg',
        rating: 4.9,
        completedBookings: 378,
        createdAt: DateTime.now().subtract(const Duration(days: 1020)),
        bio: '🌟 Premium Pet Care Specialist with 11 years in Bangalore. Certified Veterinary Assistant with expertise in senior dog care and special needs pets. Administered 2000+ medications and treatments. Expert in diabetic pet care, post-surgery recovery, and chronic illness management. Available 24/7 for emergency pet sitting. Trusted by veterinarians across Bangalore.',
        services: ['Pet Sitting', 'Vet Visit', 'Dog Walking'],
        hourlyRate: null,
        location: 'Koramangala, Bangalore, Karnataka',
        yearsOfExperience: 11,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43214',
      ),
      UserModel(
        uid: 'caregiver_arjun_bangalore',
        email: 'arjun.kumar@sahara.app',
        name: 'Arjun Kumar',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/60.jpg',
        rating: 4.8,
        completedBookings: 289,
        createdAt: DateTime.now().subtract(const Duration(days: 680)),
        bio: '🏃 Professional Dog Walker & Fitness Trainer for Dogs. 7 years experience with high-energy breeds. Specialized in agility training, jogging companions, and adventure walks. Completed 4000+ walks in Cubbon Park, Lalbagh, and Ulsoor Lake. Certified in Canine Fitness. GPS tracking provided for all walks. Perfect for working professionals.',
        services: ['Dog Walking', 'Dog Training', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Indiranagar, Bangalore, Karnataka',
        yearsOfExperience: 7,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43215',
      ),
      UserModel(
        uid: 'caregiver_sneha_bangalore',
        email: 'sneha.desai@sahara.app',
        name: 'Sneha Desai',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/67.jpg',
        rating: 4.9,
        completedBookings: 325,
        createdAt: DateTime.now().subtract(const Duration(days: 890)),
        bio: '💅 Celebrity Pet Groomer with 10 years experience. Trained at International Professional Groomers. Specialized in show dog preparation, creative grooming, and spa treatments. Featured in Bangalore Pet Magazine 2025. Use organic, hypoallergenic products. Expert in breed-specific cuts. Served 200+ celebrity pets. Home service and salon available.',
        services: ['Grooming', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Whitefield, Bangalore, Karnataka',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43216',
      ),

      // PUNE - Growing Pet Care Market (3 caregivers)
      UserModel(
        uid: 'caregiver_rohan_pune',
        email: 'rohan.kapoor@sahara.app',
        name: 'Rohan Kapoor',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/74.jpg',
        rating: 4.8,
        completedBookings: 267,
        createdAt: DateTime.now().subtract(const Duration(days: 750)),
        bio: '🐾 Expert in Indian Native Breeds with 8 years experience. Specialized in Rajapalayam, Mudhol Hound, Indian Pariah, and Kombai dogs. Advocate for native breed adoption and preservation. Certified trainer with focus on traditional Indian training methods. Completed 300+ training programs. Regular speaker at Pune Dog Shows. Bilingual (English/Marathi).',
        services: ['Dog Training', 'Dog Walking', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Koregaon Park, Pune, Maharashtra',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43217',
      ),
      UserModel(
        uid: 'caregiver_kavita_pune',
        email: 'kavita.rao@sahara.app',
        name: 'Kavita Rao',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/32.jpg',
        rating: 4.9,
        completedBookings: 312,
        createdAt: DateTime.now().subtract(const Duration(days: 920)),
        bio: '🏥 Veterinary Nurse turned Pet Care Specialist. 10 years experience in medical pet care. Expert in administering medications, wound care, and post-operative care. Worked at Pune Veterinary Hospital for 5 years. Specialized in geriatric pet care and chronic illness management. Available for overnight medical monitoring. Trusted by 100+ veterinarians.',
        services: ['Pet Sitting', 'Vet Visit', 'Dog Walking'],
        hourlyRate: null,
        location: 'Aundh, Pune, Maharashtra',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43218',
      ),
      UserModel(
        uid: 'caregiver_amit_pune',
        email: 'amit.gupta@sahara.app',
        name: 'Amit Gupta',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/33.jpg',
        rating: 4.7,
        completedBookings: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 650)),
        bio: '🚶 Professional Dog Walker with 7 years experience in Pune. Specialized in group walks and socialization. Conduct daily walks in Baner Hills, Pashan Lake, and Vetal Tekdi. Expert in handling reactive dogs and puppies. GPS tracking and photo updates provided. Flexible timing for working professionals. Completed 3500+ walks.',
        services: ['Dog Walking', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Baner, Pune, Maharashtra',
        yearsOfExperience: 7,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43219',
      ),

      // DELHI/NCR - Large Pet Owner Base (2 caregivers)
      UserModel(
        uid: 'caregiver_neha_delhi',
        email: 'neha.joshi@sahara.app',
        name: 'Neha Joshi',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/24.jpg',
        rating: 4.9,
        completedBookings: 356,
        createdAt: DateTime.now().subtract(const Duration(days: 980)),
        bio: '👑 Premium Pet Grooming & Spa Specialist. 11 years experience in Delhi NCR. Certified by International Professional Groomers. Specialized in luxury spa treatments, aromatherapy, and breed-specific styling. Served 500+ premium clients. Use imported organic products. Mobile grooming service available. Featured in Delhi Times Pet Special 2025.',
        services: ['Grooming', 'Pet Sitting', 'Dog Walking'],
        hourlyRate: null,
        location: 'Defence Colony, New Delhi, Delhi',
        yearsOfExperience: 11,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43220',
      ),
      UserModel(
        uid: 'caregiver_sanjay_gurgaon',
        email: 'sanjay.mehta@sahara.app',
        name: 'Sanjay Mehta',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/55.jpg',
        rating: 4.8,
        completedBookings: 278,
        createdAt: DateTime.now().subtract(const Duration(days: 780)),
        bio: '🎯 Certified Dog Trainer specializing in Protection & Guard Dogs. 9 years experience training German Shepherds, Rottweilers, and Dobermans. Former K9 handler. Expert in obedience, protection work, and security training. Trained 200+ guard dogs for homes and businesses. Offer customized training programs. Available in Gurgaon and Delhi NCR.',
        services: ['Dog Training', 'Dog Walking', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Sector 45, Gurgaon, Haryana',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43221',
      ),

      // HYDERABAD - Emerging Pet-Friendly City (2 caregivers)
      UserModel(
        uid: 'caregiver_divya_hyderabad',
        email: 'divya.iyer@sahara.app',
        name: 'Divya Iyer',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/45.jpg',
        rating: 4.9,
        completedBookings: 298,
        createdAt: DateTime.now().subtract(const Duration(days: 850)),
        bio: '🌸 Holistic Pet Care Specialist with 10 years experience. Certified in Pet Aromatherapy, Reiki, and Massage Therapy. Specialized in anxiety relief, stress management, and senior dog wellness. Conduct wellness workshops. Use natural, chemical-free products. Expert in calming nervous pets. Trusted by 150+ families in Hyderabad.',
        services: ['Pet Sitting', 'Grooming', 'Dog Walking'],
        hourlyRate: null,
        location: 'Banjara Hills, Hyderabad, Telangana',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43222',
      ),
      UserModel(
        uid: 'caregiver_karthik_hyderabad',
        email: 'karthik.nair@sahara.app',
        name: 'Karthik Nair',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/28.jpg',
        rating: 4.8,
        completedBookings: 245,
        createdAt: DateTime.now().subtract(const Duration(days: 690)),
        bio: '🏋️ Canine Fitness & Agility Trainer. 8 years experience in dog sports and fitness. Certified in Canine Conditioning. Specialized in agility training, flyball, and dock diving. Conduct fitness classes at Hyderabad Dog Park. Expert in weight management programs. Trained 150+ dogs for competitions. Perfect for active breeds.',
        services: ['Dog Training', 'Dog Walking', 'Pet Sitting'],
        hourlyRate: null,
        location: 'Hitech City, Hyderabad, Telangana',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43223',
      ),

      // CHENNAI - Strong Veterinary Network (1 caregiver)
      UserModel(
        uid: 'caregiver_aditya_chennai',
        email: 'aditya.singh@sahara.app',
        name: 'Aditya Singh',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/12.jpg',
        rating: 4.8,
        completedBookings: 267,
        createdAt: DateTime.now().subtract(const Duration(days: 720)),
        bio: '🐕‍🦺 Professional Dog Trainer & Behaviorist. 8 years experience in Chennai. Specialized in puppy training, socialization, and basic obedience. Certified by Karen Pryor Academy. Expert in positive reinforcement methods. Conducted 400+ training sessions. Available for in-home training and group classes. Bilingual (English/Tamil).',
        services: ['Dog Training', 'Dog Walking', 'Pet Sitting', 'Vet Visit'],
        hourlyRate: null,
        location: 'Adyar, Chennai, Tamil Nadu',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43224',
      ),
    ];

    // Seed caregivers to Firestore
    final batch = _firestore.batch();
    for (var caregiver in caregivers) {
      final docRef = _firestore.collection('users').doc(caregiver.uid);
      batch.set(docRef, caregiver.toMap());
    }
    
    await batch.commit();
    debugPrint('✅ Seeded ${caregivers.length} caregivers successfully!');
  }

  /// Seed 30 comprehensive service packages with research-based India pricing
  /// 
  /// Based on 2024-2026 market research from:
  /// - BringFido India, Petboro, DeePet Services
  /// - Vetic, MaxPetZ, YesPaws
  /// - India Pet Industry Report 2024
  Future<void> seedServicePackages() async {
    debugPrint('📦 Seeding 30 service packages with India 2026 pricing...');

    final packages = [
      // DOG WALKING PACKAGES (6 packages)
      ServicePackageModel(
        id: 'walk_quick_2026',
        serviceType: 'Dog Walking',
        packageName: 'Quick Break Walk',
        description: 'Perfect for busy schedules. Quick 15-20 minute neighborhood walk for bathroom breaks and light exercise. Ideal for senior dogs or puppies.',
        price: 200,
        duration: '15-20 minutes',
        features: [
          '15-20 minute walk',
          'Neighborhood route',
          'Bathroom break',
          'Light exercise',
          'Photo updates',
          'GPS tracking',
        ],
      ),
      ServicePackageModel(
        id: 'walk_standard_2026',
        serviceType: 'Dog Walking',
        packageName: 'Standard Walk',
        description: 'Most popular choice. 30-45 minute walk with moderate exercise and socialization. Perfect for daily routine and maintaining fitness.',
        price: 375,
        duration: '30-45 minutes',
        features: [
          '30-45 minute walk',
          'Park or trail route',
          'Moderate exercise',
          'Socialization time',
          'Water break included',
          'Photo & video updates',
          'GPS tracking',
        ],
      ),
      ServicePackageModel(
        id: 'walk_extended_2026',
        serviceType: 'Dog Walking',
        packageName: 'Extended Adventure',
        description: 'For active dogs. Full 1-hour walk with high energy activities. Includes playtime, training exercises, and exploration of new areas.',
        price: 575,
        duration: '1 hour',
        features: [
          '1 hour walk',
          'Extended trail or park',
          'High energy activities',
          'Playtime included',
          'Basic training exercises',
          'Socialization with other dogs',
          'Multiple photo updates',
          'GPS tracking',
          'Treats included',
        ],
      ),
      ServicePackageModel(
        id: 'walk_premium_2026',
        serviceType: 'Dog Walking',
        packageName: 'Premium Trail Experience',
        description: 'Ultimate adventure for your dog. 1.5-2 hour nature trail walk with swimming, hiking, and extensive playtime. Perfect for weekends.',
        price: 1000,
        duration: '1.5-2 hours',
        features: [
          '1.5-2 hour adventure',
          'Nature trail or beach',
          'Swimming opportunity',
          'Extensive playtime',
          'Training & tricks',
          'Group socialization',
          'Professional photos',
          'GPS tracking',
          'Treats & water',
          'Post-walk report',
        ],
      ),
      ServicePackageModel(
        id: 'walk_group_2026',
        serviceType: 'Dog Walking',
        packageName: 'Group Walk & Play',
        description: 'Social hour for your dog. 45-minute group walk with 3-5 dogs for maximum socialization and fun. Great for friendly, social dogs.',
        price: 450,
        duration: '45 minutes',
        features: [
          '45 minute group walk',
          'Small group (3-5 dogs)',
          'Supervised socialization',
          'Play sessions',
          'Behavior monitoring',
          'Group photos',
          'GPS tracking',
          'Safety first approach',
        ],
      ),
      ServicePackageModel(
        id: 'walk_early_2026',
        serviceType: 'Dog Walking',
        packageName: 'Early Bird Special',
        description: 'Beat the heat! Early morning walk (5-7 AM) perfect for Indian summers. 30-40 minutes of fresh air and exercise before the day heats up.',
        price: 400,
        duration: '30-40 minutes',
        features: [
          'Early morning (5-7 AM)',
          '30-40 minute walk',
          'Cool weather advantage',
          'Less crowded parks',
          'Perfect for summers',
          'Photo updates',
          'GPS tracking',
        ],
      ),

      // PET SITTING PACKAGES (6 packages)
      ServicePackageModel(
        id: 'sit_basic_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Basic Day Care',
        description: 'Essential care while you\'re away. 4-6 hours of supervision, feeding, and playtime. Perfect for half-day commitments.',
        price: 500,
        duration: '4-6 hours',
        features: [
          '4-6 hours supervision',
          'Feeding (1-2 meals)',
          'Playtime & exercise',
          'Bathroom breaks',
          'Medication if needed',
          'Photo updates',
          'Your home or ours',
        ],
      ),
      ServicePackageModel(
        id: 'sit_daycare_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Full Day Care',
        description: 'Complete day care service. 8-10 hours of comprehensive care including meals, walks, playtime, and rest. Ideal for working professionals.',
        price: 850,
        duration: '8-10 hours',
        features: [
          '8-10 hours care',
          'Multiple meals',
          '2-3 walks included',
          'Playtime & activities',
          'Rest & nap time',
          'Medication administration',
          'Regular photo updates',
          'Emergency vet access',
        ],
      ),
      ServicePackageModel(
        id: 'sit_overnight_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Overnight Stay',
        description: 'Complete 24-hour care. Your pet stays comfortable with feeding, walks, playtime, and overnight supervision. Perfect for business trips.',
        price: 1500,
        duration: '24 hours',
        features: [
          'Full 24-hour care',
          'All meals included',
          '3-4 walks',
          'Playtime & exercise',
          'Overnight supervision',
          'Medication management',
          'Video call updates',
          'Emergency support',
          'Comfortable sleeping area',
        ],
      ),
      ServicePackageModel(
        id: 'sit_extended_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Extended Stay (Per Day)',
        description: 'Multi-day boarding solution. Daily rate for extended stays during vacations. Includes all meals, walks, playtime, and daily updates.',
        price: 1250,
        duration: 'Per day',
        features: [
          'Per day rate',
          'All meals & treats',
          'Multiple daily walks',
          'Playtime & socialization',
          'Comfortable accommodation',
          'Daily photo/video updates',
          'Medication included',
          '24/7 supervision',
          'Emergency vet access',
          'Discount for 7+ days',
        ],
      ),
      ServicePackageModel(
        id: 'sit_medical_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Medical Care Sitting',
        description: 'Specialized care for pets with medical needs. Administered by trained professionals. Includes medication, wound care, and monitoring.',
        price: 1800,
        duration: '24 hours',
        features: [
          'Trained medical caregiver',
          'Medication administration',
          'Wound care & monitoring',
          'Special diet management',
          'Vital signs checking',
          'Vet coordination',
          'Detailed health reports',
          'Emergency response',
          '24/7 supervision',
        ],
      ),
      ServicePackageModel(
        id: 'sit_puppy_2026',
        serviceType: 'Pet Sitting',
        packageName: 'Puppy Care Special',
        description: 'Specialized care for puppies under 1 year. Includes frequent feeding, potty training support, socialization, and extra attention.',
        price: 1000,
        duration: '8-10 hours',
        features: [
          'Puppy-specific care',
          'Frequent feeding (3-4 times)',
          'Potty training support',
          'Socialization activities',
          'Gentle play sessions',
          'Crate training help',
          'Frequent updates',
          'Puppy-proofed environment',
        ],
      ),

      // GROOMING PACKAGES (6 packages)
      ServicePackageModel(
        id: 'groom_bath_2026',
        serviceType: 'Grooming',
        packageName: 'Bath & Brush',
        description: 'Essential grooming service. Includes bath with premium shampoo, blow dry, brushing, nail trim, and ear cleaning. Perfect for regular maintenance.',
        price: 650,
        duration: '1-1.5 hours',
        features: [
          'Premium shampoo bath',
          'Conditioner treatment',
          'Blow dry & brushing',
          'Nail trimming',
          'Ear cleaning',
          'Paw pad care',
          'Light cologne',
          'Breed-appropriate products',
        ],
      ),
      ServicePackageModel(
        id: 'groom_full_2026',
        serviceType: 'Grooming',
        packageName: 'Full Grooming',
        description: 'Complete grooming package. Bath, haircut, styling, nail care, teeth brushing, and more. Your dog will look and feel amazing!',
        price: 1000,
        duration: '2-2.5 hours',
        features: [
          'Premium bath & conditioning',
          'Breed-specific haircut',
          'Professional styling',
          'Nail trim & filing',
          'Ear cleaning & plucking',
          'Teeth brushing',
          'Paw pad moisturizing',
          'Sanitary trim',
          'Cologne & bow',
          'Before/after photos',
        ],
      ),
      ServicePackageModel(
        id: 'groom_spa_2026',
        serviceType: 'Grooming',
        packageName: 'Premium Spa Treatment',
        description: 'Luxury spa experience for your pet. Includes aromatherapy bath, deep conditioning, massage, pawdicure, and premium styling. Pure indulgence!',
        price: 1500,
        duration: '3-3.5 hours',
        features: [
          'Aromatherapy bath',
          'Deep conditioning mask',
          'Relaxing massage',
          'Premium haircut & styling',
          'Pawdicure (nail art optional)',
          'Teeth cleaning',
          'Ear care',
          'Blueberry facial',
          'Premium cologne',
          'Bandana or bow tie',
          'Professional photoshoot',
        ],
      ),
      ServicePackageModel(
        id: 'groom_luxury_2026',
        serviceType: 'Grooming',
        packageName: 'Luxury Royal Treatment',
        description: 'Ultimate grooming experience. VIP treatment with organic products, extended spa services, creative styling, and premium care. For special occasions!',
        price: 2200,
        duration: '4-5 hours',
        features: [
          'Organic spa bath',
          'Hot oil treatment',
          'Full body massage',
          'Creative styling',
          'Nail art & polish',
          'Teeth whitening',
          'Blueberry facial',
          'Paw balm treatment',
          'Premium fragrance',
          'Designer accessories',
          'Professional photoshoot',
          'Take-home grooming kit',
        ],
      ),
      ServicePackageModel(
        id: 'groom_deshed_2026',
        serviceType: 'Grooming',
        packageName: 'De-Shedding Treatment',
        description: 'Specialized treatment for heavy shedders. Reduces shedding by up to 80%. Includes special bath, de-shedding tools, and conditioning.',
        price: 900,
        duration: '2 hours',
        features: [
          'De-shedding shampoo',
          'Deep conditioning',
          'Professional de-shedding tools',
          'Undercoat removal',
          'Blow dry & brushing',
          'Nail trim',
          'Ear cleaning',
          'Reduces shedding 80%',
          'Lasts 4-6 weeks',
        ],
      ),
      ServicePackageModel(
        id: 'groom_puppy_2026',
        serviceType: 'Grooming',
        packageName: 'Puppy First Groom',
        description: 'Gentle introduction to grooming for puppies. Positive experience with treats, patience, and extra care. Sets foundation for lifetime grooming.',
        price: 550,
        duration: '45-60 minutes',
        features: [
          'Gentle puppy bath',
          'Soft brushing',
          'Nail tip trim',
          'Ear cleaning',
          'Face & paw trim',
          'Positive reinforcement',
          'Treats & patience',
          'Grooming introduction',
          'Parent education',
        ],
      ),

      // DOG TRAINING PACKAGES (6 packages)
      ServicePackageModel(
        id: 'train_basic_2026',
        serviceType: 'Dog Training',
        packageName: 'Basic Obedience (Single)',
        description: 'Foundation training session. Covers sit, stay, come, and leash manners. Perfect for puppies or first-time training. 1-hour personalized session.',
        price: 1000,
        duration: '1 hour',
        features: [
          '1-hour private session',
          'Basic commands (sit, stay, come)',
          'Leash manners',
          'Positive reinforcement',
          'Training materials',
          'Homework assignments',
          'Follow-up support',
        ],
      ),
      ServicePackageModel(
        id: 'train_advanced_2026',
        serviceType: 'Dog Training',
        packageName: 'Advanced Training (Single)',
        description: 'Advanced skills training. Off-leash control, distance commands, and complex behaviors. For dogs with basic training foundation.',
        price: 1500,
        duration: '1.5 hours',
        features: [
          '1.5-hour session',
          'Advanced commands',
          'Off-leash training',
          'Distance control',
          'Distraction training',
          'Real-world scenarios',
          'Video analysis',
          'Training plan',
        ],
      ),
      ServicePackageModel(
        id: 'train_behavior_2026',
        serviceType: 'Dog Training',
        packageName: 'Behavior Modification',
        description: 'Specialized training for behavioral issues. Addresses aggression, anxiety, fear, or destructive behaviors. Customized approach by certified behaviorist.',
        price: 2000,
        duration: '2 hours',
        features: [
          '2-hour consultation',
          'Behavior assessment',
          'Customized training plan',
          'Certified behaviorist',
          'Positive methods only',
          'Progress tracking',
          'Family training included',
          'Follow-up sessions',
          'Emergency support',
        ],
      ),
      ServicePackageModel(
        id: 'train_5session_2026',
        serviceType: 'Dog Training',
        packageName: '5-Session Training Package',
        description: 'Comprehensive training program. 5 sessions covering basic to intermediate skills. Includes homework, progress tracking, and lifetime support.',
        price: 6500,
        duration: '5 sessions (1 hour each)',
        features: [
          '5 one-hour sessions',
          'Progressive curriculum',
          'Basic to intermediate skills',
          'Homework assignments',
          'Progress reports',
          'Training materials',
          'Video tutorials',
          'Lifetime email support',
          'Certificate of completion',
          'Save ₹1500 vs individual',
        ],
      ),
      ServicePackageModel(
        id: 'train_10session_2026',
        serviceType: 'Dog Training',
        packageName: '10-Session Complete Program',
        description: 'Ultimate training transformation. 10 sessions from basic to advanced. Includes behavior modification, socialization, and real-world training.',
        price: 12000,
        duration: '10 sessions (1-1.5 hours each)',
        features: [
          '10 comprehensive sessions',
          'Basic to advanced training',
          'Behavior modification',
          'Socialization training',
          'Real-world scenarios',
          'Off-leash training',
          'Progress tracking',
          'Video analysis',
          'Training materials',
          'Lifetime support',
          'Certificate & graduation',
          'Save ₹3000 vs individual',
        ],
      ),
      ServicePackageModel(
        id: 'train_puppy_2026',
        serviceType: 'Dog Training',
        packageName: 'Puppy Foundation Program',
        description: 'Essential training for puppies 8 weeks to 6 months. Covers socialization, potty training, bite inhibition, and basic commands. Set your puppy up for success!',
        price: 7500,
        duration: '6 sessions (45 min each)',
        features: [
          '6 puppy-specific sessions',
          'Socialization training',
          'Potty training guidance',
          'Bite inhibition',
          'Basic commands',
          'Crate training',
          'Leash introduction',
          'Play & exercise tips',
          'Puppy-proofing advice',
          'Parent education',
          'Lifetime support',
        ],
      ),

      // VET VISIT COMPANION PACKAGES (6 packages)
      ServicePackageModel(
        id: 'vet_transport_2026',
        serviceType: 'Vet Visit',
        packageName: 'Transport Only',
        description: 'Safe transportation to and from vet clinic. Perfect when you can\'t take time off. We ensure your pet arrives safely and on time.',
        price: 400,
        duration: '1-2 hours',
        features: [
          'Pick up from home',
          'Safe transport to vet',
          'Wait during appointment',
          'Return home safely',
          'GPS tracking',
          'Photo updates',
          'Vet report collection',
        ],
      ),
      ServicePackageModel(
        id: 'vet_companion_2026',
        serviceType: 'Vet Visit',
        packageName: 'Vet Visit Companion',
        description: 'Complete vet visit support. We accompany your pet, communicate with vet, collect reports, and administer immediate care if needed.',
        price: 650,
        duration: '2-3 hours',
        features: [
          'Transport both ways',
          'Appointment attendance',
          'Vet communication',
          'Report collection',
          'Medication pickup',
          'Immediate care',
          'Detailed updates',
          'Photo/video documentation',
        ],
      ),
      ServicePackageModel(
        id: 'vet_emergency_2026',
        serviceType: 'Vet Visit',
        packageName: 'Emergency Support',
        description: 'Urgent vet visit assistance. Available 24/7 for emergencies. Immediate response, fast transport, and complete support during crisis.',
        price: 1000,
        duration: 'As needed',
        features: [
          '24/7 availability',
          'Immediate response',
          'Emergency transport',
          'Vet coordination',
          'Crisis management',
          'Family updates',
          'Post-care support',
          'Medication administration',
          'Follow-up care',
        ],
      ),
      ServicePackageModel(
        id: 'vet_fullday_2026',
        serviceType: 'Vet Visit',
        packageName: 'Full Day Medical Care',
        description: 'Complete day of medical support. For surgeries, procedures, or extended treatments. We stay with your pet throughout and provide post-care.',
        price: 1800,
        duration: 'Full day (8-12 hours)',
        features: [
          'Full day attendance',
          'Pre-procedure support',
          'Surgery/procedure wait',
          'Post-care monitoring',
          'Medication administration',
          'Vet coordination',
          'Regular family updates',
          'Transport both ways',
          'Home settling',
          'Follow-up care',
        ],
      ),
      ServicePackageModel(
        id: 'vet_vaccination_2026',
        serviceType: 'Vet Visit',
        packageName: 'Vaccination Visit',
        description: 'Hassle-free vaccination appointment. We handle transport, vaccination, and ensure your pet is comfortable throughout the process.',
        price: 500,
        duration: '1.5-2 hours',
        features: [
          'Transport both ways',
          'Vaccination appointment',
          'Comfort & calming',
          'Certificate collection',
          'Post-vaccination monitoring',
          'Treat rewards',
          'Photo updates',
          'Next appointment reminder',
        ],
      ),
      ServicePackageModel(
        id: 'vet_checkup_2026',
        serviceType: 'Vet Visit',
        packageName: 'Routine Check-up',
        description: 'Regular health check-up support. Perfect for annual exams, senior wellness checks, or routine health monitoring.',
        price: 550,
        duration: '2-2.5 hours',
        features: [
          'Transport both ways',
          'Check-up attendance',
          'Health report collection',
          'Vet Q&A on your behalf',
          'Medication pickup if needed',
          'Weight & vitals recording',
          'Photo updates',
          'Health summary report',
        ],
      ),
    ];

    // Seed packages to Firestore
    final batch = _firestore.batch();
    for (var package in packages) {
      final docRef = _firestore.collection('service_packages').doc(package.id);
      batch.set(docRef, package.toMap());
    }
    
    await batch.commit();
    debugPrint('✅ Seeded ${packages.length} service packages successfully!');
  }

  /// Seed adoptable pets for adoption feature
  /// 
  /// Based on Indian pet adoption trends and popular breeds
  Future<void> seedAdoptablePets() async {
    debugPrint('🐾 Seeding adoptable pets for adoption...');

    final adoptablePets = [
      // Popular Indian breeds and rescues
      {
        'id': 'adopt_luna_golden_2026',
        'name': 'Luna',
        'type': 'Dog',
        'breed': 'Golden Retriever',
        'age': 2,
        'gender': 'Female',
        'size': 'Large',
        'location': 'Mumbai, Maharashtra',
        'image': 'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=800&h=800&fit=crop',
        'description': 'Luna is a friendly and energetic Golden Retriever who loves playing fetch and going on long walks. She\'s great with children and other pets. Fully vaccinated and house-trained.',
        'adoptionFee': 5000,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'High',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_max_shepherd_2026',
        'name': 'Max',
        'type': 'Dog',
        'breed': 'German Shepherd',
        'age': 3,
        'gender': 'Male',
        'size': 'Large',
        'location': 'Bangalore, Karnataka',
        'image': 'https://images.unsplash.com/photo-1568572933382-74d440642117?w=800&h=800&fit=crop',
        'description': 'Max is a loyal and protective German Shepherd. He\'s well-trained, obedient, and makes an excellent family companion. Perfect for experienced dog owners.',
        'adoptionFee': 6000,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': false,
        'energyLevel': 'High',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_bella_beagle_2026',
        'name': 'Bella',
        'type': 'Dog',
        'breed': 'Beagle',
        'age': 1,
        'gender': 'Female',
        'size': 'Medium',
        'location': 'Pune, Maharashtra',
        'image': 'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800&h=800&fit=crop',
        'description': 'Bella is an adorable young Beagle full of energy and curiosity. She\'s playful, social, and loves being around people. Great for active families.',
        'adoptionFee': 4000,
        'vaccinated': true,
        'spayedNeutered': false,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Very High',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_rocky_labrador_2026',
        'name': 'Rocky',
        'type': 'Dog',
        'breed': 'Labrador Retriever',
        'age': 4,
        'gender': 'Male',
        'size': 'Large',
        'location': 'Delhi, NCR',
        'image': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800&h=800&fit=crop',
        'description': 'Rocky is a gentle giant who loves everyone he meets. This Labrador is calm, well-behaved, and perfect for families. He enjoys swimming and outdoor activities.',
        'adoptionFee': 5500,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Medium',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_milo_indie_2026',
        'name': 'Milo',
        'type': 'Dog',
        'breed': 'Indian Pariah (Indie)',
        'age': 2,
        'gender': 'Male',
        'size': 'Medium',
        'location': 'Hyderabad, Telangana',
        'image': 'https://images.unsplash.com/photo-1477884213360-7e9d7dcc1e48?w=800&h=800&fit=crop',
        'description': 'Milo is a smart and adaptable Indian Pariah dog. These native breeds are known for their intelligence, loyalty, and low maintenance. Perfect for Indian climate.',
        'adoptionFee': 2000,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Medium',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_daisy_pug_2026',
        'name': 'Daisy',
        'type': 'Dog',
        'breed': 'Pug',
        'age': 3,
        'gender': 'Female',
        'size': 'Small',
        'location': 'Chennai, Tamil Nadu',
        'image': 'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=800&h=800&fit=crop',
        'description': 'Daisy is a charming Pug with a playful personality. She loves cuddles and is perfect for apartment living. Great companion for seniors or small families.',
        'adoptionFee': 4500,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Low',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_bruno_boxer_2026',
        'name': 'Bruno',
        'type': 'Dog',
        'breed': 'Boxer',
        'age': 2,
        'gender': 'Male',
        'size': 'Large',
        'location': 'Mumbai, Maharashtra',
        'image': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800&h=800&fit=crop',
        'description': 'Bruno is an energetic Boxer who loves to play and exercise. He\'s protective, loyal, and great with active families. Needs regular exercise and mental stimulation.',
        'adoptionFee': 5500,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': false,
        'energyLevel': 'Very High',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_coco_shihtzu_2026',
        'name': 'Coco',
        'type': 'Dog',
        'breed': 'Shih Tzu',
        'age': 5,
        'gender': 'Female',
        'size': 'Small',
        'location': 'Bangalore, Karnataka',
        'image': 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800&h=800&fit=crop',
        'description': 'Coco is a sweet and gentle Shih Tzu looking for a loving home. She\'s calm, well-mannered, and perfect for apartment living. Great with seniors.',
        'adoptionFee': 4000,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Low',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_simba_indie_2026',
        'name': 'Simba',
        'type': 'Dog',
        'breed': 'Indian Pariah (Indie)',
        'age': 1,
        'gender': 'Male',
        'size': 'Medium',
        'location': 'Pune, Maharashtra',
        'image': 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=800&h=800&fit=crop',
        'description': 'Simba is a young and playful Indian Pariah pup. He\'s smart, easy to train, and adapts well to Indian weather. Perfect first dog for families.',
        'adoptionFee': 1500,
        'vaccinated': true,
        'spayedNeutered': false,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'High',
        'availableFrom': Timestamp.now(),
      },
      {
        'id': 'adopt_charlie_cocker_2026',
        'name': 'Charlie',
        'type': 'Dog',
        'breed': 'Cocker Spaniel',
        'age': 3,
        'gender': 'Male',
        'size': 'Medium',
        'location': 'Delhi, NCR',
        'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=800&h=800&fit=crop',
        'description': 'Charlie is a friendly Cocker Spaniel with beautiful long ears. He\'s gentle, affectionate, and loves being around people. Great family dog.',
        'adoptionFee': 5000,
        'vaccinated': true,
        'spayedNeutered': true,
        'goodWithKids': true,
        'goodWithPets': true,
        'energyLevel': 'Medium',
        'availableFrom': Timestamp.now(),
      },
    ];

    // Seed adoptable pets to Firestore
    final batch = _firestore.batch();
    for (var pet in adoptablePets) {
      final docRef = _firestore.collection('adoptable_pets').doc(pet['id'] as String);
      batch.set(docRef, pet);
    }
    
    await batch.commit();
    debugPrint('✅ Seeded ${adoptablePets.length} adoptable pets successfully!');
  }

  /// Check database status
  Future<void> checkDatabaseStatus() async {
    debugPrint('📊 Checking database status...');
    
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .get();
      
      final packagesSnapshot = await _firestore
          .collection('service_packages')
          .get();
      
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .get();
      
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .get();
      
      debugPrint('👥 Caregivers: ${usersSnapshot.docs.length}');
      debugPrint('📦 Service Packages: ${packagesSnapshot.docs.length}');
      debugPrint('📅 Bookings: ${bookingsSnapshot.docs.length}');
      debugPrint('⭐ Reviews: ${reviewsSnapshot.docs.length}');
    } catch (e) {
      debugPrint('❌ Error checking status: $e');
    }
  }

  /// Seed sample bookings with time-wise distribution for tracking feature
  /// 
  /// Creates 15 bookings with various statuses and times:
  /// - Current in-progress bookings (active)
  /// - Upcoming confirmed bookings
  /// - Pending bookings
  /// 
  /// NO completed bookings - they will be created naturally as services finish
  /// 
  /// IMPORTANT: Replace 'YOUR_USER_ID' with actual user ID from Firebase Auth
  Future<void> seedSampleBookings({String? userId}) async {
    debugPrint('📅 Seeding sample bookings with time distribution...');

    final now = DateTime.now();
    
    // Use provided userId or default to demo user
    final ownerId = userId ?? 'demo_user_001';
    debugPrint('   Using owner ID: $ownerId');
    
    final sampleBookings = [
      // IN-PROGRESS BOOKINGS (Current - Active)
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_priya_mumbai',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Training',
        'packageName': 'Basic Obedience (Single)',
        'duration': '1 hour',
        'scheduledDate': now.subtract(const Duration(minutes: 30)),
        'status': 'in_progress',
        'price': 1000.0,
        'notes': 'First training session - basic commands',
        'createdAt': now.subtract(const Duration(days: 1)),
        'actualStartTime': now.subtract(const Duration(minutes: 30)),
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_sneha_bangalore',
        'petId': 'demo_pet_002',
        'serviceType': 'Grooming',
        'packageName': 'Premium Spa Treatment',
        'duration': '3-3.5 hours',
        'scheduledDate': now.subtract(const Duration(hours: 1)),
        'status': 'in_progress',
        'price': 1500.0,
        'notes': 'Spa day for special occasion',
        'createdAt': now.subtract(const Duration(days: 2)),
        'actualStartTime': now.subtract(const Duration(hours: 1)),
      },

      // CONFIRMED BOOKINGS (Upcoming - Today)
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_rahul_mumbai',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Walking',
        'packageName': 'Standard Walk',
        'duration': '30-45 minutes',
        'scheduledDate': now.add(const Duration(hours: 2)),
        'status': 'confirmed',
        'price': 375.0,
        'notes': 'Afternoon walk',
        'createdAt': now.subtract(const Duration(hours: 12)),
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_meera_bangalore',
        'petId': 'demo_pet_001',
        'serviceType': 'Pet Sitting',
        'packageName': 'Basic Day Care',
        'duration': '4-6 hours',
        'scheduledDate': now.add(const Duration(hours: 4)),
        'status': 'confirmed',
        'price': 500.0,
        'notes': 'Evening care needed',
        'createdAt': now.subtract(const Duration(hours: 8)),
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_arjun_bangalore',
        'petId': 'demo_pet_002',
        'serviceType': 'Dog Walking',
        'packageName': 'Premium Trail Experience',
        'duration': '1.5-2 hours',
        'scheduledDate': now.add(const Duration(hours: 5)),
        'status': 'confirmed',
        'price': 1000.0,
        'notes': 'Weekend trail adventure',
        'createdAt': now.subtract(const Duration(hours: 6)),
      },

      // CONFIRMED BOOKINGS (Tomorrow)
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_anjali_mumbai',
        'petId': 'demo_pet_001',
        'serviceType': 'Grooming',
        'packageName': 'Bath & Brush',
        'duration': '1-1.5 hours',
        'scheduledDate': now.add(const Duration(days: 1, hours: 10)),
        'status': 'confirmed',
        'price': 650.0,
        'notes': 'Regular grooming session',
        'createdAt': now.subtract(const Duration(hours: 4)),
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_priya_mumbai',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Training',
        'packageName': 'Advanced Training (Single)',
        'duration': '1.5 hours',
        'scheduledDate': now.add(const Duration(days: 1, hours: 16)),
        'status': 'confirmed',
        'price': 1500.0,
        'notes': 'Advanced commands training',
        'createdAt': now.subtract(const Duration(hours: 2)),
      },

      // CONFIRMED BOOKINGS (This Week)
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_kavita_pune',
        'petId': 'demo_pet_001',
        'serviceType': 'Vet Visit',
        'packageName': 'Routine Check-up',
        'duration': '2-2.5 hours',
        'scheduledDate': now.add(const Duration(days: 2, hours: 11)),
        'status': 'confirmed',
        'price': 550.0,
        'notes': 'Annual health check-up',
        'createdAt': now.subtract(const Duration(hours: 1)),
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_divya_hyderabad',
        'petId': 'demo_pet_002',
        'serviceType': 'Pet Sitting',
        'packageName': 'Overnight Stay',
        'duration': '24 hours',
        'scheduledDate': now.add(const Duration(days: 3, hours: 18)),
        'status': 'confirmed',
        'price': 1500.0,
        'notes': 'Overnight care for business trip',
        'createdAt': now,
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_rohan_pune',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Training',
        'packageName': 'Behavior Modification',
        'duration': '2 hours',
        'scheduledDate': now.add(const Duration(days: 4, hours: 15)),
        'status': 'confirmed',
        'price': 2000.0,
        'notes': 'Addressing separation anxiety',
        'createdAt': now,
      },

      // PENDING BOOKINGS (Awaiting Confirmation)
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_neha_delhi',
        'petId': 'demo_pet_001',
        'serviceType': 'Grooming',
        'packageName': 'Luxury Royal Treatment',
        'duration': '4-5 hours',
        'scheduledDate': now.add(const Duration(days: 7, hours: 10)),
        'status': 'pending',
        'price': 2200.0,
        'notes': 'Special occasion grooming',
        'createdAt': now,
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_karthik_hyderabad',
        'petId': 'demo_pet_002',
        'serviceType': 'Dog Training',
        'packageName': '5-Session Training Package',
        'duration': '5 sessions (1 hour each)',
        'scheduledDate': now.add(const Duration(days: 10, hours: 16)),
        'status': 'pending',
        'price': 6500.0,
        'notes': 'Complete training program',
        'createdAt': now,
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_amit_pune',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Walking',
        'packageName': 'Group Walk & Play',
        'duration': '45 minutes',
        'scheduledDate': now.add(const Duration(days: 14, hours: 8)),
        'status': 'pending',
        'price': 450.0,
        'notes': 'Socialization walk',
        'createdAt': now,
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_aditya_chennai',
        'petId': 'demo_pet_002',
        'serviceType': 'Vet Visit',
        'packageName': 'Vaccination Visit',
        'duration': '1.5-2 hours',
        'scheduledDate': now.add(const Duration(days: 21, hours: 11)),
        'status': 'pending',
        'price': 500.0,
        'notes': 'Annual vaccination',
        'createdAt': now,
      },
      {
        'ownerId': ownerId,
        'caregiverId': 'caregiver_sanjay_gurgaon',
        'petId': 'demo_pet_001',
        'serviceType': 'Dog Training',
        'packageName': '10-Session Complete Program',
        'duration': '10 sessions (1-1.5 hours each)',
        'scheduledDate': now.add(const Duration(days: 30, hours: 17)),
        'status': 'pending',
        'price': 12000.0,
        'notes': 'Complete transformation program',
        'createdAt': now,
      },
    ];

    // Seed bookings to Firestore
    for (var booking in sampleBookings) {
      await _firestore.collection('bookings').add(booking);
    }
    
    debugPrint('✅ Seeded ${sampleBookings.length} sample bookings successfully!');
    debugPrint('   - 2 active (in-progress)');
    debugPrint('   - 8 upcoming (confirmed)');
    debugPrint('   - 5 pending');
  }

  /// Seed sample reviews for caregivers
  /// 
  /// Creates 25 realistic reviews with ratings and feedback
  Future<void> seedSampleReviews() async {
    debugPrint('⭐ Seeding sample reviews...');

    final now = DateTime.now();
    
    final sampleReviews = [
      // Reviews for Priya Sharma (Mumbai)
      {
        'caregiverId': 'caregiver_priya_mumbai',
        'ownerId': 'demo_user_001',
        'ownerName': 'Rajesh Kumar',
        'rating': 5.0,
        'comment': 'Priya is an exceptional trainer! My Labrador learned basic commands in just 3 sessions. Her positive reinforcement methods work wonders. Highly recommended!',
        'createdAt': now.subtract(const Duration(days: 10)),
      },
      {
        'caregiverId': 'caregiver_priya_mumbai',
        'ownerId': 'demo_user_002',
        'ownerName': 'Sneha Patel',
        'rating': 5.0,
        'comment': 'Best dog trainer in Mumbai! Very professional and patient. My German Shepherd\'s behavior improved significantly. Worth every rupee!',
        'createdAt': now.subtract(const Duration(days: 25)),
      },
      {
        'caregiverId': 'caregiver_priya_mumbai',
        'ownerId': 'demo_user_003',
        'ownerName': 'Amit Desai',
        'rating': 4.0,
        'comment': 'Great trainer with excellent knowledge. My only concern was scheduling flexibility, but the training quality is top-notch.',
        'createdAt': now.subtract(const Duration(days: 45)),
      },

      // Reviews for Rahul Verma (Mumbai)
      {
        'caregiverId': 'caregiver_rahul_mumbai',
        'ownerId': 'demo_user_004',
        'ownerName': 'Priya Singh',
        'rating': 5.0,
        'comment': 'Rahul is fantastic! Always on time, sends photos during walks, and my dog absolutely loves him. Very reliable and trustworthy.',
        'createdAt': now.subtract(const Duration(days: 5)),
      },
      {
        'caregiverId': 'caregiver_rahul_mumbai',
        'ownerId': 'demo_user_005',
        'ownerName': 'Vikram Mehta',
        'rating': 5.0,
        'comment': 'Best dog walker in Powai! My Beagle comes back tired and happy. Rahul handles multiple dogs with ease. Highly professional.',
        'createdAt': now.subtract(const Duration(days: 18)),
      },

      // Reviews for Anjali Patel (Mumbai)
      {
        'caregiverId': 'caregiver_anjali_mumbai',
        'ownerId': 'demo_user_006',
        'ownerName': 'Kavita Sharma',
        'rating': 5.0,
        'comment': 'Anjali is a grooming artist! My Golden Retriever looks stunning after every session. She\'s gentle and uses premium products. Absolutely love her work!',
        'createdAt': now.subtract(const Duration(days: 8)),
      },
      {
        'caregiverId': 'caregiver_anjali_mumbai',
        'ownerId': 'demo_user_007',
        'ownerName': 'Rohan Kapoor',
        'rating': 5.0,
        'comment': 'Best groomer in Mumbai! My anxious Pug feels comfortable with her. The spa treatment is worth it. Highly recommended!',
        'createdAt': now.subtract(const Duration(days: 30)),
      },

      // Reviews for Meera Reddy (Bangalore)
      {
        'caregiverId': 'caregiver_meera_bangalore',
        'ownerId': 'demo_user_008',
        'ownerName': 'Arun Kumar',
        'rating': 5.0,
        'comment': 'Meera is amazing with senior dogs! She took excellent care of my 12-year-old Labrador. Very knowledgeable about medical needs. Trustworthy and caring.',
        'createdAt': now.subtract(const Duration(days: 12)),
      },
      {
        'caregiverId': 'caregiver_meera_bangalore',
        'ownerId': 'demo_user_009',
        'ownerName': 'Divya Iyer',
        'rating': 5.0,
        'comment': 'Excellent pet sitter! My diabetic dog was in safe hands. Meera administered insulin perfectly and sent regular updates. Peace of mind!',
        'createdAt': now.subtract(const Duration(days: 35)),
      },

      // Reviews for Arjun Kumar (Bangalore)
      {
        'caregiverId': 'caregiver_arjun_bangalore',
        'ownerId': 'demo_user_010',
        'ownerName': 'Neha Reddy',
        'rating': 5.0,
        'comment': 'Perfect for high-energy dogs! Arjun takes my Husky on amazing trail walks. GPS tracking is great. My dog is always exhausted and happy!',
        'createdAt': now.subtract(const Duration(days: 7)),
      },
      {
        'caregiverId': 'caregiver_arjun_bangalore',
        'ownerId': 'demo_user_011',
        'ownerName': 'Karthik Nair',
        'rating': 4.0,
        'comment': 'Great walker for active breeds. My German Shepherd loves the agility training. Would give 5 stars if timing was more flexible.',
        'createdAt': now.subtract(const Duration(days: 22)),
      },

      // Reviews for Sneha Desai (Bangalore)
      {
        'caregiverId': 'caregiver_sneha_bangalore',
        'ownerId': 'demo_user_012',
        'ownerName': 'Sanjay Gupta',
        'rating': 5.0,
        'comment': 'Celebrity groomer for a reason! Sneha groomed my Shih Tzu for a dog show. The styling was perfect. Professional and talented!',
        'createdAt': now.subtract(const Duration(days: 15)),
      },

      // Reviews for Rohan Kapoor (Pune)
      {
        'caregiverId': 'caregiver_rohan_pune',
        'ownerId': 'demo_user_013',
        'ownerName': 'Anjali Joshi',
        'rating': 5.0,
        'comment': 'Expert in Indian breeds! Rohan trained my Rajapalayam beautifully. He understands native breeds better than anyone. Highly recommended!',
        'createdAt': now.subtract(const Duration(days: 20)),
      },
      {
        'caregiverId': 'caregiver_rohan_pune',
        'ownerId': 'demo_user_014',
        'ownerName': 'Rahul Patil',
        'rating': 5.0,
        'comment': 'Best trainer for Indian Pariah dogs! Rohan\'s traditional methods work perfectly. My indie dog is now well-behaved and obedient.',
        'createdAt': now.subtract(const Duration(days: 40)),
      },

      // Reviews for Kavita Rao (Pune)
      {
        'caregiverId': 'caregiver_kavita_pune',
        'ownerId': 'demo_user_015',
        'ownerName': 'Meera Kulkarni',
        'rating': 5.0,
        'comment': 'Kavita is a lifesaver! She took care of my senior dog post-surgery. Her medical knowledge is impressive. Very caring and professional.',
        'createdAt': now.subtract(const Duration(days: 9)),
      },

      // Reviews for Neha Joshi (Delhi)
      {
        'caregiverId': 'caregiver_neha_delhi',
        'ownerId': 'demo_user_016',
        'ownerName': 'Vikram Singh',
        'rating': 5.0,
        'comment': 'Premium grooming at its best! Neha\'s spa treatment is luxurious. My Cocker Spaniel looks and smells amazing. Worth the price!',
        'createdAt': now.subtract(const Duration(days: 11)),
      },
      {
        'caregiverId': 'caregiver_neha_delhi',
        'ownerId': 'demo_user_017',
        'ownerName': 'Priya Malhotra',
        'rating': 5.0,
        'comment': 'Best groomer in Delhi NCR! Mobile service is convenient. My Golden Retriever loves the spa days. Highly professional!',
        'createdAt': now.subtract(const Duration(days: 28)),
      },

      // Reviews for Sanjay Mehta (Gurgaon)
      {
        'caregiverId': 'caregiver_sanjay_gurgaon',
        'ownerId': 'demo_user_018',
        'ownerName': 'Amit Sharma',
        'rating': 5.0,
        'comment': 'Expert in protection training! Sanjay trained my Rottweiler for home security. Very professional and knowledgeable. Excellent results!',
        'createdAt': now.subtract(const Duration(days: 14)),
      },

      // Reviews for Divya Iyer (Hyderabad)
      {
        'caregiverId': 'caregiver_divya_hyderabad',
        'ownerId': 'demo_user_019',
        'ownerName': 'Karthik Reddy',
        'rating': 5.0,
        'comment': 'Holistic care is amazing! Divya\'s aromatherapy helped my anxious dog. She\'s gentle, caring, and uses natural products. Highly recommended!',
        'createdAt': now.subtract(const Duration(days: 6)),
      },
      {
        'caregiverId': 'caregiver_divya_hyderabad',
        'ownerId': 'demo_user_020',
        'ownerName': 'Sneha Rao',
        'rating': 5.0,
        'comment': 'Perfect for nervous pets! My rescue dog feels safe with Divya. Her calming techniques work wonders. Very patient and understanding.',
        'createdAt': now.subtract(const Duration(days: 32)),
      },

      // Reviews for Karthik Nair (Hyderabad)
      {
        'caregiverId': 'caregiver_karthik_hyderabad',
        'ownerId': 'demo_user_021',
        'ownerName': 'Rohan Nair',
        'rating': 5.0,
        'comment': 'Best fitness trainer for dogs! Karthik\'s agility classes are fun and effective. My Border Collie loves it. Great for active breeds!',
        'createdAt': now.subtract(const Duration(days: 17)),
      },

      // Reviews for Aditya Singh (Chennai)
      {
        'caregiverId': 'caregiver_aditya_chennai',
        'ownerId': 'demo_user_022',
        'ownerName': 'Lakshmi Iyer',
        'rating': 5.0,
        'comment': 'Excellent puppy trainer! Aditya is patient and uses positive methods. My Labrador puppy learned quickly. Highly professional!',
        'createdAt': now.subtract(const Duration(days: 13)),
      },
      {
        'caregiverId': 'caregiver_aditya_chennai',
        'ownerId': 'demo_user_023',
        'ownerName': 'Ravi Kumar',
        'rating': 4.0,
        'comment': 'Good trainer with solid basics. My Beagle improved a lot. Would be 5 stars with more advanced training options.',
        'createdAt': now.subtract(const Duration(days: 38)),
      },

      // Additional reviews
      {
        'caregiverId': 'caregiver_vikram_mumbai',
        'ownerId': 'demo_user_024',
        'ownerName': 'Pooja Desai',
        'rating': 5.0,
        'comment': 'Vikram is a behavior expert! He helped with my dog\'s aggression issues. Very knowledgeable and effective. Highly recommended!',
        'createdAt': now.subtract(const Duration(days: 19)),
      },
      {
        'caregiverId': 'caregiver_amit_pune',
        'ownerId': 'demo_user_025',
        'ownerName': 'Suresh Patil',
        'rating': 5.0,
        'comment': 'Reliable dog walker! Amit is punctual and my dog loves the group walks. Great for socialization. Very trustworthy!',
        'createdAt': now.subtract(const Duration(days: 24)),
      },
    ];

    // Seed reviews to Firestore
    for (var review in sampleReviews) {
      await _firestore.collection('reviews').add(review);
    }
    
    debugPrint('✅ Seeded ${sampleReviews.length} sample reviews successfully!');
  }
}
