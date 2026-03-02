import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(300, 500);
  double _minRating = 4.0;
  bool _verifiedOnly = false;
  bool _availableOnly = true;
  List<String> _selectedServices = [];

  final List<String> _allServices = [
    'Dog Walking',
    'Pet Sitting',
    'Grooming',
    'Training',
    'Vet Visit',
    'Medication Administration',
    'Pet Transportation',
    'Overnight Care',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Price Range
            const Text(
              'Price Range (per hour)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: _priceRange,
              min: 250,
              max: 600,
              divisions: 35,
              labels: RangeLabels(
                '₹${_priceRange.start.round()}',
                '₹${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${_priceRange.start.round()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  '₹${_priceRange.end.round()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Minimum Rating
            const Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _minRating,
              min: 3.0,
              max: 5.0,
              divisions: 20,
              label: _minRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _minRating = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text(
                      _minRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const Text(
                  '5.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Switches
            SwitchListTile(
              title: const Text('Verified Caregivers Only', 
                style: TextStyle(fontFamily: 'Montserrat')),
              subtitle: const Text('Show only verified professionals',
                style: TextStyle(fontFamily: 'Montserrat')),
              value: _verifiedOnly,
              onChanged: (value) {
                setState(() {
                  _verifiedOnly = value;
                });
              },
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
            ),
            SwitchListTile(
              title: const Text('Available Now',
                style: TextStyle(fontFamily: 'Montserrat')),
              subtitle: const Text('Show only currently available caregivers',
                style: TextStyle(fontFamily: 'Montserrat')),
              value: _availableOnly,
              onChanged: (value) {
                setState(() {
                  _availableOnly = value;
                });
              },
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
            ),
            const SizedBox(height: 24),
            
            // Services
            const Text(
              'Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allServices.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontFamily: 'Montserrat',
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(300, 500);
      _minRating = 4.0;
      _verifiedOnly = false;
      _availableOnly = true;
      _selectedServices = [];
    });
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'priceRange': _priceRange,
      'minRating': _minRating,
      'verifiedOnly': _verifiedOnly,
      'availableOnly': _availableOnly,
      'services': _selectedServices,
    });
    Navigator.pop(context);
  }
}
