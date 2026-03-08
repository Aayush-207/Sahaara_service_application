import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';
import '../services/cloudinary_service.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/validators.dart';
import '../utils/image_picker_helper.dart';
import 'dart:io';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final SoundService _soundService = SoundService();
  
  @override
  void initState() {
    super.initState();
    _loadPets();
  }
  
  void _loadPets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      petProvider.loadUserPets(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'My Dogs',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              _soundService.playTap();
              _showAddPetDialog();
            },
          ),
        ],
      ),
      body: _buildBody(petProvider, authProvider),
    );
  }
  
  Widget _buildBody(PetProvider petProvider, AuthProvider authProvider) {
    if (petProvider.isLoading) {
      return const LoadingWidget(message: 'Loading your pets...');
    }
    
    if (petProvider.errorMessage != null) {
      return ErrorDisplayWidget(
        message: petProvider.errorMessage!,
        onRetry: () {
          if (authProvider.currentUser != null) {
            petProvider.loadUserPets(authProvider.currentUser!.uid);
          }
        },
      );
    }
    
    if (petProvider.pets.isEmpty) {
      return NoPetsEmptyState(
        onAddPet: () {
          _soundService.playClick();
          _showAddPetDialog();
        },
      );
    }
    
    return _buildPetsList(petProvider.pets);
  }

  Widget _buildPetsList(List<PetModel> pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPetCard(pets[index]),
        );
      },
    );
  }

  Widget _buildPetCard(PetModel pet) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet photo or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: pet.photoUrl != null
                  ? Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets_rounded,
                          size: 24,
                          color: Colors.white,
                        );
                      },
                    )
                  : const Icon(
                      Icons.pets_rounded,
                      size: 24,
                      color: Colors.white,
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${pet.breed} • ${pet.age} years old',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pet.weight} kg',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text(
                      'Edit',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.error,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _soundService.playTap();
              if (value == 'edit') {
                _showAddPetDialog(existingPet: pet);
              } else if (value == 'delete') {
                _showDeleteDialog(pet);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddPetDialog({PetModel? existingPet}) {
    _soundService.playTap();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddPetDialog(existingPet: existingPet),
    );
  }

  void _showDeleteDialog(PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Dog',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${pet.name}? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playTap();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final petProvider = Provider.of<PetProvider>(context, listen: false);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              
              final success = await petProvider.deletePet(pet.id);
              
              if (!mounted) return;
              
              if (success) {
                _soundService.playSuccess();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${pet.name} removed successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else {
                _soundService.playError();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      petProvider.errorMessage ?? 'Failed to delete pet',
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class AddPetDialog extends StatefulWidget {
  final PetModel? existingPet;

  const AddPetDialog({super.key, this.existingPet});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _soundService = SoundService();
  final _cloudinaryService = CloudinaryService();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late String _selectedBreed;
  bool _isSubmitting = false;
  File? _selectedPhotoFile;
  String? _petPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingPet?.name ?? '');
    _ageController = TextEditingController(
      text: widget.existingPet != null ? widget.existingPet!.age.toString() : '',
    );
    _weightController = TextEditingController(
      text: widget.existingPet != null ? widget.existingPet!.weight.toString() : '',
    );
    _selectedBreed = widget.existingPet?.breed ?? 'Labrador Retriever';
    _petPhotoUrl = widget.existingPet?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingPet != null;

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    
    if (!_formKey.currentState!.validate()) {
      _soundService.playError();
      return;
    }

    setState(() => _isSubmitting = true);
    _soundService.playTap();

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);

    if (age == null || weight == null) {
      _soundService.playError();
      setState(() => _isSubmitting = false);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add pets'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Upload image if selected
    if (_selectedPhotoFile != null) {
      debugPrint('📤 Uploading pet image...');
      _petPhotoUrl = await _cloudinaryService.uploadImage(
        _selectedPhotoFile!,
        folder: 'sahara/pets',
      );
      if (_petPhotoUrl == null) {
        if (mounted) {
          _soundService.playError();
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload pet image'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    final petData = PetModel(
      id: _isEditing ? widget.existingPet!.id : '',
      ownerId: authProvider.currentUser!.uid,
      name: name,
      type: 'Dog',
      breed: _selectedBreed,
      age: age,
      weight: weight,
      photoUrl: _petPhotoUrl,
      createdAt: _isEditing ? widget.existingPet!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      isNeutered: false,
    );

    bool success;
    try {
      if (_isEditing) {
        success = await petProvider.updatePet(petData);
      } else {
        success = await petProvider.addPet(petData);
      }
    } catch (e) {
      debugPrint('Error saving pet: $e');
      success = false;
    }

    if (!mounted) return;

    Navigator.of(context).pop();

    if (success) {
      _soundService.playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? '$name updated successfully!' : '$name added successfully!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      _soundService.playError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(petProvider.errorMessage ?? 'Failed to save pet'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEditing ? 'Edit Dog' : 'Add Dog',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pet photo section
              Center(
                child: Column(
                  children: [
                    // Photo preview or placeholder
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _selectedPhotoFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                _selectedPhotoFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _petPhotoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    _petPhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.pets_rounded,
                                          size: 50,
                                          color: AppColors.primary.withValues(alpha: 0.5),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.pets_rounded,
                                    size: 50,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 12),
                    // Upload photo button
                    ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              final photoFile = await ImagePickerHelper.pickImage(context);
                              if (photoFile != null) {
                                setState(() => _selectedPhotoFile = photoFile);
                                _soundService.playClick();
                              }
                            },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        _selectedPhotoFile != null || _petPhotoUrl != null
                            ? 'Change Photo'
                            : 'Upload Photo',
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Dog Name',
                  labelStyle: const TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: const Icon(Icons.pets_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: Validators.validatePetName,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedBreed,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedBreed = value);
                        }
                      },
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Breed',
                  labelStyle: const TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: const [
                  'Labrador Retriever',
                  'German Shepherd',
                  'Golden Retriever',
                  'French Bulldog',
                  'Bulldog',
                  'Poodle',
                  'Beagle',
                  'Rottweiler',
                  'German Shorthaired Pointer',
                  'Dachshund',
                  'Pembroke Welsh Corgi',
                  'Australian Shepherd',
                  'Yorkshire Terrier',
                  'Boxer',
                  'Great Dane',
                  'Siberian Husky',
                  'Doberman Pinscher',
                  'Cavalier King Charles Spaniel',
                  'Miniature Schnauzer',
                  'Shih Tzu',
                  'Boston Terrier',
                  'Pomeranian',
                  'Havanese',
                  'Shetland Sheepdog',
                  'Brittany',
                  'Cocker Spaniel',
                  'Border Collie',
                  'Pug',
                  'Chihuahua',
                  'Mixed Breed',
                  'Other',
                ]
                    .map((breed) => DropdownMenuItem(
                          value: breed,
                          child: Text(breed),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  labelStyle: const TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: const Icon(Icons.cake_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: const Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateWeight,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  _soundService.playTap();
                  Navigator.of(context).pop();
                },
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isEditing ? 'Update' : 'Add',
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
        ),
      ],
    );
  }
}
