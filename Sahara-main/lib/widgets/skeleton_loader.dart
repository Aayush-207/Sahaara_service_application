import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Skeleton Loader Widgets
/// Provides loading placeholders for better UX

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.border,
                AppColors.borderLight,
                AppColors.border,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton Card for Caregiver List
class CaregiverSkeletonCard extends StatelessWidget {
  const CaregiverSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 120,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton Card for Service Package
class PackageSkeletonCard extends StatelessWidget {
  const PackageSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 120,
                height: 18,
                borderRadius: BorderRadius.circular(4),
              ),
              SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: double.infinity,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 180,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SkeletonLoader(
                width: double.infinity,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for Pet Card
class PetSkeletonCard extends StatelessWidget {
  const PetSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 64,
            height: 64,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 100,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 140,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonLoader(
                      width: 60,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(width: 12),
                    SkeletonLoader(
                      width: 60,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
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

/// Skeleton for Booking Card
class BookingSkeletonCard extends StatelessWidget {
  const BookingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 120,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              SkeletonLoader(
                width: 70,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: 160,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 140,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 80,
                height: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              SkeletonLoader(
                width: 60,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading Overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.secondary,
                strokeWidth: 3,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
