import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/service_package_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';

/// Booking Confirmation Screen
/// 
/// Final step in the booking flow where users review and confirm their booking:
/// - Booking summary (service, package, duration, caregiver, price)
/// - Date and time selection with pickers
/// - Additional notes/instructions field
/// - Confirm booking button with loading state
/// - Success dialog with navigation to home
/// 
/// Design Principles:
/// - Solid colors only (Navy, Orange, Sky Blue, Light Blue)
/// - 8px grid spacing system
/// - Montserrat font family
/// - Clean card-based layout
/// - Professional information hierarchy
/// - Clear call-to-action
/// 
/// Theme Colors:
/// - Background: AppColors.surface (white)
/// - Cards: White with AppColors.border
/// - Primary button: AppColors.primary (navy)
/// - Price: AppColors.secondary (orange)
/// - Success: AppColors.success (green)
class BookingConfirmationScreen extends StatefulWidget {
  final String serviceType;
  final ServicePackageModel selectedPackage;
  final UserModel selectedCaregiver;

  const BookingConfirmationScreen({
    super.key,
    required this.serviceType,
    required this.selectedPackage,
    required this.selectedCaregiver,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  PetModel? _selectedDog;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _loadDogs();
  }

  /// Load user's dogs (only if not already loaded)
  void _loadDogs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && petProvider.pets.isEmpty && !petProvider.isLoading) {
      petProvider.loadUserPets(authProvider.currentUser!.uid);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATE/TIME SELECTION
  // ============================================================================

  /// Shows date picker dialog
  Future<void> _selectDate() async {
    _soundService.playTap();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Shows time picker dialog
  Future<void> _selectTime() async {
    _soundService.playTap();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ============================================================================
  // BOOKING CONFIRMATION
  // ============================================================================

  /// Confirms the booking and creates it in Firestore
  Future<void> _confirmBooking() async {
    _soundService.playClick();
    
    // Validate dog selection
    if (_selectedDog == null) {
      _soundService.playError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a dog for this booking'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _soundService.playError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final booking = BookingModel(
        id: '',
        ownerId: currentUser.uid,
        caregiverId: widget.selectedCaregiver.uid,
        petId: _selectedDog!.id,
        serviceType: widget.serviceType,
        packageName: widget.selectedPackage.packageName,
        scheduledDate: scheduledDateTime,
        duration: widget.selectedPackage.duration,
        price: widget.selectedPackage.price,
        status: 'pending',
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createBooking(booking);

      if (!mounted) return;

      _soundService.playSuccess();
      _showSuccessDialog();
    } catch (e) {
      _soundService.playError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows success dialog after booking confirmation
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your booking with ${widget.selectedCaregiver.name} has been confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Montserrat',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _soundService.playClick();
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildDogSelectionSection(),
                    const SizedBox(height: 24),
                    _buildDateTimeSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - SUMMARY CARD
  // ============================================================================

  /// Builds the booking summary card
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Service', widget.serviceType),
          const SizedBox(height: 12),
          _buildSummaryRow('Package', widget.selectedPackage.packageName),
          const SizedBox(height: 12),
          _buildSummaryRow('Duration', widget.selectedPackage.duration),
          const SizedBox(height: 12),
          _buildSummaryRow('Caregiver', widget.selectedCaregiver.name),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Rating',
            '${widget.selectedCaregiver.rating?.toStringAsFixed(1) ?? '0.0'} ⭐',
          ),
          const Divider(height: 32, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${widget.selectedPackage.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single summary row
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - DOG SELECTION SECTION
  // ============================================================================

  /// Builds the dog selection section
  Widget _buildDogSelectionSection() {
    final petProvider = Provider.of<PetProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Dog',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (petProvider.isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (petProvider.pets.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pets_rounded,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No dogs added yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please add a dog before booking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _soundService.playTap();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Dog',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: petProvider.pets.map((dog) {
              final isSelected = _selectedDog?.id == dog.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    _soundService.playTap();
                    setState(() {
                      _selectedDog = dog;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.tertiary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dog.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dog.breed} • ${dog.age} years • ${dog.weight} kg',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - DATE/TIME SECTION
  // ============================================================================

  /// Builds the date and time selection section
  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeCard(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeCard(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: _selectedTime.format(context),
                onTap: _selectTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single date/time card
  Widget _buildDateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - NOTES SECTION
  // ============================================================================

  /// Builds the additional notes section
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Montserrat',
            ),
            decoration: const InputDecoration(
              hintText: 'Any special instructions or requirements...',
              hintStyle: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - BOTTOM BAR
  // ============================================================================

  /// Builds the bottom bar with confirm button
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
