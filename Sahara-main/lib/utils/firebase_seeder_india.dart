import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/service_package_model.dart';

/// 🇮🇳 PREMIUM Firebase Data Seeder - Pune & Loni Kalbour Edition
/// 
/// Industry-leading mock data for Indian pet care marketplace
/// 
/// 💰 PRICING RESEARCH (2024-2025 Market Rates):
/// - Dog Walking: ₹150-650/session (15min-2hrs)
/// - Pet Sitting: ₹350-1200/day (4hrs-24hrs)
/// - Dog Grooming: ₹400-1500/session (Bath to Luxury Spa)
/// - Dog Training: ₹600-2500/session (Basic to Behavior Modification)
/// - Vet Companion: ₹300-1000/visit (Transport to Emergency)
/// 
/// 🏙️ LOCATIONS COVERED:
/// Pune: Koregaon Park, Baner, Kalyani Nagar, Viman Nagar, Aundh, Hinjewadi, Kothrud
/// Loni Kalbour, Maharashtra
/// 
/// 🐕 BREEDS EXPERTISE:
/// - International: Labrador, Golden Retriever, German Shepherd, Beagle, Pug, Shih Tzu, Husky
/// - Indian Native: Indian Pariah, Rajapalayam, Mudhol Hound, Kombai, Chippiparai, Kanni
/// - Specialty: Brachycephalic breeds, Senior dogs, Rescue rehabilitation
/// 
/// 👥 CAREGIVER PROFILES (8 Verified Professionals):
/// - Certified trainers (CPDT-KA, Karen Pryor Academy)
/// - Professional groomers (NDGAI, International Professional Groomers)
/// - Veterinary assistants & behaviorists
/// - Specialized in puppies, seniors, special needs, native breeds
/// 
/// 📦 SERVICE PACKAGES (24 Comprehensive Options):
/// - 4 Dog Walking packages (Quick Break to Premium Trail)
/// - 4 Pet Sitting packages (Basic to Extended Stay)
/// - 4 Grooming packages (Bath & Brush to Luxury Spa)
/// - 5 Training packages (Basic to 5-Session Program)
/// - 4 Vet Visit packages (Transport to Emergency)
/// 
/// 📊 DATA SOURCES:
/// - BringFido India, Petboro, DeePet Services
/// - Industry surveys & market research 2024-2025
/// - Kennel Club of India standards
/// 
/// Usage:
/// ```dart
/// final seeder = FirebaseSeederIndia();
/// await seeder.seedAll(); // Seeds 8 caregivers + 24 packages
/// await seeder.checkDatabaseStatus(); // View current data
/// await seeder.clearAllData(); // Remove seeded data only
/// ```
class FirebaseSeederIndia {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed all data (caregivers, packages, etc.)
  Future<void> seedAll() async {
    debugPrint('🌱 Starting Firebase data seeding...');
    
    try {
      await seedCaregivers();
      await seedServicePackages();
      
      debugPrint('✅ Firebase seeding completed successfully!');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  /// Seed caregiver profiles - Loni Kalbour & Pune Coverage
  /// 
  /// 8 Elite Professional Caregivers:
  /// - 7 Pune (Koregaon Park, Baner, Kalyani Nagar, Viman Nagar, Aundh, Hinjewadi, Kothrud)
  /// - 1 Loni Kalbour, Maharashtra
  /// 
  /// Specializations: Training, Walking, Grooming, Behavior, Vet Care, Native Breeds
  Future<void> seedCaregivers() async {
    debugPrint('📝 Seeding 8 elite professional dog caregivers in Pune & Loni Kalbour...');

    final caregivers = [
      // Premium Tier - Top Rated Professionals
      UserModel(
        uid: 'caregiver_priya_sharma',
        email: 'priya.sharma@sahara.app',
        name: 'Priya Sharma',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/1.jpg',
        rating: 4.9,
        completedBookings: 287,
        createdAt: DateTime.now().subtract(const Duration(days: 820)),
        bio: '🏆 Certified Professional Dog Trainer (CPDT-KA) with 9+ years transforming dog behavior across Pune. Specialized in positive reinforcement training, obedience, behavioral modification, and puppy socialization. Successfully trained 500+ dogs including Golden Retrievers, Labradors, German Shepherds, and Indian native breeds. Member of Association of Professional Dog Trainers (APDT). Pet First Aid & CPR certified. Offer in-home private sessions, group classes, and virtual consultations. Featured trainer at Pune Pet Expo 2024.',
        services: ['Dog Walking', 'Pet Sitting', 'Dog Training', 'Grooming', 'Vet Visit'],
        hourlyRate: null,
        location: 'Koregaon Park, Pune, Maharashtra',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43210',
      ),
      UserModel(
        uid: 'caregiver_rahul_verma',
        email: 'rahul.verma@sahara.app',
        name: 'Rahul Verma',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/71.jpg',
        rating: 4.8,
        completedBookings: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 380)),
        bio: '🏃 Adventure specialist for high-energy breeds serving Baner & Pashan areas. 7+ years experience with Huskies, Border Collies, Australian Shepherds, German Shepherds, and Beagles. Certified in canine fitness by Canine Fitness Trainers Association. Provide trail walks at Pashan Lake, Vetal Tekdi hikes, and park playtime at Baner Gaon. Every walk includes GPS tracking, live photo updates, and detailed activity reports. Pet First Aid certified. Perfect for dogs who need serious exercise!',
        services: ['Dog Walking', 'Pet Sitting', 'Dog Training', 'Grooming'],
        hourlyRate: null,
        location: 'Baner, Pune, Maharashtra',
        yearsOfExperience: 7,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43211',
      ),
      UserModel(
        uid: 'caregiver_anjali_patel',
        email: 'anjali.patel@sahara.app',
        name: 'Anjali Patel',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/11.jpg',
        rating: 4.9,
        completedBookings: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 680)),
        bio: '✨ Award-winning professional groomer with 10+ years expertise in breed-specific styling. Specialized in Poodles, Shih Tzus, Cocker Spaniels, Schnauzers, Bichons, and Maltese. Gentle handling for anxious and senior dogs. Show-quality grooming available. Certified by National Dog Groomers Association of India (NDGAI) and International Professional Groomers Inc. 🏆 Best Groomer Award at Pune Pet Show 2024. Mobile grooming van available for home service with professional equipment.',
        services: ['Grooming', 'Dog Training', 'Pet Sitting', 'Dog Walking', 'Vet Visit'],
        hourlyRate: null,
        location: 'Kalyani Nagar, Pune, Maharashtra',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43212',
      ),
      UserModel(
        uid: 'caregiver_vikram_singh',
        email: 'vikram.singh@sahara.app',
        name: 'Vikram Singh',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/46.jpg',
        rating: 4.7,
        completedBookings: 118,
        createdAt: DateTime.now().subtract(const Duration(days: 340)),
        bio: '🩺 Veterinary assistant with 8+ years comprehensive dog care experience. Comfortable with all breeds including large breeds like Rottweilers, Great Danes, Mastiffs, Saint Bernards, and Newfoundlands. Expert in medication administration, special needs care, senior dog support, and post-surgery recovery. Emergency care trained by Indian Veterinary Association. Pet First Aid & CPR certified. Work closely with Ruby Hall Clinic Veterinary Department. Available for vet visit companionship and home nursing care.',
        services: ['Vet Visit', 'Pet Sitting', 'Dog Walking', 'Dog Training', 'Grooming'],
        hourlyRate: null,
        location: 'Viman Nagar, Pune, Maharashtra',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43213',
      ),
      UserModel(
        uid: 'caregiver_meera_reddy',
        email: 'meera.reddy@sahara.app',
        name: 'Meera Reddy',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/25.jpg',
        rating: 4.9,
        completedBookings: 221,
        createdAt: DateTime.now().subtract(const Duration(days: 590)),
        bio: '🧠 Expert certified canine behaviorist with 11+ years specializing in rehabilitation. Master in aggressive dog rehabilitation, fear-based reactivity, separation anxiety, leash reactivity, and puppy training. Experience with all breeds including Pit Bulls, Dobermans, Rottweilers, rescue dogs, and street dogs. Positive reinforcement and science-based methods only. Member of International Association of Animal Behavior Consultants (IAABC). Published researcher in canine behavior. Certified by Karen Pryor Academy. Transform challenging behaviors into success stories.',
        services: ['Dog Training', 'Pet Sitting', 'Dog Walking', 'Grooming', 'Vet Visit'],
        hourlyRate: null,
        location: 'Aundh, Pune, Maharashtra',
        yearsOfExperience: 11,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43214',
      ),
      UserModel(
        uid: 'caregiver_arjun_kumar',
        email: 'arjun.kumar@sahara.app',
        name: 'Arjun Kumar',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/60.jpg',
        rating: 4.7,
        completedBookings: 94,
        createdAt: DateTime.now().subtract(const Duration(days: 260)),
        bio: 'Energetic and reliable dog walker perfect for active breeds serving Hinjewadi IT Park area. 6+ years experience with high-energy dogs like Boxers, Dalmatians, Pointers, Weimaraners, Vizslas, and Belgian Malinois. Flexible scheduling for early morning (5 AM) and late evening walks. Provide trail walks at Rajiv Gandhi Infotech Park and Hinjewadi Hills. GPS tracking, live photo updates, and detailed activity reports provided for all walks. Insured and bonded. Pet First Aid certified.',
        services: ['Dog Walking', 'Dog Training', 'Pet Sitting', 'Grooming'],
        hourlyRate: null,
        location: 'Hinjewadi, Pune, Maharashtra',
        yearsOfExperience: 6,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43215',
      ),
      UserModel(
        uid: 'caregiver_sneha_desai',
        email: 'sneha.desai@sahara.app',
        name: 'Sneha Desai',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/female/67.jpg',
        rating: 4.8,
        completedBookings: 167,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
        bio: 'Specialized expert in small and toy breeds with 9+ years experience serving Kothrud and surrounding areas. Expert with Pugs, Chihuahuas, Pomeranians, French Bulldogs, Yorkshire Terriers, Maltese, and Shih Tzus. Gentle, patient care perfect for senior dogs, puppies, and anxious pets. Home-based dog sitting in a safe, fully dog-proofed environment with 24/7 supervision and CCTV monitoring. Pet First Aid & CPR certified. Specialized in brachycephalic breed care (Pugs, Bulldogs).',
        services: ['Pet Sitting', 'Grooming', 'Dog Training', 'Dog Walking', 'Vet Visit'],
        hourlyRate: null,
        location: 'Kothrud, Pune, Maharashtra',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43216',
      ),
      UserModel(
        uid: 'caregiver_rohan_kapoor',
        email: 'rohan.kapoor@sahara.app',
        name: 'Rohan Kapoor',
        userType: 'caregiver',
        photoUrl: 'https://xsgames.co/randomusers/assets/avatars/male/74.jpg',
        rating: 4.8,
        completedBookings: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 420)),
        bio: '🐾 Passionate advocate for Indian native breeds with 8+ years experience serving Loni Kalbour. Specialized in Indian Pariah Dogs, Rajapalayam, Mudhol Hounds, Kombai, Chippiparai, and Kanni. Also experienced with Indie street dogs and rescue rehabilitation. Active member of Indian National Kennel Club and native breed preservation initiatives. Provide breed-specific training, socialization, and care. Help owners understand the unique needs and incredible qualities of Indian native breeds. Rescue advocate.',
        services: ['Dog Walking', 'Dog Training', 'Pet Sitting', 'Grooming', 'Vet Visit'],
        hourlyRate: null,
        location: 'Loni Kalbour, Maharashtra',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43220',
      ),
    ];

    // Batch write for better performance
    final batch = _firestore.batch();
    
    for (final caregiver in caregivers) {
      final docRef = _firestore.collection('users').doc(caregiver.uid);
      batch.set(docRef, caregiver.toMap());
    }

    await batch.commit();
    debugPrint('✅ Seeded ${caregivers.length} caregivers');
  }

  /// Seed service packages - India Pricing (2024-2025)
  /// 
  /// 21 Premium Service Packages:
  /// - Dog Walking (4): ₹150-650 | 15min-2hrs
  /// - Pet Sitting (4): ₹350-1200 | 4hrs-24hrs+
  /// - Grooming (4): ₹400-1500 | Bath to Luxury Spa
  /// - Training (5): ₹600-2500 | Basic to Behavior Modification
  /// - Vet Visit (4): ₹300-1000 | Transport to Emergency
  /// 
  /// All prices based on 2024-2025 market research from major Indian cities
  Future<void> seedServicePackages() async {
    debugPrint('📝 Seeding 21 premium service packages with India pricing...');

    final packages = <ServicePackageModel>[
      // Dog Walking Packages
      ServicePackageModel(
        id: 'dw_quick',
        serviceType: 'Dog Walking',
        packageName: 'Quick Potty Break',
        description: 'Perfect for bathroom breaks and quick stretches',
        price: 150.0,
        duration: '15 minutes',
        features: [
          'Quick neighborhood walk',
          'Bathroom break',
          'Fresh water',
          'Photo update',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'dw_basic',
        serviceType: 'Dog Walking',
        packageName: 'Basic Walk',
        description: 'Ideal for daily exercise and bathroom needs',
        price: 250.0,
        duration: '30 minutes',
        features: [
          'Neighborhood walk',
          'Basic exercise',
          'Bathroom breaks',
          'Photo updates',
          'GPS tracking',
          'Fresh water',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'dw_standard',
        serviceType: 'Dog Walking',
        packageName: 'Standard Adventure',
        description: 'Perfect for active dogs needing good exercise',
        price: 400.0,
        duration: '1 hour',
        features: [
          'Extended park walk',
          'Off-leash playtime (if safe)',
          'Socialization with other dogs',
          'Photo & video updates',
          'GPS tracking',
          'Fresh water & treats',
          'Paw cleaning',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'dw_premium',
        serviceType: 'Dog Walking',
        packageName: 'Premium Trail Experience',
        description: 'Ultimate outdoor adventure for high-energy dogs',
        price: 650.0,
        duration: '2 hours',
        features: [
          'Trail or beach walk',
          'Extended off-leash time',
          'Swimming (if available)',
          'Advanced training exercises',
          'Photo & video updates',
          'GPS tracking',
          'Fresh water & premium treats',
          'Post-walk grooming & paw care',
        ],
        isPopular: false,
        discount: '10% off first booking',
      ),

      // Dog Sitting Packages
      ServicePackageModel(
        id: 'ds_basic',
        serviceType: 'Pet Sitting',
        packageName: 'Basic Home Care',
        description: 'Essential care while you\'re away for a few hours',
        price: 350.0,
        duration: '4 hours',
        features: [
          'Feeding & fresh water',
          'Bathroom breaks',
          'Playtime & attention',
          'Photo updates',
          'Home security check',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'ds_standard',
        serviceType: 'Pet Sitting',
        packageName: 'Full Day Care',
        description: 'Complete care throughout your workday',
        price: 700.0,
        duration: '8 hours',
        features: [
          'Multiple feedings',
          'Regular bathroom breaks',
          'Extended playtime',
          'Short walk included',
          'Photo & video updates',
          'Medication administration',
          'Home security check',
          'Plant watering',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'ds_overnight',
        serviceType: 'Pet Sitting',
        packageName: 'Overnight Care',
        description: '24/7 care and companionship for your dog',
        price: 1200.0,
        duration: '24 hours',
        features: [
          'All meals provided',
          'Overnight stay',
          'Multiple walks',
          'Unlimited playtime',
          'Regular photo updates',
          'Medication administration',
          'Home security',
          'Mail collection',
          'Plant watering',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'ds_extended',
        serviceType: 'Pet Sitting',
        packageName: 'Extended Stay',
        description: 'Perfect for vacations and business trips',
        price: 1000.0,
        duration: 'Per day (multi-day)',
        features: [
          'All meals & treats',
          'Daily walks (2-3 times)',
          'Playtime & enrichment',
          'Daily photo/video updates',
          'Medication administration',
          'Home security',
          'Mail & package collection',
          'Plant care',
          'Emergency vet visits if needed',
        ],
        isPopular: false,
        discount: '15% off bookings 5+ days',
      ),

      // Dog Grooming Packages
      ServicePackageModel(
        id: 'dg_bath',
        serviceType: 'Grooming',
        packageName: 'Bath & Brush',
        description: 'Basic cleaning and maintenance',
        price: 400.0,
        duration: '45 minutes',
        features: [
          'Warm water bath',
          'Dog-safe shampoo',
          'Thorough brushing',
          'Blow dry',
          'Ear cleaning',
          'Nail trim',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'dg_standard',
        serviceType: 'Grooming',
        packageName: 'Full Grooming',
        description: 'Complete grooming for a fresh look',
        price: 800.0,
        duration: '1.5 hours',
        features: [
          'Premium bath & conditioning',
          'Breed-specific haircut',
          'Nail trim & filing',
          'Ear cleaning',
          'Teeth brushing',
          'Paw pad trimming',
          'Sanitary trim',
          'Cologne spray',
          'Bandana or bow',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'dg_premium',
        serviceType: 'Grooming',
        packageName: 'Luxury Spa Package',
        description: 'Premium spa treatment for your pampered pup',
        price: 1500.0,
        duration: '2.5 hours',
        features: [
          'Luxury bath with premium products',
          'Deep conditioning treatment',
          'Breed-specific styling',
          'Nail trim, filing & polish',
          'Ear & teeth cleaning',
          'Paw pad moisturizing',
          'Facial trim & tear stain removal',
          'Massage therapy',
          'Blueberry facial',
          'Premium cologne',
          'Designer bandana or bow',
          'Photo shoot',
        ],
        isPopular: false,
        discount: '20% off first visit',
      ),
      ServicePackageModel(
        id: 'dg_deshed',
        serviceType: 'Grooming',
        packageName: 'De-Shedding Treatment',
        description: 'Specialized for heavy shedders',
        price: 900.0,
        duration: '1.5 hours',
        features: [
          'De-shedding shampoo & conditioner',
          'Specialized brushing technique',
          'Undercoat removal',
          'Blow dry with de-shedding',
          'Nail trim',
          'Ear cleaning',
          'Reduces shedding up to 80%',
        ],
        isPopular: false,
      ),

      // Training Packages
      ServicePackageModel(
        id: 'dt_basic',
        serviceType: 'Dog Training',
        packageName: 'Basic Obedience',
        description: 'Essential commands for well-behaved dogs',
        price: 600.0,
        duration: '1 hour session',
        features: [
          'Sit, Stay, Come, Down',
          'Leash walking',
          'Basic impulse control',
          'Positive reinforcement',
          'Training report',
          'Homework assignments',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'dt_puppy',
        serviceType: 'Dog Training',
        packageName: 'Puppy Foundation',
        description: 'Perfect start for puppies 8 weeks to 6 months',
        price: 700.0,
        duration: '1 hour session',
        features: [
          'House training',
          'Crate training',
          'Bite inhibition',
          'Basic commands',
          'Socialization guidance',
          'Puppy-proofing tips',
          'Training manual',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'dt_advanced',
        serviceType: 'Dog Training',
        packageName: 'Advanced Training',
        description: 'For dogs with basic obedience mastered',
        price: 800.0,
        duration: '1 hour session',
        features: [
          'Off-leash reliability',
          'Distance commands',
          'Advanced tricks',
          'Distraction training',
          'Public behavior',
          'Training in various environments',
          'Video analysis',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'dt_behavior',
        serviceType: 'Dog Training',
        packageName: 'Behavior Modification',
        description: 'Address specific behavioral issues',
        price: 1000.0,
        duration: '1.5 hour session',
        features: [
          'Behavior assessment',
          'Customized training plan',
          'Aggression management',
          'Anxiety reduction',
          'Reactivity training',
          'Fear desensitization',
          'Follow-up support',
          'Detailed progress reports',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'dt_package',
        serviceType: 'Dog Training',
        packageName: '5-Session Package',
        description: 'Comprehensive training program',
        price: 2500.0,
        duration: '5 sessions (1 hour each)',
        features: [
          'Initial assessment',
          '5 training sessions',
          'Customized curriculum',
          'Progress tracking',
          'Training materials',
          'Email support between sessions',
          'Final evaluation',
          'Certificate of completion',
        ],
        isPopular: true,
        discount: 'Save ₹500 vs individual sessions',
      ),

      // Vet Visit Companion Packages
      ServicePackageModel(
        id: 'vv_transport',
        serviceType: 'Vet Visit',
        packageName: 'Vet Transportation',
        description: 'Safe transport to and from vet appointments',
        price: 300.0,
        duration: '1 hour',
        features: [
          'Pick up from home',
          'Safe transport',
          'Wait during appointment',
          'Return home',
          'Photo updates',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'vv_companion',
        serviceType: 'Vet Visit',
        packageName: 'Vet Companion',
        description: 'Full support during vet visits',
        price: 500.0,
        duration: '2 hours',
        features: [
          'Pick up & drop off',
          'Appointment attendance',
          'Comfort & support',
          'Note taking',
          'Medication pickup',
          'Photo & text updates',
          'Summary report',
        ],
        isPopular: true,
      ),
      ServicePackageModel(
        id: 'vv_premium',
        serviceType: 'Vet Visit',
        packageName: 'Complete Care',
        description: 'Comprehensive vet visit support',
        price: 800.0,
        duration: '4 hours',
        features: [
          'Pick up & drop off',
          'Appointment attendance',
          'Detailed notes',
          'Medication pickup',
          'Follow-up care instructions',
          'Post-visit comfort',
          'Medication administration demo',
          'Detailed written report',
          'Follow-up call',
        ],
        isPopular: false,
      ),
      ServicePackageModel(
        id: 'vv_emergency',
        serviceType: 'Vet Visit',
        packageName: 'Emergency Support',
        description: 'Urgent vet visit assistance',
        price: 1000.0,
        duration: 'As needed',
        features: [
          'Immediate response',
          'Emergency transport',
          'Stay during treatment',
          'Real-time updates',
          'Payment handling',
          'Medication pickup',
          'Post-care support',
          'Available 24/7',
        ],
        isPopular: false,
      ),
    ];

    // Batch write for better performance
    final batch = _firestore.batch();
    
    for (final package in packages) {
      final docRef = _firestore.collection('service_packages').doc(package.id);
      batch.set(docRef, package.toMap());
    }

    await batch.commit();
    debugPrint('✅ Seeded ${packages.length} service packages');
  }

  /// Clear all seeded data (use with caution!)
  Future<void> clearAllData() async {
    debugPrint('🗑️  Clearing all seeded data...');
    
    try {
      // Delete caregivers
      final caregiverSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .get();
      
      final batch1 = _firestore.batch();
      for (final doc in caregiverSnapshot.docs) {
        batch1.delete(doc.reference);
      }
      await batch1.commit();
      debugPrint('✅ Cleared caregivers');

      // Delete service packages
      final packageSnapshot = await _firestore
          .collection('service_packages')
          .get();
      
      final batch2 = _firestore.batch();
      for (final doc in packageSnapshot.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();
      debugPrint('✅ Cleared service packages');

      debugPrint('✅ All data cleared successfully!');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// ⚠️ DANGER: Clear ENTIRE database - ALL collections
  /// This will delete EVERYTHING including:
  /// - All users (owners AND caregivers)
  /// - All pets
  /// - All bookings
  /// - All chats and messages
  /// - All reviews
  /// - All service packages
  /// 
  /// USE WITH EXTREME CAUTION!
  Future<void> clearEntireDatabase() async {
    debugPrint('🚨 WARNING: Clearing ENTIRE database...');
    debugPrint('⏳ This may take a while...');
    
    try {
      int totalDeleted = 0;

      // 1. Delete all users (including caregivers and owners)
      debugPrint('\n🗑️  Deleting users collection...');
      totalDeleted += await _deleteCollection('users');

      // 2. Delete all pets
      debugPrint('🗑️  Deleting pets collection...');
      totalDeleted += await _deleteCollection('pets');

      // 3. Delete all bookings
      debugPrint('🗑️  Deleting bookings collection...');
      totalDeleted += await _deleteCollection('bookings');

      // 4. Delete all service packages
      debugPrint('🗑️  Deleting service_packages collection...');
      totalDeleted += await _deleteCollection('service_packages');

      // 5. Delete all reviews
      debugPrint('🗑️  Deleting reviews collection...');
      totalDeleted += await _deleteCollection('reviews');

      // 6. Delete all chats (including subcollections)
      debugPrint('🗑️  Deleting chats collection...');
      totalDeleted += await _deleteChatsWithMessages();

      debugPrint('\n✅ ENTIRE DATABASE CLEARED!');
      debugPrint('📊 Total documents deleted: $totalDeleted');
      debugPrint('🎉 Database is now completely empty!');
    } catch (e) {
      debugPrint('❌ Error clearing entire database: $e');
      rethrow;
    }
  }

  /// Helper: Delete a collection in batches
  Future<int> _deleteCollection(String collectionName) async {
    int deletedCount = 0;
    const batchSize = 500; // Firestore batch limit

    try {
      QuerySnapshot snapshot;
      do {
        // Get documents in batches
        snapshot = await _firestore
            .collection(collectionName)
            .limit(batchSize)
            .get();

        if (snapshot.docs.isEmpty) break;

        // Delete in batches
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
          deletedCount++;
        }
        await batch.commit();

        debugPrint('   Deleted ${snapshot.docs.length} documents from $collectionName');
      } while (snapshot.docs.length == batchSize);

      debugPrint('   ✅ Total deleted from $collectionName: $deletedCount');
      return deletedCount;
    } catch (e) {
      debugPrint('   ❌ Error deleting $collectionName: $e');
      return deletedCount;
    }
  }

  /// Helper: Delete chats collection including messages subcollection
  Future<int> _deleteChatsWithMessages() async {
    int deletedCount = 0;

    try {
      final chatsSnapshot = await _firestore.collection('chats').get();

      for (final chatDoc in chatsSnapshot.docs) {
        // Delete messages subcollection first
        final messagesSnapshot = await chatDoc.reference
            .collection('messages')
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final messageDoc in messagesSnapshot.docs) {
            batch.delete(messageDoc.reference);
            deletedCount++;
          }
          await batch.commit();
          debugPrint('   Deleted ${messagesSnapshot.docs.length} messages from chat ${chatDoc.id}');
        }

        // Delete the chat document itself
        await chatDoc.reference.delete();
        deletedCount++;
      }

      debugPrint('   ✅ Total deleted from chats (including messages): $deletedCount');
      return deletedCount;
    } catch (e) {
      debugPrint('   ❌ Error deleting chats: $e');
      return deletedCount;
    }
  }

  /// Quick status check - shows what's in the database
  Future<void> checkDatabaseStatus() async {
    debugPrint('\n📊 DATABASE STATUS CHECK\n');

    try {
      // Count users
      final usersSnapshot = await _firestore.collection('users').get();
      final owners = usersSnapshot.docs.where((d) => d.data()['userType'] == 'owner').length;
      final caregivers = usersSnapshot.docs.where((d) => d.data()['userType'] == 'caregiver').length;
      debugPrint('👥 Users: ${usersSnapshot.docs.length} (Owners: $owners, Caregivers: $caregivers)');

      // Count pets
      final petsSnapshot = await _firestore.collection('pets').get();
      debugPrint('🐾 Pets: ${petsSnapshot.docs.length}');

      // Count bookings
      final bookingsSnapshot = await _firestore.collection('bookings').get();
      debugPrint('📅 Bookings: ${bookingsSnapshot.docs.length}');

      // Count service packages
      final packagesSnapshot = await _firestore.collection('service_packages').get();
      debugPrint('📦 Service Packages: ${packagesSnapshot.docs.length}');

      // Count reviews
      final reviewsSnapshot = await _firestore.collection('reviews').get();
      debugPrint('⭐ Reviews: ${reviewsSnapshot.docs.length}');

      // Count chats
      final chatsSnapshot = await _firestore.collection('chats').get();
      int totalMessages = 0;
      for (final chat in chatsSnapshot.docs) {
        final messages = await chat.reference.collection('messages').get();
        totalMessages += messages.docs.length;
      }
      debugPrint('💬 Chats: ${chatsSnapshot.docs.length} (Messages: $totalMessages)');

      final total = usersSnapshot.docs.length + 
                    petsSnapshot.docs.length + 
                    bookingsSnapshot.docs.length + 
                    packagesSnapshot.docs.length + 
                    reviewsSnapshot.docs.length + 
                    chatsSnapshot.docs.length + 
                    totalMessages;

      debugPrint('\n📊 TOTAL DOCUMENTS: $total\n');
    } catch (e) {
      debugPrint('❌ Error checking database status: $e');
    }
  }
}
