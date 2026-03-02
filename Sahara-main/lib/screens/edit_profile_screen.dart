import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';

/// Edit Profile Screen
/// 
/// Allows users to edit their profile information:
/// - Profile photo selection from gallery
/// - Full name editing
/// - Email editing
/// - Phone number editing
/// - Form validation for all fields
/// - Save changes with loading state
/// 
/// Features:
/// - Image picker for profile photo
/// - Form validation with error messages
/// - Loading state during save
/// - Success/error feedback with snackbars
/// - Sound feedback on interactions
/// 
/// Design Principles:
/// - Solid colors only (Navy, Orange, Sky Blue, Light Blue)
/// - 8px grid spacing system
/// - Montserrat font family
/// - Clean form layout
/// - Professional editing interface
/// - Clear visual hierarchy
/// 
/// Theme Colors:
/// - Background: AppColors.surface (white)
/// - Avatar: AppColors.primary with transparency
/// - Camera button: AppColors.primary (navy)
/// - Success snackbar: AppColors.success (green)
/// - Error snackbar: AppColors.error (red)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final SoundService _soundService = SoundService();
  final StorageService _storageService = StorageService();
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _selectedImagePath;
  String? _uploadedImageUrl;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================================
  // PROFILE ACTIONS
  // ============================================================================

  /// Saves the profile changes
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _soundService.playClick();
      
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;
        
        if (currentUser == null) {
          throw Exception('No user logged in');
        }

        // Upload image if selected
        String? photoUrl = _uploadedImageUrl ?? currentUser.photoUrl;
        if (_selectedImagePath != null && _uploadedImageUrl == null) {
          setState(() {
            _isUploadingImage = true;
          });
          
          final file = File(_selectedImagePath!);
          photoUrl = await _storageService.uploadProfilePicture(file, currentUser.uid);
          
          setState(() {
            _isUploadingImage = false;
            _uploadedImageUrl = photoUrl;
          });
          
          if (photoUrl == null) {
            throw Exception('Failed to upload profile picture');
          }
        }

        // Prepare update data
        final updateData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        debugPrint('💾 Saving profile with data: $updateData');
        debugPrint('💾 PhotoUrl being saved: $photoUrl');

        // Update in Firestore
        await authProvider.updateUserProfile(updateData);

        debugPrint('✅ Profile updated in Firestore');
        debugPrint('🔄 Refreshing user data...');

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _soundService.playSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });

        _soundService.playError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _soundService.playError();
    }
  }

  /// Shows image source selection dialog
  Future<void> _showImageSourceDialog() async {
    _soundService.playTap();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Choose Image Source',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text(
                'Camera',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text(
                'Gallery',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Picks an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request appropriate permission
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await _permissionService.requestCameraPermission(context);
      } else {
        hasPermission = await _permissionService.requestPhotosPermission(context);
      }
      
      if (!hasPermission) {
        if (!mounted) return;
        _soundService.playError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission is required to take photos'
                  : 'Photo library permission is required to select images',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _uploadedImageUrl = null; // Reset uploaded URL
        });

        if (!mounted) return;

        _soundService.playSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected! Tap Save to update profile.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _soundService.playError();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePhoto(),
              const SizedBox(height: 32),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - PROFILE PHOTO
  // ============================================================================

  /// Builds the profile photo with camera button
  Widget _buildProfilePhoto() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: _selectedImagePath != null 
                ? FileImage(File(_selectedImagePath!)) as ImageProvider
                : (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                    ? NetworkImage(currentUser.photoUrl!)
                    : null,
            child: (_selectedImagePath == null && 
                   (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty))
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
        if (_isUploadingImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _isUploadingImage ? null : _showImageSourceDialog,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - FORM FIELDS
  // ============================================================================

  /// Builds the name input field
  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      labelText: 'Full Name',
      prefixIcon: Icons.person_outline,
      validator: Validators.validateName,
    );
  }

  /// Builds the email input field
  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      labelText: 'Email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
    );
  }

  /// Builds the phone input field
  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      labelText: 'Phone Number',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        // Phone is optional
        if (value == null || value.trim().isEmpty) {
          return null;
        }
        return Validators.validatePhone(value);
      },
    );
  }

  // ============================================================================
  // UI BUILDERS - SAVE BUTTON
  // ============================================================================

  /// Builds the save changes button
  Widget _buildSaveButton() {
    return CustomButton(
      text: 'Save Changes',
      isLoading: _isLoading,
      onPressed: _saveProfile,
    );
  }
}
