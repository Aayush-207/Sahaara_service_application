import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl,
    this.photoPath,
  });

  String name;
  String email;
  String password;
  String? photoUrl;
  String? photoPath;
}

UserProfile currentUserProfile = UserProfile(
  name: '',
  email: '',
  password: '',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// Google Sign-In Function
Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0099CC)),
        ),
      ),
    );

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // If user cancels the sign-in
    if (googleUser == null) {
      Navigator.of(context).pop(); // Close loading dialog
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    currentUserProfile = UserProfile(
      name: user?.displayName ?? 'User',
      email: user?.email ?? '',
      password: 'Google Sign-In',
      photoUrl: user?.photoURL,
    );

    Navigator.of(context).pop(); // Close loading dialog

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome ${userCredential.user?.displayName ?? "User"}!'),
        backgroundColor: const Color(0xFF0099CC),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to home screen
    Navigator.pushReplacementNamed(context, '/home');

    return userCredential;
  } catch (e) {
    // Close loading dialog if open
    Navigator.of(context, rootNavigator: true).pop();
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Sign-In failed: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    return null;
  }
}

// Location Service Functions
Future<void> requestLocationPermission(BuildContext context) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required to find nearby caregivers')),
          );
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showLocationPermissionDialog(context);
      }
      return;
    }
    
    // Get user's current location
    await getUserLocation();
  } catch (e) {
    debugPrint('Error requesting location: $e');
  }
}

Future<void> getUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    // Convert coordinates to address in English
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      localeIdentifier: 'en_US',
    );
    
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      userLocation = '${place.locality}, ${place.administrativeArea}';
      debugPrint('Updated location: $userLocation');
    }
  } catch (e) {
    debugPrint('Error getting location: $e');
  }
}

void _showLocationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'This app needs location access to find caregivers near you. Please enable location permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    },
  );
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
        '/book-date-time': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final caregiver = args?['caregiver'] as Caregiver?;
          return caregiver != null ? BookDateTimeScreen(caregiver: caregiver) : const HomeScreen();
        },
        '/booking-confirmation': (context) {
          final booking = ModalRoute.of(context)?.settings.arguments as Booking?;
          return booking != null ? BookingConfirmationScreen(booking: booking) : const HomeScreen();
        },
        '/booking-history': (context) => const BookingHistoryScreen(),
        '/all-caregivers': (context) => const AllCaregiversScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

// Book Date & Time Screen
class BookDateTimeScreen extends StatefulWidget {
  final Caregiver caregiver;

  const BookDateTimeScreen({super.key, required this.caregiver});

  @override
  State<BookDateTimeScreen> createState() => _BookDateTimeScreenState();
}

class _BookDateTimeScreenState extends State<BookDateTimeScreen> {
  late DateTime selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String selectedDuration = '1 hour';
  late TextEditingController petNameController;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().add(const Duration(days: 1));
    petNameController = TextEditingController();
    petNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    petNameController.dispose();
    super.dispose();
  }

  double calculatePrice() {
    int durationValue = int.parse(selectedDuration.split(' ')[0]);
    return widget.caregiver.hourlyRate * durationValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF003D66), size: 24),
        ),
        title: const Text(
          'Book a Session',
          style: TextStyle(
            color: Color(0xFF003D66),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caregiver Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0099CC), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: AssetImage(_getCaregiverImage(widget.caregiver.name)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.caregiver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003D66),
                        ),
                      ),
                      Text(
                        '${widget.caregiver.hourlyRate}\$/hour',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0099CC),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pet Name Input
            const Text(
              'Pet Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003D66),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: petNameController,
              decoration: InputDecoration(
                hintText: 'Enter your pet\'s name',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003D66),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0099CC),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF003D66),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003D66),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF0099CC), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Selection
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003D66),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0099CC),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF003D66),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003D66),
                      ),
                    ),
                    const Icon(Icons.access_time, color: Color(0xFF0099CC), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Duration Selection
            const Text(
              'Session Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003D66),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['1 hour', '2 hours', '3 hours', '4 hours', '6 hours']
                  .map((duration) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDuration = duration;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedDuration == duration
                              ? const Color(0xFF0099CC)
                              : Colors.white,
                          border: Border.all(
                            color: selectedDuration == duration
                                ? const Color(0xFF0099CC)
                                : const Color(0xFFE0E0E0),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selectedDuration == duration
                                ? Colors.white
                                : const Color(0xFF003D66),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003D66),
                    ),
                  ),
                  Text(
                    '\$${calculatePrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0099CC),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: petNameController.text.isEmpty
                    ? null
                    : () {
                        final booking = Booking(
                          id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
                          caregiverName: widget.caregiver.name,
                          caregiverImage: _getCaregiverImage(widget.caregiver.name),
                          petName: petNameController.text,
                          bookingDate: selectedDate,
                          bookingTime: selectedTime,
                          duration: int.parse(selectedDuration.split(' ')[0]),
                          totalPrice: calculatePrice(),
                          createdAt: DateTime.now(),
                        );
                        Navigator.pushNamed(
                          context,
                          '/booking-confirmation',
                          arguments: booking,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0099CC),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Confirmation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getCaregiverImage(String caregiverName) {
    final imageMap = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };
    return imageMap[caregiverName] ?? 'assets/Sarah_Johnson.jpg';
  }
}

// Booking Confirmation Screen
class BookingConfirmationScreen extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        body: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Checkmark Animation
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0099CC),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0099CC).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Booking Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF003D66),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your session with ${widget.booking.caregiverName} is confirmed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Booking Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Caregiver Info
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                image: DecorationImage(
                                  image: AssetImage(widget.booking.caregiverImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.booking.caregiverName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF003D66),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Booking ID: ${widget.booking.id.substring(0, 10)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE0E0E0), height: 1),
                        const SizedBox(height: 20),

                        // Booking Details
                        _buildDetailRow('Pet Name', widget.booking.petName),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Date',
                          '${widget.booking.bookingDate.day}/${widget.booking.bookingDate.month}/${widget.booking.bookingDate.year}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Time',
                          '${widget.booking.bookingTime.hour.toString().padLeft(2, '0')}:${widget.booking.bookingTime.minute.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Duration',
                          '${widget.booking.duration} hour${widget.booking.duration > 1 ? 's' : ''}',
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE0E0E0), height: 1),
                        const SizedBox(height: 20),

                        // Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003D66),
                              ),
                            ),
                            Text(
                              '\$${widget.booking.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0099CC),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        userBookings.add(widget.booking);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Booking confirmed! Check your booking history.'),
                            backgroundColor: const Color(0xFF0099CC),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0099CC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/booking-history');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0099CC), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Booking History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0099CC),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003D66),
          ),
        ),
      ],
    );
  }
}

// Booking History Screen
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final List<String> cancellationReasons = [
    'Change of plans',
    'Found another caregiver',
    'Schedule conflict',
    'Pet became unavailable',
    'Too expensive',
    'Other reason',
  ];

  void _showCancellationDialog(Booking booking, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReasonDialog(booking, index);
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReasonDialog(Booking booking, int index) {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cancellation Reason'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please select a reason for cancellation:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...cancellationReasons.map(
                      (reason) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedReason = reason;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedReason == reason
                                ? const Color(0xFFE0F3FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedReason == reason
                                  ? const Color(0xFF0099CC)
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedReason == reason
                                        ? const Color(0xFF0099CC)
                                        : const Color(0xFFCCCCCC),
                                  ),
                                ),
                                child: selectedReason == reason
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Color(0xFF0099CC),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF003D66),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: selectedReason != null
                      ? () {
                          setState(() {
                            booking.status = 'cancelled';
                            booking.cancellationReason = selectedReason;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking cancelled successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Confirm Cancellation',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF003D66), size: 24),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Color(0xFF003D66),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFF5F9FB),
      body: userBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: const Color(0xFF0099CC).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Bookings Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF003D66),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book a caregiver to get started',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0099CC),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Find a Caregiver',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userBookings.length,
              itemBuilder: (context, index) {
                final booking = userBookings[index];
                final isUpcoming = booking.isUpcoming;
                final isCancelled = booking.isCancelled;

                // Status color based on booking status
                Color statusColor = isCancelled
                    ? Colors.red
                    : isUpcoming
                        ? const Color(0xFF0099CC)
                        : Colors.green;
                Color statusBgColor = isCancelled
                    ? const Color(0xFFFFEBEE)
                    : isUpcoming
                        ? const Color(0xFFE0F3FF)
                        : const Color(0xFFE8F5E9);
                String statusText = isCancelled
                    ? 'Cancelled'
                    : isUpcoming
                        ? 'Upcoming'
                        : 'Completed';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with Status
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: AssetImage(booking.caregiverImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking.caregiverName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF003D66),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pet: ${booking.petName}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor, width: 1),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      // Booking Details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and Time
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: const Color(0xFF0099CC),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} at ${booking.bookingTime.hour.toString().padLeft(2, '0')}:${booking.bookingTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003D66),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Duration and Price
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: const Color(0xFF0099CC),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Duration: ${booking.duration} hours',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF003D66),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0099CC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Cancellation Reason (if cancelled)
                            if (isCancelled && booking.cancellationReason != null) ...
[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Cancelled: ${booking.cancellationReason}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Cancel Button (only for upcoming bookings)
                      if (isUpcoming && !isCancelled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showCancellationDialog(booking, index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Cancel Booking',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// All Caregivers Screen with Filters and Sorting
class AllCaregiversScreen extends StatefulWidget {
  const AllCaregiversScreen({super.key});

  @override
  State<AllCaregiversScreen> createState() => _AllCaregiversScreenState();
}

class _AllCaregiversScreenState extends State<AllCaregiversScreen> {
  String selectedSpecialty = 'All';
  String selectedSort = 'Rating';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> specialties = ['All', 'Walking', 'Grooming', 'Sitting', 'Vet', 'Training'];
  final List<String> sortOptions = ['Rating', 'Price (Low to High)', 'Price (High to Low)', 'Distance', 'Experience'];

  List<Caregiver> get filteredAndSortedCaregivers {
    // Filter by specialty
    List<Caregiver> filtered = selectedSpecialty == 'All'
        ? List.from(nearbyCaregivers)
        : nearbyCaregivers.where((c) => c.specialty == selectedSpecialty).toList();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.specialty.toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.services.any((s) => s.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }

    // Sort
    switch (selectedSort) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price (Low to High)':
        filtered.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'Price (High to Low)':
        filtered.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
        break;
      case 'Distance':
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Experience':
        filtered.sort((a, b) => b.experience.compareTo(a.experience));
        break;
    }

    return filtered;
  }

  String _getImageForCaregiver(String name) {
    final Map<String, String> caregiverImages = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };
    return caregiverImages[name] ?? 'assets/Sarah_Johnson.jpg';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caregivers = filteredAndSortedCaregivers;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0099CC),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
        title: const Text(
          'All Caregivers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Sort Header
          Container(
            color: const Color(0xFF0099CC),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search caregivers...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF0099CC),
                        size: 22,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  searchQuery = '';
                                });
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Color(0xFF999999),
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort,
                        color: Color(0xFF0099CC),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sort by:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003D66),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedSort,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0099CC)),
                          items: sortOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSort = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: specialties.length,
                itemBuilder: (context, index) {
                  final specialty = specialties[index];
                  final isSelected = selectedSpecialty == specialty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSpecialty = specialty;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0099CC) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0099CC) : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            specialty,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${caregivers.length} Caregiver${caregivers.length != 1 ? 's' : ''} Found',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003D66),
                  ),
                ),
              ],
            ),
          ),
          // Caregivers Grid
          Expanded(
            child: caregivers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: const Color(0xFF0099CC).withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No caregivers found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: caregivers.length,
                    itemBuilder: (context, index) {
                      final caregiver = caregivers[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
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
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(_getImageForCaregiver(caregiver.name)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
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
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF003D66),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (favoriteCaregivers.contains(caregiver.name)) {
                                              favoriteCaregivers.remove(caregiver.name);
                                            } else {
                                              favoriteCaregivers.add(caregiver.name);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            favoriteCaregivers.contains(caregiver.name)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: favoriteCaregivers.contains(caregiver.name)
                                                ? Colors.red
                                                : const Color(0xFF999999),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        caregiver.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF003D66),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F3FF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          caregiver.specialty,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0099CC),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Color(0xFF999999),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${caregiver.distance} km',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${caregiver.hourlyRate}/hr',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0099CC),
                                            ),
                                          ),
                                          Text(
                                            '${caregiver.experience}y exp',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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

  Widget _getImageForCaregiver(String name, bool isGridView) {
    final Map<String, String> caregiverImages = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };

    if (caregiverImages.containsKey(name)) {
      return Image.asset(
        caregiverImages[name]!,
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: const Color(0xFFE8F4F8),
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
      ),
    );
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

    final email = _emailController.text.trim();
    final nameFromEmail = email.contains('@')
      ? email.split('@').first
      : 'User';
    final resolvedName =
      currentUserProfile.email == email && currentUserProfile.name.isNotEmpty
        ? currentUserProfile.name
        : nameFromEmail;
    currentUserProfile = UserProfile(
      name: resolvedName,
      email: email,
      password: _passwordController.text,
      photoUrl: currentUserProfile.photoUrl,
      photoPath: currentUserProfile.photoPath,
    );

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
                              onPressed: () => signInWithGoogle(context),
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
class Review {
  final String reviewerName;
  final double rating;
  final String reviewText;
  final String petType;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.reviewText,
    required this.petType,
  });
}

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
  final List<Review> reviews;

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
    required this.reviews,
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

class Booking {
  final String id;
  final String caregiverName;
  final String caregiverImage;
  final String petName;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  final int duration; // in hours
  final double totalPrice;
  final DateTime createdAt;
  String status; // 'upcoming', 'completed', or 'cancelled'
  String? cancellationReason;

  Booking({
    required this.id,
    required this.caregiverName,
    required this.caregiverImage,
    required this.petName,
    required this.bookingDate,
    required this.bookingTime,
    required this.duration,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'upcoming',
    this.cancellationReason,
  });
  
  bool get isUpcoming => bookingDate.isAfter(DateTime.now()) && status == 'upcoming';
  bool get isCancelled => status == 'cancelled';
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

final List<Booking> userBookings = [
  Booking(
    id: 'B001',
    caregiverName: 'Emily Davis',
    caregiverImage: '4',
    petName: 'Max',
    bookingDate: DateTime.now().subtract(const Duration(days: 3)),
    bookingTime: const TimeOfDay(hour: 10, minute: 0),
    duration: 3,
    totalPrice: 105.0,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    status: 'completed',
  ),
  Booking(
    id: 'B002',
    caregiverName: 'Michael Brown',
    caregiverImage: '3',
    petName: 'Luna',
    bookingDate: DateTime.now().subtract(const Duration(days: 7)),
    bookingTime: const TimeOfDay(hour: 14, minute: 30),
    duration: 2,
    totalPrice: 60.0,
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
    status: 'completed',
  ),
  Booking(
    id: 'B003',
    caregiverName: 'Sarah Johnson',
    caregiverImage: '1',
    petName: 'Buddy',
    bookingDate: DateTime.now().subtract(const Duration(days: 14)),
    bookingTime: const TimeOfDay(hour: 9, minute: 0),
    duration: 4,
    totalPrice: 100.0,
    createdAt: DateTime.now().subtract(const Duration(days: 16)),
    status: 'completed',
  ),
];

String userLocation = 'San Francisco, CA';

final List<Caregiver> nearbyCaregivers = [
  Caregiver(
    name: 'Sarah Johnson',
    rating: 4.9,
    distance: 0.8,
    hourlyRate: 25,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Downtown, 2km away',
    services: ['Dog Walking', 'Pet Sitting', 'Dog Training', 'Leash Training', 'Puppy Care', 'Photo Updates'],
    about: 'Professional pet care specialist with 5+ years of experience. Sarah loves all dogs and provides personalized care with daily updates.',
    experience: 5,
    reviews: [
      Review(
        reviewerName: 'John Smith',
        rating: 5.0,
        reviewText: 'Sarah is amazing! Max loves her and always comes back happy and tired. Highly recommended!',
        petType: 'Golden Retriever',
      ),
      Review(
        reviewerName: 'Emily Davis',
        rating: 4.8,
        reviewText: 'Very professional and caring. She sends photos during walks which is great peace of mind.',
        petType: 'Labrador',
      ),
      Review(
        reviewerName: 'Michael Brown',
        rating: 5.0,
        reviewText: 'Best dog walker in town. My pup looks forward to walking with Sarah every day!',
        petType: 'Beagle',
      ),
      Review(
        reviewerName: 'Sarah Williams',
        rating: 4.7,
        reviewText: 'Great service and very attentive to my dogs needs. Reliable and trustworthy.',
        petType: 'Golden Retriever',
      ),
    ],
  ),
  Caregiver(
    name: 'Marcus Williams',
    rating: 4.8,
    distance: 1.2,
    hourlyRate: 22,
    specialty: 'Grooming',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Midtown, 1.2km away',
    services: ['Grooming', 'Dog Bathing', 'Nail Trimming', 'Fur Styling', 'Flea Treatment', 'Ear Cleaning'],
    about: 'Expert groomer with certified training. Marcus specializes in all dog breeds and ensures your pet looks their best.',
    experience: 7,
    reviews: [
      Review(
        reviewerName: 'Lisa Anderson',
        rating: 5.0,
        reviewText: 'Marcus groomed my poodle beautifully! Very skilled and gentle with the animals.',
        petType: 'Poodle',
      ),
      Review(
        reviewerName: 'Robert Johnson',
        rating: 4.8,
        reviewText: 'Professional groomer. My dog looks amazing after each session. Definitely worth the price.',
        petType: 'German Shepherd',
      ),
      Review(
        reviewerName: 'Maria Garcia',
        rating: 4.7,
        reviewText: 'Very clean grooming salon and Marcus takes care of anxious dogs very well.',
        petType: 'Shy Terrier',
      ),
    ],
  ),
  Caregiver(
    name: 'Emma Rodriguez',
    rating: 4.95,
    distance: 0.5,
    hourlyRate: 28,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Riverside, 500m away',
    services: ['Pet Sitting', 'Dog Walking', 'Overnight Care', 'Feeding', 'Medication', 'Playtime'],
    about: 'Compassionate pet sitter who treats every pet like family. Emma offers flexible scheduling and daily photo updates.',
    experience: 6,
    reviews: [
      Review(
        reviewerName: 'James Taylor',
        rating: 5.0,
        reviewText: 'Emma stayed with our dog for a week while we traveled. She was wonderful and we felt completely at ease.',
        petType: 'Boxer Mix',
      ),
      Review(
        reviewerName: 'Patricia Miller',
        rating: 5.0,
        reviewText: 'The best pet sitter ever! She gives daily updates and my dog adores her. Worth every penny.',
        petType: 'Cocker Spaniel',
      ),
      Review(
        reviewerName: 'David Wilson',
        rating: 4.9,
        reviewText: 'Reliable, caring, and professional. Emma takes excellent care of our pets when we\'re away.',
        petType: 'Dachshund',
      ),
      Review(
        reviewerName: 'Jennifer Martinez',
        rating: 4.9,
        reviewText: 'Emma is trustworthy and loving. Our senior dog is always happy in her care.',
        petType: 'Senior Pug',
      ),
    ],
  ),
  Caregiver(
    name: 'David Chen',
    rating: 4.7,
    distance: 1.5,
    hourlyRate: 26,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Westside, 1.5km away',
    services: ['Dog Walking', 'Group Walks', 'Exercise Training', 'Park Time', 'Agility Work', 'Fitness'],
    about: 'Athletic and energetic dog walker. David specializes in high-energy dogs and provides structured exercise routines.',
    experience: 4,
    reviews: [
      Review(
        reviewerName: 'Christopher Lee',
        rating: 4.8,
        reviewText: 'Perfect for my hyper dog! David provides structured exercise and my dog sleeps well at night.',
        petType: 'German Shepherd',
      ),
      Review(
        reviewerName: 'Amanda Clark',
        rating: 4.7,
        reviewText: 'Great for active dogs. David really knows how to tire them out safely.',
        petType: 'Husky Mix',
      ),
      Review(
        reviewerName: 'Kevin Robinson',
        rating: 4.7,
        reviewText: 'David is energetic and fun. My border collie loves the activity he provides.',
        petType: 'Border Collie',
      ),
      Review(
        reviewerName: 'Rachel Green',
        rating: 4.6,
        reviewText: 'Good walker but sometimes runs a bit late. Still very good overall.',
        petType: 'Labrador',
      ),
    ],
  ),
  Caregiver(
    name: 'Olivia Martinez',
    rating: 4.85,
    distance: 0.9,
    hourlyRate: 26,
    specialty: 'Vet',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Healthcare District, 900m away',
    services: ['Medical Care', 'Health Monitoring', 'Medication', 'Vaccination', 'Wound Care', 'Health Coaching'],
    about: 'Licensed veterinary technician with extensive medical knowledge. Olivia provides professional health monitoring and care.',
    experience: 8,
    reviews: [
      Review(
        reviewerName: 'Thomas Anderson',
        rating: 5.0,
        reviewText: 'Olivia helped with my dogs rehabilitation after surgery. Very knowledgeable and caring.',
        petType: 'Post-Surgery Care',
      ),
      Review(
        reviewerName: 'Barbara Thompson',
        rating: 4.9,
        reviewText: 'Professional veterinary technician. She managed my dogs medication schedule perfectly.',
        petType: 'Senior Dog',
      ),
      Review(
        reviewerName: 'Daniel White',
        rating: 4.8,
        reviewText: 'Excellent health monitoring. I felt confident leaving my sick dog in her care.',
        petType: 'Diabetic Dog',
      ),
      Review(
        reviewerName: 'Jessica Harris',
        rating: 4.7,
        reviewText: 'Very professional and compassionate. Olivia made my anxious dog feel safe.',
        petType: 'Anxious Chihuahua',
      ),
    ],
  ),
  Caregiver(
    name: 'James Murphy',
    rating: 4.6,
    distance: 1.8,
    hourlyRate: 20,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Eastside, 1.8km away',
    services: ['Dog Walking', 'Basic Training', 'Socialization', 'Pickup/Dropoff', 'Rest Time', 'Cleaning'],
    about: 'Friendly dog walker with a passion for helping dogs socialize. James creates a safe and fun environment for all pets.',
    experience: 3,
    reviews: [
      Review(
        reviewerName: 'Matthew Thompson',
        rating: 4.6,
        reviewText: 'James is friendly and my dog enjoys his company. Good with young dogs.',
        petType: 'Labrador Puppy',
      ),
      Review(
        reviewerName: 'Nicole Adams',
        rating: 4.5,
        reviewText: 'Good walker, very affordable. My shy dog opened up after a few sessions with James.',
        petType: 'Shy Cocker Spaniel',
      ),
      Review(
        reviewerName: 'Brandon Clark',
        rating: 4.7,
        reviewText: 'Great with dogs! James helped my pup socialize with other dogs at the park.',
        petType: 'Mixed Breed',
      ),
    ],
  ),
  Caregiver(
    name: 'Sophie Bennett',
    rating: 4.9,
    distance: 0.7,
    hourlyRate: 27,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Park View, 700m away',
    services: ['Pet Sitting', 'Dog Walking', 'Playdate Coordination', 'Anxiety Support', 'Home Sitting', 'Adventure Time'],
    about: 'Experienced pet sitter with a special touch for anxious pets. Sophie creates calm environments and provides constant care.',
    experience: 6,
    reviews: [
      Review(
        reviewerName: 'Sandra Lopez',
        rating: 5.0,
        reviewText: 'Sophie is wonderful with anxious dogs! She helped my rescue puppy feel safe and confident.',
        petType: 'Rescue Puppy',
      ),
      Review(
        reviewerName: 'Gregory Brown',
        rating: 4.9,
        reviewText: 'Amazing sitter. She organized playdates for my dog and it really helped with their socialization.',
        petType: 'French Bulldog',
      ),
      Review(
        reviewerName: 'Rebecca Johnson',
        rating: 4.8,
        reviewText: 'Very caring and attentive. Sophie goes above and beyond for her clients.',
        petType: 'Cavalier King Charles',
      ),
      Review(
        reviewerName: 'Steven Martinez',
        rating: 4.9,
        reviewText: 'Best adventure sitter ever! My dog loves the trips Sophie takes her on.',
        petType: 'Australian Shepherd',
      ),
    ],
  ),
  Caregiver(
    name: 'Michael Torres',
    rating: 4.75,
    distance: 1.3,
    hourlyRate: 24,
    specialty: 'Grooming',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Commerce Ave, 1.3km away',
    services: ['Full Grooming', 'Spa Treatments', 'Show Prep', 'De-matting', 'Color Treatment', 'Breed Styling'],
    about: 'Professional groomer with show experience. Michael provides premium grooming services tailored to each dog\'s needs.',
    experience: 9,
    reviews: [
      Review(
        reviewerName: 'Angela White',
        rating: 4.8,
        reviewText: 'Michael showed my Poodle for a local competition and did an excellent job with styling.',
        petType: 'Show Poodle',
      ),
      Review(
        reviewerName: 'Mark Harris',
        rating: 4.7,
        reviewText: 'Great groomer with lots of experience. My dog looks premium after each session.',
        petType: 'Maltese',
      ),
      Review(
        reviewerName: 'Karen Peterson',
        rating: 4.8,
        reviewText: 'Professional and skilled. Michael noticed my dogs skin issue and suggested I see a vet.',
        petType: 'Pomeranian',
      ),
    ],
  ),
  Caregiver(
    name: 'Lisa Anderson',
    rating: 4.8,
    distance: 1.1,
    hourlyRate: 25,
    specialty: 'Training',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Learning Center, 1.1km away',
    services: ['Obedience Training', 'Behavior Correction', 'Puppy Training', 'Aggression Training', 'Anxiety Therapy', 'Commands'],
    about: 'Certified dog trainer specializing in positive reinforcement. Lisa helps dogs learn good behavior in a fun way.',
    experience: 11,
    reviews: [
      Review(
        reviewerName: 'Edward Johnson',
        rating: 4.9,
        reviewText: 'Lisa helped my stubborn dog learn obedience. She\'s patient, professional, and results-oriented.',
        petType: 'Stubborn Terrier',
      ),
      Review(
        reviewerName: 'Susan Miller',
        rating: 4.8,
        reviewText: 'Transformed my aggressive rescue dog. Lisa\'s positive reinforcement approach really works.',
        petType: 'Aggressive Rescue',
      ),
      Review(
        reviewerName: 'Patrick Davis',
        rating: 4.8,
        reviewText: 'Excellent trainer! Lisa taught my puppy good behaviors from the start using humane methods.',
        petType: 'Puppy',
      ),
      Review(
        reviewerName: 'Helen Garcia',
        rating: 4.7,
        reviewText: 'Helped my dog overcome anxiety in new situations. Very knowledgeable and compassionate.',
        petType: 'Anxious Greyhound',
      ),
    ],
  ),
  Caregiver(
    name: 'Carlos Rodriguez',
    rating: 4.65,
    distance: 2.0,
    hourlyRate: 23,
    specialty: 'Walking',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Northgate, 2km away',
    services: ['Dog Walking', 'Adventure Hikes', 'Beach Trips', 'Trail Walks', 'Water Play', 'Outdoor Training'],
    about: 'Adventure-loving dog walker who enjoys outdoor activities. Carlos takes dogs on exciting outings and nature walks.',
    experience: 5,
    reviews: [
      Review(
        reviewerName: 'Frank Williams',
        rating: 4.7,
        reviewText: 'Carlos takes my dog on amazing hiking adventures. Perfect for active pups!',
        petType: 'Golden Retriever',
      ),
      Review(
        reviewerName: 'Michelle Lopez',
        rating: 4.6,
        reviewText: 'Great outdoor walker. My beach-loving dog gets plenty of water play time with Carlos.',
        petType: 'Labrador Mix',
      ),
      Review(
        reviewerName: 'Richard Turner',
        rating: 4.6,
        reviewText: 'Good walker for adventurous dogs. Carlos is knowledgeable about outdoor safety.',
        petType: 'Jack Russell Terrier',
      ),
    ],
  ),
  Caregiver(
    name: 'Rachel White',
    rating: 4.92,
    distance: 0.6,
    hourlyRate: 29,
    specialty: 'Sitting',
    profileImages: ['1', '2', '3', '4', '5', '6'],
    location: 'Central Heights, 600m away',
    services: ['Overnight Sitting', 'Busy Day Care', 'Special Needs Care', 'Senior Dog Care', 'Post-Surgery Care', 'End-of-Life Care'],
    about: 'Premium pet care specialist. Rachel excels at caring for senior pets and dogs with special needs.',
    experience: 10,
    reviews: [
      Review(
        reviewerName: 'Dorothy Nelson',
        rating: 5.0,
        reviewText: 'Rachel cared for my senior dog with such compassion and professionalism during his final months. Truly grateful.',
        petType: 'Senior Labrador',
      ),
      Review(
        reviewerName: 'Joseph Hall',
        rating: 4.9,
        reviewText: 'Excellent special needs caregiver. My dog with mobility issues felt safe and comfortable with Rachel.',
        petType: 'Senior Mobility Needs',
      ),
      Review(
        reviewerName: 'Margaret Scott',
        rating: 4.9,
        reviewText: 'Rachel provided overnight care after my dogs surgery. She monitored him carefully and was very attentive.',
        petType: 'Post-Surgery Dog',
      ),
      Review(
        reviewerName: 'Ronald Green',
        rating: 4.9,
        reviewText: 'Premium service for premium care. Rachel goes above and beyond what normal sitters provide.',
        petType: 'Special Needs Dog',
      ),
    ],
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
    reviews: [],
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
    reviews: [],
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
    reviews: [],
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
    reviews: [],
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
  final int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Walking', 'Grooming', 'Sitting', 'Vet'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    
    // Try to get user location when home screen loads
    getUserLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        currentUserProfile.name.isNotEmpty ? currentUserProfile.name : 'Guest';
    final displayEmail =
        currentUserProfile.email.isNotEmpty ? currentUserProfile.email : 'No email';

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
                            Text(
                              'Good Morning, $displayName',
                              style: const TextStyle(
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
                                Text(
                                  userLocation,
                                  style: const TextStyle(
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
                              onTap: () {
                                Navigator.pushNamed(context, '/all-caregivers');
                              },
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
                        // Caregivers Horizontal Carousel - Shows 2 cards with smooth scrolling
                        SizedBox(
                          height: 320,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: nearbyCaregivers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: 16,
                                  left: index == 0 ? 0 : 0,
                                ),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 - 28,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.7, end: 1).animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          0.5 + (index * 0.05),
                                          0.8 + (index * 0.05),
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
                                  ),
                                ),
                              );
                            },
                          ),
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

  // Helper method to get the correct image for a caregiver
  Widget _getImageForCaregiver(String name, bool isGridView) {
    final Map<String, String> caregiverImages = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };

    if (caregiverImages.containsKey(name)) {
      return Image.asset(
        caregiverImages[name]!,
        fit: BoxFit.cover,
      );
    }

    // Fallback grid view
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isGridView ? 3 : 2,
      ),
      itemCount: isGridView ? 6 : 4,
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
              size: isGridView ? null : 16,
            ),
          ),
        );
      },
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
                      child: _getImageForCaregiver(caregiver.name, isGridView),
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
                    child: _getImageForCaregiver(caregiver.name, false),
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
    final displayName =
        currentUserProfile.name.isNotEmpty ? currentUserProfile.name : 'Guest';
    final displayEmail = currentUserProfile.email.isNotEmpty
        ? currentUserProfile.email
        : 'No email';

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

  Widget _getImageForCaregiver(String name, bool isGridView) {
    final Map<String, String> caregiverImages = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };

    if (caregiverImages.containsKey(name)) {
      return Image.asset(
        caregiverImages[name]!,
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: const Color(0xFFE8F4F8),
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
      ),
    );
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
                                  child: _getImageForCaregiver(caregiver.name, false),
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

  Widget _buildProfileAvatar() {
    if (currentUserProfile.photoPath != null &&
        currentUserProfile.photoPath!.isNotEmpty) {
      return Image.file(
        File(currentUserProfile.photoPath!),
        fit: BoxFit.cover,
      );
    }

    if (currentUserProfile.photoUrl != null &&
        currentUserProfile.photoUrl!.isNotEmpty) {
      return Image.network(
        currentUserProfile.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            color: Colors.grey[400],
            size: 28,
          );
        },
      );
    }

    return Icon(
      Icons.person,
      color: Colors.grey[400],
      size: 28,
    );
  }

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
    final displayName =
        currentUserProfile.name.isNotEmpty ? currentUserProfile.name : 'Guest';
    final displayEmail = currentUserProfile.email.isNotEmpty
        ? currentUserProfile.email
        : 'No email';

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
                            child: _buildProfileAvatar(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: const TextStyle(
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
                          _buildSettingRow(Icons.calendar_month, 'My Bookings', onTap: () {
                            Navigator.of(context).pushNamed('/booking-history');
                          }),
                          _buildSettingRow(Icons.edit, 'Edit Profile', onTap: () {
                            Navigator.of(context).pushNamed('/edit-profile');
                          }),
                          _buildSettingRow(Icons.logout, 'Logout', onTap: () async {
                            currentUserProfile = UserProfile(
                              name: '',
                              email: '',
                              password: '',
                            );
                            await FirebaseAuth.instance.signOut();
                            await GoogleSignIn().signOut();
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
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

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName =
        currentUserProfile.name.isNotEmpty ? currentUserProfile.name : 'Guest';
    final displayEmail =
        currentUserProfile.email.isNotEmpty ? currentUserProfile.email : 'No email';
    final displayPassword = currentUserProfile.password.isNotEmpty
        ? currentUserProfile.password
        : 'Not available';

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
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003D66),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
                'Account Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003D66),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileField('Name', displayName),
              const SizedBox(height: 12),
              _buildProfileField('Email', displayEmail),
              const SizedBox(height: 12),
              _buildProfileField('Password', displayPassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B8E9E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003D66),
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

    // Store user profile data
    currentUserProfile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      // Request location permission and get user's location
      await requestLocationPermission(context);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
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
                              onPressed: () => signInWithGoogle(context),
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

  // Helper to get correct image for detail screen
  Widget _getCaregiverDetailImage(String name) {
    final Map<String, String> caregiverImages = {
      'Sarah Johnson': 'assets/Sarah_Johnson.jpg',
      'Marcus Williams': 'assets/Marcus_Williams.jpg',
      'Emma Rodriguez': 'assets/Emma_rodriguez.png',
      'David Chen': 'assets/David_chen.jpg',
      'Olivia Martinez': 'assets/olivia_martinez.jpg',
      'James Murphy': 'assets/james_murphy.jpg',
      'Sophie Bennett': 'assets/sophie_bennett.jpg',
      'Michael Torres': 'assets/michael_torres.jpg',
      'Lisa Anderson': 'assets/lisa_anderson.jpg',
      'Carlos Rodriguez': 'assets/Carlos_rodriguez.jpg',
      'Rachel White': 'assets/rachel_white.jpg',
    };

    if (caregiverImages.containsKey(name)) {
      return Image.asset(
        caregiverImages[name]!,
        fit: BoxFit.cover,
      );
    }

    // Fallback grid
    return GridView.count(
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
    );
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
                    child: _getCaregiverDetailImage(widget.caregiver.name),
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
                  // Reviews Section
                  if (widget.caregiver.reviews.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF003D66),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8CC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFFA500), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.caregiver.rating}',
                                      style: const TextStyle(
                                        fontSize: 12,
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.caregiver.reviews.length,
                            itemBuilder: (context, index) {
                              final review = widget.caregiver.reviews[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reviewer Info
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.reviewerName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF003D66),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Pet: ${review.petType}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF999999),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE8CC),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Color(0xFFFFA500),
                                                size: 12,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${review.rating}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF003D66),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Review Text
                                    Text(
                                      review.reviewText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF666666),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
            Navigator.pushNamed(
              context,
              '/book-date-time',
              arguments: {'caregiver': widget.caregiver},
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
