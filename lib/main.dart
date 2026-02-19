import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/manage-pets': (context) => const ManagePetsScreen(),
        '/caregiver-detail': (context) {
          final caregiver = ModalRoute.of(context)?.settings.arguments as Caregiver?;
          return caregiver != null ? CaregiverDetailScreen(caregiver: caregiver) : const HomeScreen();
        },
      },
    );
  }
}

class OnboardingData {
  final String title;
  final String description;

  OnboardingData({
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      title: 'Find Trusted Caregivers',
      description:
          'Connect with verified pet walkers and caregivers in your area who love animals as much as you do.',
    ),
    OnboardingData(
      title: 'Track in Real-Time',
      description:
          'Monitor your pet\'s activities with live GPS tracking and receive photo updates during walks.',
    ),
    OnboardingData(
      title: 'Peace of Mind',
      description:
          'Book with confidence knowing all caregivers are background-checked and highly rated by the community.',
    ),
  ];

  // Asset images for onboarding pages
  final Map<String, String> onboardingImages = {
    'Find Trusted Caregivers': 'assets/find_trusted_caregivers.jpg',
    'Track in Real-Time': 'assets/Track_in_real_time.jpg',
    'Peace of Mind': 'assets/Peace_of_mind.jpg',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login/signup
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  data: onboardingPages[index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingPages.length,
                    (index) => Container(
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? const Color(0xFF0099CC)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Navigation Buttons
                Row(
                  children: [
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0099CC),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == onboardingPages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  final OnboardingData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC8E6F5),
            Color(0xFFF0E8F8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Animated Placeholder Image
            Expanded(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.data.title == 'Find Trusted Caregivers'
                            ? 'assets/find_trusted_caregivers.jpg'
                            : widget.data.title == 'Track in Real-Time'
                                ? 'assets/Track_in_real_time.jpg'
                                : 'assets/Peace_of_mind.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Animated Title and Description
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Title
                    Text(
                      widget.data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003D66),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      widget.data.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A7C99),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a small delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC8E6F5),
              Color(0xFFF0E8F8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003D66),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        const Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A7C99),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Email Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 15,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 15,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0099CC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Or Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFDDDDDD),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFDDDDDD),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Google Button
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Apple Button
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.apple,
                                    size: 20,
                                    color: Color(0xFF333333),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Apple',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF666666),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed('/signup');
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0099CC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Screen Models & Classes
class Caregiver {
  final String name;
  final double rating;
  final double distance;
  final double hourlyRate;
  final String specialty;
  final List<String> profileImages;
  final String location;
  final List<String> services;
  final String about;
  final int experience;

  Caregiver({
    required this.name,
    required this.rating,
    required this.distance,
    required this.hourlyRate,
    required this.specialty,
    required this.profileImages,
    required this.location,
    required this.services,
    required this.about,
    required this.experience,
  });
}

class Pet {
  final String name;
  final String breed;
  final String age;
  final String weight;
  final String? imagePath;

  Pet({
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    this.imagePath,
  });
}

final List<Pet> userPets = [
  Pet(
    name: 'Max',
    breed: 'Golden Retriever',
    age: '3',
    weight: '32',
    imagePath: null,
  ),
];

final Set<String> favoriteCaregivers = <String>{};

final List<Caregiver> nearbyCaregivers = [
  Caregiver(
    name: 'Sarah Johnson',
    rating: 4.9,
    distance: 0.8,
    hourlyRate: 25,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Downtown, 2km away',
    services: ['Dog Walking', 'Pet Sitting', 'Dog Training'],
    about: 'Professional pet care specialist with 5+ years of experience. Sarah loves all dogs and provides personalized care with daily updates.',
    experience: 5,
  ),
  Caregiver(
    name: 'Marcus Williams',
    rating: 4.8,
    distance: 1.2,
    hourlyRate: 22,
    specialty: 'Grooming',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Midtown, 1.2km away',
    services: ['Grooming', 'Dog Bathing', 'Nail Trimming'],
    about: 'Expert groomer with certified training. Marcus specializes in all dog breeds and ensures your pet looks their best.',
    experience: 7,
  ),
  Caregiver(
    name: 'Emma Rodriguez',
    rating: 4.95,
    distance: 0.5,
    hourlyRate: 28,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Riverside, 500m away',
    services: ['Pet Sitting', 'Dog Walking', 'Overnight Care'],
    about: 'Compassionate pet sitter who treats every pet like family. Emma offers flexible scheduling and daily photo updates.',
    experience: 6,
  ),
  Caregiver(
    name: 'David Chen',
    rating: 4.7,
    distance: 1.5,
    hourlyRate: 26,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Westside, 1.5km away',
    services: ['Dog Walking', 'Group Walks', 'Exercise Training'],
    about: 'Athletic and energetic dog walker. David specializes in high-energy dogs and provides structured exercise routines.',
    experience: 4,
  ),
  Caregiver(
    name: 'Olivia Martinez',
    rating: 4.85,
    distance: 0.9,
    hourlyRate: 26,
    specialty: 'Vet',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Healthcare District, 900m away',
    services: ['Medical Care', 'Health Monitoring', 'Medication Administration'],
    about: 'Licensed veterinary technician with extensive medical knowledge. Olivia provides professional health monitoring and care.',
    experience: 8,
  ),
  Caregiver(
    name: 'James Murphy',
    rating: 4.6,
    distance: 1.8,
    hourlyRate: 20,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Eastside, 1.8km away',
    services: ['Dog Walking', 'Basic Training', 'Socialization'],
    about: 'Friendly dog walker with a passion for helping dogs socialize. James creates a safe and fun environment for all pets.',
    experience: 3,
  ),
  Caregiver(
    name: 'Sophie Bennett',
    rating: 4.9,
    distance: 0.7,
    hourlyRate: 27,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Park View, 700m away',
    services: ['Pet Sitting', 'Dog Walking', 'Playdate Coordination'],
    about: 'Experienced pet sitter with a special touch for anxious pets. Sophie creates calm environments and provides constant care.',
    experience: 6,
  ),
  Caregiver(
    name: 'Michael Torres',
    rating: 4.75,
    distance: 1.3,
    hourlyRate: 24,
    specialty: 'Grooming',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Commerce Ave, 1.3km away',
    services: ['Full Grooming', 'Spa Treatments', 'Show Prep'],
    about: 'Professional groomer with show experience. Michael provides premium grooming services tailored to each dog\'s needs.',
    experience: 9,
  ),
  Caregiver(
    name: 'Lisa Anderson',
    rating: 4.8,
    distance: 1.1,
    hourlyRate: 25,
    specialty: 'Training',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Learning Center, 1.1km away',
    services: ['Obedience Training', 'Behavior Correction', 'Puppy Training'],
    about: 'Certified dog trainer specializing in positive reinforcement. Lisa helps dogs learn good behavior in a fun way.',
    experience: 11,
  ),
  Caregiver(
    name: 'Carlos Rodriguez',
    rating: 4.65,
    distance: 2.0,
    hourlyRate: 23,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Northgate, 2km away',
    services: ['Dog Walking', 'Adventure Hikes', 'Beach Trips'],
    about: 'Adventure-loving dog walker who enjoys outdoor activities. Carlos takes dogs on exciting outings and nature walks.',
    experience: 5,
  ),
  Caregiver(
    name: 'Rachel White',
    rating: 4.92,
    distance: 0.6,
    hourlyRate: 29,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Central Heights, 600m away',
    services: ['Overnight Sitting', 'Busy Day Care', 'Special Needs Care'],
    about: 'Premium pet care specialist. Rachel excels at caring for senior pets and dogs with special needs.',
    experience: 10,
  ),
];

final List<Caregiver> topRatedCaregivers = [
  Caregiver(
    name: 'Sarah Johnson',
    rating: 4.9,
    distance: 0.8,
    hourlyRate: 25,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4'],
    location: 'Downtown, 2km away',
    services: ['Dog Walking', 'Pet Sitting', 'Dog Training'],
    about: 'Professional pet care specialist with 5+ years of experience. Sarah loves all dogs and provides personalized care with daily updates.',
    experience: 5,
  ),
  Caregiver(
    name: 'Marcus Williams',
    rating: 4.8,
    distance: 1.2,
    hourlyRate: 22,
    specialty: 'Grooming',
    profileImages: ['1', '2', '3', '4'],
    location: 'Midtown, 1.2km away',
    services: ['Grooming', 'Dog Bathing', 'Nail Trimming'],
    about: 'Expert groomer with certified training. Marcus specializes in all dog breeds and ensures your pet looks their best.',
    experience: 7,
  ),
  Caregiver(
    name: 'Emma Rodriguez',
    rating: 4.95,
    distance: 0.5,
    hourlyRate: 28,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4'],
    location: 'Riverside, 500m away',
    services: ['Pet Sitting', 'Dog Walking', 'Overnight Care'],
    about: 'Compassionate pet sitter who treats every pet like family. Emma offers flexible scheduling and daily photo updates.',
    experience: 6,
  ),
  Caregiver(
    name: 'Olivia Martinez',
    rating: 4.85,
    distance: 0.9,
    hourlyRate: 26,
    specialty: 'Vet',
    profileImages: ['1', '2', '3', '4'],
    location: 'Healthcare District, 900m away',
    services: ['Medical Care', 'Health Monitoring', 'Medication Administration'],
    about: 'Licensed veterinary technician with extensive medical knowledge. Olivia provides professional health monitoring and care.',
    experience: 8,
  ),
];

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Walking', 'Grooming', 'Sitting', 'Vet'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0099CC),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: const Color(0xFF0099CC),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0, 0.3, curve: Curves.easeInOut),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            const Text(
                              'Good Morning, Aayush',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Location
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'San Francisco, CA',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Search Bar
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search caregivers...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 15,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF0099CC),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Category Filter
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _categories.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedCategory == index
                                    ? const Color(0xFF0099CC)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _selectedCategory == index
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF0099CC)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedCategory == index
                                      ? Colors.white
                                      : const Color(0xFF4A7C99),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Nearby Caregivers Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nearby Caregivers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0099CC),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Caregivers Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.88,
                          ),
                          itemCount: nearbyCaregivers.length,
                          itemBuilder: (context, index) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.7, end: 1).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    0.5 + (index * 0.1),
                                    0.8 + (index * 0.1),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/caregiver-detail',
                                    arguments: nearbyCaregivers[index],
                                  );
                                },
                                child: _buildCaregiverCard(
                                  nearbyCaregivers[index],
                                  isGridView: true,
                                  onFavoriteToggle: () {
                                    setState(() {
                                      if (favoriteCaregivers.contains(nearbyCaregivers[index].name)) {
                                        favoriteCaregivers.remove(nearbyCaregivers[index].name);
                                      } else {
                                        favoriteCaregivers.add(nearbyCaregivers[index].name);
                                      }
                                    });
                                  },
                                  isFavorite: favoriteCaregivers.contains(nearbyCaregivers[index].name),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Top Rated Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 0.9, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Rated',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003D66),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topRatedCaregivers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final startValue = (0.6 + (index * 0.04)).clamp(0.0, 0.95);
                            final endValue = (0.85 + (index * 0.04)).clamp(0.0, 0.99);
                            
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    startValue,
                                    endValue,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/caregiver-detail',
                                    arguments: topRatedCaregivers[index],
                                  );
                                },
                                child: _buildCaregiverCard(
                                  topRatedCaregivers[index],
                                  isGridView: false,
                                  onFavoriteToggle: () {
                                    setState(() {
                                      if (favoriteCaregivers.contains(topRatedCaregivers[index].name)) {
                                        favoriteCaregivers.remove(topRatedCaregivers[index].name);
                                      } else {
                                        favoriteCaregivers.add(topRatedCaregivers[index].name);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Added to favourites'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  isFavorite: favoriteCaregivers.contains(topRatedCaregivers[index].name),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero)
                  .animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'Home', 0),
                    _buildNavItem(Icons.location_on, 'Tracking', 1),
                    _buildNavItem(Icons.chat_bubble, 'Chat', 2),
                    _buildNavItem(Icons.person, 'Profile', 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: index == 1
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrackingScreen(),
                ),
              );
            }
          : index == 3
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              : () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: index == 0
                ? const Color(0xFF0099CC)
                : const Color(0xFFAAAAAA),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: index == 0
                  ? const Color(0xFF0099CC)
                  : const Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverCard(Caregiver caregiver, {
    required bool isGridView,
    VoidCallback? onFavoriteToggle,
    bool isFavorite = false,
  }) {
    if (isGridView) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Pictures Grid
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFE8F4F8),
                      child: caregiver.name == 'Sarah Johnson'
                          ? Image.asset(
                              'assets/Sarah_Johnson.jpg',
                              fit: BoxFit.cover,
                            )
                          : caregiver.name == 'Marcus Williams'
                              ? Image.asset(
                                  'assets/Marcus_Williams.jpg',
                                  fit: BoxFit.cover,
                                )
                              : GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        caregiver.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003D66),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFA500),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${caregiver.rating}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003D66),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF999999),
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${caregiver.distance} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${caregiver.hourlyRate}/hr',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0099CC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Heart Icon
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : const Color(0xFF9AA7B2),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // List View Card
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Row(
              children: [
                // Profile Pictures
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFE8F4F8),
                    child: caregiver.name == 'Sarah Johnson'
                        ? Image.asset(
                            'assets/Sarah_Johnson.jpg',
                            fit: BoxFit.cover,
                          )
                        : caregiver.name == 'Marcus Williams'
                            ? Image.asset(
                                'assets/Marcus_Williams.jpg',
                                fit: BoxFit.cover,
                              )
                            : GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              caregiver.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003D66),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF0099CC),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFA500),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${caregiver.rating}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003D66),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF999999),
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${caregiver.distance} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${caregiver.hourlyRate}/hr',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0099CC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Heart Icon for List View
            Positioned(
              bottom: 6,
              right: 6,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : const Color(0xFF9AA7B2),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Tracking Screen
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0099CC),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0, 0.3, curve: Curves.easeInOut),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Live Tracking',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Max is on a walk with Sarah',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Map Card
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6F9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CustomPaint(
                              painter: GridPainter(),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Live Tracking',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: RoutePainter(),
                            ),
                          ),
                          Positioned(
                            left: 70,
                            bottom: 40,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0099CC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Stats
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Expanded(
                          child: TrackingStatCard(
                            icon: Icons.location_on,
                            value: '2.4',
                            unit: 'km',
                            label: 'Distance',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TrackingStatCard(
                            icon: Icons.schedule,
                            value: '24',
                            unit: 'min',
                            label: 'Time',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TrackingStatCard(
                            icon: Icons.local_fire_department,
                            value: '48',
                            unit: 'cal',
                            label: 'Calories',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Live Updates
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.photo_camera,
                                color: Color(0xFF0099CC),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Live Updates',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const TrackingUpdateItem(
                            title: 'Playing at the park!',
                            time: '10:15 AM',
                          ),
                          const SizedBox(height: 14),
                          const TrackingUpdateItem(
                            title: 'Hydration break',
                            time: '10:30 AM',
                          ),
                          const SizedBox(height: 14),
                          const TrackingUpdateItem(
                            title: 'Making new friends',
                            time: '10:45 AM',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrackingNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                  ),
                  _buildTrackingNavItem(
                    icon: Icons.location_on,
                    label: 'Tracking',
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildTrackingNavItem(
                    icon: Icons.chat_bubble,
                    label: 'Chat',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildTrackingNavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/profile');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF0099CC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            )
          else
            Icon(
              icon,
              color: const Color(0xFF9AA7B2),
              size: 22,
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF003D66) : const Color(0xFF9AA7B2),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;

  const TrackingStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0099CC),
            size: 20,
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003D66),
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003D66),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7B8E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingUpdateItem extends StatelessWidget {
  final String title;
  final String time;

  const TrackingUpdateItem({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F4),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Icon(
            Icons.pets,
            color: Color(0xFF9AA7B2),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF003D66),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7B8E9E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDECF2)
      ..strokeWidth = 1;

    const double gap = 18;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Caregiver> uniqueCaregivers = {
      for (final caregiver in [...nearbyCaregivers, ...topRatedCaregivers])
        caregiver.name: caregiver,
    };
    final favoriteList = uniqueCaregivers.values
        .where((caregiver) => favoriteCaregivers.contains(caregiver.name))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003D66)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favourites',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003D66),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: favoriteList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: Color(0xFFCCCCCC),
                          size: 56,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No favourites yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7B8E9E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add caregivers to your favourites',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9AA7B2),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: favoriteList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final caregiver = favoriteList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/caregiver-detail',
                            arguments: caregiver,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 74,
                                  height: 74,
                                  color: const Color(0xFFE8F4F8),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF9AA7B2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caregiver.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF003D66),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFFA500),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${caregiver.rating}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF003D66),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${caregiver.hourlyRate}/hr',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0099CC),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${caregiver.distance} km • ${caregiver.specialty}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF7B8E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class ManagePetsScreen extends StatefulWidget {
  const ManagePetsScreen({super.key});

  @override
  State<ManagePetsScreen> createState() => _ManagePetsScreenState();
}

class _ManagePetsScreenState extends State<ManagePetsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPetForm({Pet? pet, int? index}) {
    final nameController = TextEditingController(text: pet?.name ?? '');
    final breedController = TextEditingController(text: pet?.breed ?? '');
    final ageController = TextEditingController(text: pet?.age ?? '');
    final weightController = TextEditingController(text: pet?.weight ?? '');
    final imagePicker = ImagePicker();
    String? tempImagePath = pet?.imagePath;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet == null ? 'Add Pet' : 'Edit Pet',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003D66),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF7B8E9E),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9FB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE0E8F0),
                        width: 2,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tempImagePath = picked.path;
                          });
                        }
                      },
                      child: tempImagePath != null && tempImagePath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(tempImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0099CC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Upload Pet Image',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0099CC),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFormLabel('Pet Name'),
                  const SizedBox(height: 8),
                  _buildFormField(controller: nameController, hintText: 'Enter pet name'),
                  const SizedBox(height: 16),
                  _buildFormLabel('Pet Breed'),
                  const SizedBox(height: 8),
                  _buildFormField(controller: breedController, hintText: 'Enter pet breed'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Age (years)'),
                            const SizedBox(height: 8),
                            _buildFormField(
                              controller: ageController,
                              hintText: 'e.g., 3',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Weight (kg)'),
                            const SizedBox(height: 8),
                            _buildFormField(
                              controller: weightController,
                              hintText: 'e.g., 32',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (pet != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (index != null) {
                                  userPets.removeAt(index);
                                }
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEAEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE84C3D),
                              ),
                            ),
                          ),
                        ),
                      if (pet != null) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final newPet = Pet(
                              name: nameController.text.isEmpty
                                  ? 'My Pet'
                                  : nameController.text,
                              breed: breedController.text.isEmpty
                                  ? 'Unknown'
                                  : breedController.text,
                              age: ageController.text.isEmpty ? '0' : ageController.text,
                              weight: weightController.text.isEmpty
                                  ? '0'
                                  : weightController.text,
                              imagePath: tempImagePath,
                            );
                            setState(() {
                              if (index != null) {
                                userPets[index] = newPet;
                              } else {
                                userPets.add(newPet);
                              }
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0099CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            pet == null ? 'Add Pet' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF003D66),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9AA7B2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE0E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE0E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0099CC),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003D66)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Pets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003D66),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF003D66)),
            onPressed: () => _showPetForm(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: userPets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          color: Color(0xFFCCCCCC),
                          size: 56,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No pets added yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7B8E9E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your pets to manage them',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9AA7B2),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: userPets.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pet = userPets[index];
                      return GestureDetector(
                        onTap: () => _showPetForm(pet: pet, index: index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: const Color(0xFFF0F2F4),
                                  child: pet.imagePath != null &&
                                          pet.imagePath!.isNotEmpty
                                      ? Image.file(
                                          File(pet.imagePath!),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.pets,
                                          color: Color(0xFF9AA7B2),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF003D66),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pet.breed,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF7B8E9E),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${pet.age} years • ${pet.weight} kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF7B8E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.edit,
                                color: Color(0xFF0099CC),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0099CC),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0, 0.3, curve: Curves.easeInOut),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Aayush',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'aayush@pettrust.com',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // My Pets Card
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Pets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003D66),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (userPets.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'No pets added yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7B8E9E),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: userPets
                                  .map(
                                    (pet) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(26),
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: const Color(0xFFF0F2F4),
                                              child: pet.imagePath != null &&
                                                      pet.imagePath!.isNotEmpty
                                                  ? Image.file(
                                                      File(pet.imagePath!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(
                                                      Icons.pets,
                                                      color: Color(0xFF9AA7B2),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pet.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF003D66),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  pet.breed,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF7B8E9E),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${pet.age} years',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF7B8E9E),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${pet.weight} kg',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF7B8E9E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Booking History
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.35, 0.75, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003D66),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBookingItem(
                            name: 'Sarah Johnson',
                            detail: 'Walking • 2026-02-20 at 10:00 AM',
                            status: 'Upcoming',
                            statusColor: const Color(0xFF0099CC),
                          ),
                          const SizedBox(height: 14),
                          _buildBookingItem(
                            name: 'Emma Rodriguez',
                            detail: 'Grooming • 2026-02-15 at 2:00 PM',
                            status: 'Completed',
                            statusColor: const Color(0xFF7BBF9B),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Settings
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 0.95, curve: Curves.easeOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003D66),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSettingRow(Icons.person, 'Manage Pets', onTap: _openManagePetsPage),
                          _buildSettingRow(Icons.favorite_border, 'Favorites', onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FavoritesScreen(),
                              ),
                            );
                          }),
                          _buildSettingRow(Icons.calendar_month, 'My Bookings'),
                          _buildSettingRow(Icons.settings, 'Settings'),
                          _buildSettingRow(Icons.logout, 'Logout',
                              onTap: () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                  ),
                  _buildProfileNavItem(
                    icon: Icons.location_on,
                    label: 'Tracking',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/tracking');
                    },
                  ),
                  _buildProfileNavItem(
                    icon: Icons.chat_bubble,
                    label: 'Chat',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildProfileNavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem({
    required String name,
    required String detail,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.pets,
            color: Color(0xFF9AA7B2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003D66),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7B8E9E),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  void _openManagePetsPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ManagePetsScreen()))
        .then((_) => setState(() {}));
  }

  

  Widget _buildSettingRow(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF003D66),
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF003D66),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9AA7B2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF0099CC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            )
          else
            Icon(
              icon,
              color: const Color(0xFF9AA7B2),
              size: 22,
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF003D66) : const Color(0xFF9AA7B2),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0099CC)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.12, size.height * 0.62);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.45,
      size.height * 0.75,
      size.width * 0.65,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.30,
      size.width * 0.85,
      size.height * 0.40,
      size.width * 0.88,
      size.height * 0.42,
    );

    const double dashLength = 10;
    const double dashGap = 10;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a small delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC8E6F5),
              Color(0xFFF0E8F8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003D66),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        const Text(
                          'Join PetTrust today',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A7C99),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Full Name Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 15,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 15,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 15,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0099CC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Or Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFDDDDDD),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFDDDDDD),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Google Button
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Apple Button
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.apple,
                                    size: 20,
                                    color: Color(0xFF333333),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Apple',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF666666),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0099CC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Caregiver Detail Screen
class CaregiverDetailScreen extends StatefulWidget {
  final Caregiver caregiver;

  const CaregiverDetailScreen({
    super.key,
    required this.caregiver,
  });

  @override
  State<CaregiverDetailScreen> createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _isFavorite = favoriteCaregivers.contains(widget.caregiver.name);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Profile Image
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: const Color(0xFFE8F4F8),
                    child: widget.caregiver.name == 'Sarah Johnson'
                        ? Image.asset(
                            'assets/Sarah_Johnson.jpg',
                            fit: BoxFit.cover,
                          )
                        : widget.caregiver.name == 'Marcus Williams'
                            ? Image.asset(
                                'assets/Marcus_Williams.jpg',
                                fit: BoxFit.cover,
                              )
                            : GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(
                                  9,
                                  (index) => Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[400],
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF003D66),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                          if (_isFavorite) {
                            favoriteCaregivers.add(widget.caregiver.name);
                          } else {
                            favoriteCaregivers.remove(widget.caregiver.name);
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : const Color(0xFF9AA7B2),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.caregiver.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8CC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFA500), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.caregiver.rating}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF003D66),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F3FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.caregiver.specialty,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0099CC),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.caregiver.experience} years exp.',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Location and Distance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF0099CC),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.caregiver.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003D66),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // About
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003D66),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.caregiver.about,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Services
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF003D66),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.caregiver.services
                              .map(
                                (service) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F3FF),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF0099CC),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    service,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0099CC),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Pricing
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hourly Rate',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${widget.caregiver.hourlyRate}/hr',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0099CC),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[200],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.caregiver.distance} km',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // Book Slot Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking slot with ${widget.caregiver.name}...'),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF0099CC),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0099CC),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Book a Slot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
