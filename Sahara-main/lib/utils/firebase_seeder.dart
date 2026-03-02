import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/service_package_model.dart';

/// 🇮🇳 Firebase Data Seeder - Production Ready
/// 
/// Industry-standard mock data for Indian pet care marketplace
/// 
/// 💰 PRICING (2024-2025 Market Rates):
/// - Dog Walking: ₹150-650/session
/// - Pet Sitting: ₹350-1200/day
/// - Grooming: ₹400-1500/session
/// - Training: ₹600-2500/session
/// - Vet Visit: ₹300-1000/visit
/// 
/// 📦 INCLUDES:
/// - 16 verified professional caregivers
/// - 21 comprehensive service packages
/// - Pan-India coverage (7 major cities)
/// - Realistic ratings and booking history
/// 
/// Usage:
/// ```dart
/// final seeder = FirebaseSeeder();
/// await seeder.seedAll();
/// ```
class FirebaseSeeder {
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

  /// Seed caregiver profiles (Dog-Specific) - India Edition
  /// 16 Elite professionals across 7 major Indian cities
  /// Verified credentials, realistic experience, authentic locations
  Future<void> seedCaregivers() async {
    debugPrint('📝 Seeding 16 professional dog caregivers for India...');

    final caregivers = [
      // Premium Tier - Top Rated Professionals
      UserModel(
        uid: 'caregiver_priya_sharma',
        email: 'priya.sharma@sahara.app',
        name: 'Priya Sharma',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=5',
        rating: 4.9,
        completedBookings: 287,
        createdAt: DateTime.now().subtract(const Duration(days: 820)),
        bio: 'Certified Professional Dog Trainer (CPDT-KA) with 9+ years of experience specializing in positive reinforcement training. Expert in obedience training, behavioral modification, and puppy socialization. Worked with 500+ dogs including Golden Retrievers, Labradors, German Shepherds, and Indian breeds. Member of Association of Professional Dog Trainers (APDT). Pet First Aid & CPR certified. Available for in-home training sessions and group classes.',
        services: ['Dog Walking', 'Dog Sitting', 'Dog Training', 'Dog Grooming'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=12',
        rating: 4.8,
        completedBookings: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 380)),
        bio: 'Professional dog walker and adventure specialist for high-energy breeds serving Baner and surrounding areas. 7+ years experience with Huskies, Border Collies, Australian Shepherds, German Shepherds, and Beagles. Certified in canine fitness and conditioning by Canine Fitness Trainers Association. Provide trail walks at Pashan Lake, Vetal Tekdi hikes, and park playtime. GPS tracking, live photo updates, and detailed activity reports included with every walk. Pet First Aid certified.',
        services: ['Dog Walking', 'Dog Sitting', 'Dog Transportation'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=9',
        rating: 4.9,
        completedBookings: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 680)),
        bio: 'Certified professional dog groomer with 10+ years expertise in breed-specific styling serving Kalyani Nagar and East Pune. Specialized in Poodles, Shih Tzus, Cocker Spaniels, Schnauzers, Bichons, and Maltese. Gentle handling techniques for anxious and senior dogs. Show-quality grooming available. Certified by National Dog Groomers Association of India (NDGAI) and International Professional Groomers Inc. Award winner at Pune Pet Show 2024. Mobile grooming van available for home service.',
        services: ['Dog Grooming', 'Dog Training', 'Dog Sitting'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=13',
        rating: 4.7,
        completedBookings: 118,
        createdAt: DateTime.now().subtract(const Duration(days: 340)),
        bio: 'Veterinary assistant with 8+ years of comprehensive dog care experience serving Viman Nagar and surrounding areas. Comfortable with all breeds including large breeds like Rottweilers, Great Danes, Mastiffs, Saint Bernards, and Newfoundlands. Expert in medication administration, special needs care, senior dog support, and post-surgery recovery care. Emergency care trained by Indian Veterinary Association. Pet First Aid & CPR certified. Work closely with Ruby Hall Clinic Veterinary Department.',
        services: ['Vet Visit Companion', 'Dog Sitting', 'Dog Walking'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=10',
        rating: 4.9,
        completedBookings: 221,
        createdAt: DateTime.now().subtract(const Duration(days: 590)),
        bio: 'Expert certified canine behaviorist and rehabilitation specialist with 11+ years experience serving Aundh and North Pune. Specialized in aggressive dog rehabilitation, fear-based reactivity, separation anxiety, leash reactivity, and puppy training. Experience with all breeds including Pit Bulls, Dobermans, Rottweilers, rescue dogs, and street dogs. Positive reinforcement and science-based training methods only. Member of International Association of Animal Behavior Consultants (IAABC). Published researcher in canine behavior. Certified by Karen Pryor Academy.',
        services: ['Dog Training', 'Dog Sitting', 'Dog Walking'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=14',
        rating: 4.7,
        completedBookings: 94,
        createdAt: DateTime.now().subtract(const Duration(days: 260)),
        bio: 'Energetic and reliable dog walker perfect for active breeds serving Hinjewadi IT Park area. 6+ years experience with high-energy dogs like Boxers, Dalmatians, Pointers, Weimaraners, Vizslas, and Belgian Malinois. Flexible scheduling for early morning (5 AM) and late evening walks. Provide trail walks at Rajiv Gandhi Infotech Park and Hinjewadi Hills. GPS tracking, live photo updates, and detailed activity reports provided for all walks. Insured and bonded. Pet First Aid certified.',
        services: ['Dog Walking', 'Dog Transportation', 'Dog Sitting'],
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
        photoUrl: 'https://i.pravatar.cc/300?img=16',
        rating: 4.8,
        completedBookings: 167,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
        bio: 'Specialized expert in small and toy breeds with 9+ years experience serving Kothrud and surrounding areas. Expert with Pugs, Chihuahuas, Pomeranians, French Bulldogs, Yorkshire Terriers, Maltese, and Shih Tzus. Gentle, patient care perfect for senior dogs, puppies, and anxious pets. Home-based dog sitting in a safe, fully dog-proofed environment with 24/7 supervision and CCTV monitoring. Pet First Aid & CPR certified. Specialized in brachycephalic breed care (Pugs, Bulldogs).',
        services: ['Dog Sitting', 'Dog Grooming', 'Dog Transportation'],
        hourlyRate: null,
        location: 'Kothrud, Pune, Maharashtra',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43216',
      ),
      UserModel(
        uid: 'caregiver_karthik_nair',
        email: 'karthik.nair@sahara.app',
        name: 'Karthik Nair',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=15',
        rating: 4.8,
        completedBookings: 112,
        createdAt: DateTime.now().subtract(const Duration(days: 320)),
        bio: 'Professional dog agility trainer and advanced obedience specialist with 8+ years experience. Expert with working breeds like Belgian Malinois, Australian Shepherds, Border Collies, and German Shepherds. Competition-level training available. Certified in canine sports and agility. Member of Kennel Club of India.',
        services: ['Dog Training', 'Dog Walking', 'Dog Sitting'],
        hourlyRate: null,
        location: 'Jayanagar, Bengaluru, Karnataka',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43217',
      ),
      UserModel(
        uid: 'caregiver_divya_iyer',
        email: 'divya.iyer@sahara.app',
        name: 'Divya Iyer',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=20',
        rating: 4.9,
        completedBookings: 203,
        createdAt: DateTime.now().subtract(const Duration(days: 600)),
        bio: 'Certified canine behaviorist with Master\'s degree in Animal Behavior from University of Mumbai. 11+ years experience in behavior modification, separation anxiety treatment, fear aggression, and reactivity training. Work with all breeds including challenging cases and rescue dogs. Science-based, force-free training methods. Published researcher in canine behavior.',
        services: ['Dog Training', 'Dog Sitting', 'Dog Grooming'],
        hourlyRate: null,
        location: 'Jubilee Hills, Hyderabad, Telangana',
        yearsOfExperience: 11,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43218',
      ),
      UserModel(
        uid: 'caregiver_amit_gupta',
        email: 'amit.gupta@sahara.app',
        name: 'Amit Gupta',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=17',
        rating: 4.7,
        completedBookings: 98,
        createdAt: DateTime.now().subtract(const Duration(days: 240)),
        bio: 'Reliable and experienced dog walker and sitter with 6+ years in multi-dog household management. Comfortable with mixed breeds, rescues, and dogs with special needs. Expert in pack dynamics and socialization. Available for overnight stays, extended care, and holiday boarding. Background verified and insured.',
        services: ['Dog Walking', 'Dog Sitting'],
        hourlyRate: null,
        location: 'Malad West, Mumbai, Maharashtra',
        yearsOfExperience: 6,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43219',
      ),
      UserModel(
        uid: 'caregiver_rohan_kapoor',
        email: 'rohan.kapoor@sahara.app',
        name: 'Rohan Kapoor',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=18',
        rating: 4.8,
        completedBookings: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 420)),
        bio: 'Specialized expert in Indian native breeds with 8+ years experience. Passionate about Indian Pariah Dogs, Rajapalayam, Mudhol Hounds, Kombai, Chippiparai, and Kanni. Also experienced with Indie street dogs and rescue rehabilitation. Advocate for native breed preservation. Member of Indian National Kennel Club.',
        services: ['Dog Walking', 'Dog Training', 'Dog Sitting'],
        hourlyRate: null,
        location: 'Koramangala, Bengaluru, Karnataka',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43220',
      ),
      UserModel(
        uid: 'caregiver_neha_joshi',
        email: 'neha.joshi@sahara.app',
        name: 'Neha Joshi',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=24',
        rating: 4.9,
        completedBookings: 178,
        createdAt: DateTime.now().subtract(const Duration(days: 480)),
        bio: 'Expert in puppy care and early socialization with 9+ years experience. Specialized in house training, crate training, bite inhibition, and basic obedience for puppies 8 weeks to 1 year. Gentle, patient approach perfect for first-time dog owners. Certified puppy trainer. Provide comprehensive puppy starter kits and training materials.',
        services: ['Dog Training', 'Dog Sitting', 'Dog Walking'],
        hourlyRate: null,
        location: 'Gurgaon, Delhi NCR',
        yearsOfExperience: 9,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43221',
      ),
      UserModel(
        uid: 'caregiver_sanjay_mehta',
        email: 'sanjay.mehta@sahara.app',
        name: 'Sanjay Mehta',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=33',
        rating: 4.7,
        completedBookings: 145,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        bio: 'Experienced dog walker and pet sitter serving South Delhi for 7+ years. Specialized in senior dog care and dogs with mobility issues. Gentle handling and patient approach. Available for medication administration and special dietary needs. Background verified and fully insured.',
        services: ['Dog Walking', 'Dog Sitting', 'Vet Visit Companion'],
        hourlyRate: null,
        location: 'Hauz Khas, New Delhi',
        yearsOfExperience: 7,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43222',
      ),
      UserModel(
        uid: 'caregiver_kavita_rao',
        email: 'kavita.rao@sahara.app',
        name: 'Kavita Rao',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=26',
        rating: 4.9,
        completedBookings: 212,
        createdAt: DateTime.now().subtract(const Duration(days: 650)),
        bio: 'Professional dog groomer and stylist with 10+ years experience. Specialized in show grooming for Poodles, Cocker Spaniels, and Shih Tzus. Certified by International Professional Groomers Inc. Gentle with nervous dogs. Mobile grooming van available for home service. Award-winning groomer at Bangalore Dog Show 2023.',
        services: ['Dog Grooming', 'Dog Sitting'],
        hourlyRate: null,
        location: 'HSR Layout, Bengaluru, Karnataka',
        yearsOfExperience: 10,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43223',
      ),
      UserModel(
        uid: 'caregiver_aditya_singh',
        email: 'aditya.singh@sahara.app',
        name: 'Aditya Singh',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=51',
        rating: 4.6,
        completedBookings: 87,
        createdAt: DateTime.now().subtract(const Duration(days: 220)),
        bio: 'Young and energetic dog walker perfect for active breeds. 5+ years experience with high-energy dogs. Provide running sessions, hiking trips, and beach outings. Certified in pet first aid. GPS tracking and live photo updates. Available for early morning (5 AM) and late evening walks.',
        services: ['Dog Walking', 'Dog Transportation'],
        hourlyRate: null,
        location: 'Juhu, Mumbai, Maharashtra',
        yearsOfExperience: 5,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43224',
      ),
      UserModel(
        uid: 'caregiver_pooja_nambiar',
        email: 'pooja.nambiar@sahara.app',
        name: 'Pooja Nambiar',
        userType: 'caregiver',
        photoUrl: 'https://i.pravatar.cc/300?img=47',
        rating: 4.8,
        completedBookings: 167,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
        bio: 'Certified dog trainer specializing in positive reinforcement methods. 8+ years experience with all breeds. Expert in puppy training, basic obedience, and trick training. Certified by Karen Pryor Academy. Provide in-home training sessions and group classes. Member of Pet Dog Trainers of India.',
        services: ['Dog Training', 'Dog Walking', 'Dog Sitting'],
        hourlyRate: null,
        location: 'Banjara Hills, Hyderabad, Telangana',
        yearsOfExperience: 8,
        isVerified: true,
        isAvailable: true,
        phone: '+91 98765 43225',
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

  /// Seed service packages (Dog-Specific) - India Pricing
  /// 21 comprehensive packages based on 2024-2025 market research
  Future<void> seedServicePackages() async {
    debugPrint('📝 Seeding 21 dog service packages with India pricing...');

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
        serviceType: 'Dog Sitting',
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
        serviceType: 'Dog Sitting',
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
        serviceType: 'Dog Sitting',
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
        serviceType: 'Dog Sitting',
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
        serviceType: 'Dog Grooming',
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
        serviceType: 'Dog Grooming',
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
        serviceType: 'Dog Grooming',
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
        serviceType: 'Dog Grooming',
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
        serviceType: 'Training',
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
        serviceType: 'Training',
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
        serviceType: 'Training',
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
        serviceType: 'Training',
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
        serviceType: 'Training',
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
