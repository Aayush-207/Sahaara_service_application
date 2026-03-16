import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/firebase_seeder_2026_india.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Admin screen for seeding Firebase data
/// 
/// This screen provides a UI to seed initial data to Firebase Firestore.
/// Use this once to populate your database with sample caregivers and packages.
/// 
/// Features:
/// - Clear all existing data
/// - Seed fresh 2026 India research-based data
/// - 15 caregivers across major Indian cities
/// - 30 service packages with market-based pricing
/// 
/// Access: Profile → Admin Seed Screen
class AdminSeedScreen extends StatefulWidget {
  const AdminSeedScreen({super.key});

  @override
  State<AdminSeedScreen> createState() => _AdminSeedScreenState();
}

class _AdminSeedScreenState extends State<AdminSeedScreen> {
  final FirebaseSeeder2026India _seeder = FirebaseSeeder2026India();
  bool _isSeeding = false;
  String _status = 'Ready to seed 2026 India data';
  final List<String> _logs = [];

  Future<void> _seedAllData() async {
    // Get current user ID from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;
    
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please login first to seed bookings with your user ID'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() {
      _isSeeding = true;
      _status = 'Seeding data...';
      _logs.clear();
    });

    try {
      _addLog('🌱 Starting data seeding...');
      _addLog('👤 Using current user ID: $currentUserId');
      
      // Seed caregivers, packages, and pets
      await _seeder.seedCaregivers();
      _addLog('✅ Caregivers seeded');
      
      await _seeder.seedServicePackages();
      _addLog('✅ Service packages seeded');
      
      await _seeder.seedAdoptablePets();
      _addLog('✅ Adoptable pets seeded');
      
      // Seed bookings with current user ID
      await _seeder.seedSampleBookings(userId: currentUserId);
      _addLog('✅ Sample bookings seeded with your user ID');
      
      await _seeder.seedSampleReviews();
      _addLog('✅ Sample reviews seeded');
      
      _addLog('✅ Data seeding completed successfully!');
      
      setState(() {
        _status = 'Seeding completed successfully!';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data seeded successfully with your user ID!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Seeding failed';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all seeded caregivers and packages. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSeeding = true;
      _status = 'Clearing data...';
      _logs.clear();
    });

    try {
      _addLog('🗑️  Clearing all data...');
      await _seeder.clearAllData();
      _addLog('✅ Data cleared successfully!');
      
      setState(() {
        _status = 'Data cleared successfully!';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data cleared successfully!'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Clearing failed';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearEntireDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('⚠️ DANGER!'),
          ],
        ),
        content: const Text(
          'This will DELETE EVERYTHING in the database:\n\n'
          '• ALL users (owners & caregivers)\n'
          '• ALL pets\n'
          '• ALL bookings\n'
          '• ALL chats & messages\n'
          '• ALL reviews\n'
          '• ALL service packages\n\n'
          'This action CANNOT be undone!\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.error,
            ),
            child: const Text('YES, DELETE EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSeeding = true;
      _status = 'Clearing ENTIRE database...';
      _logs.clear();
    });

    try {
      _addLog('🚨 WARNING: Clearing ENTIRE database...');
      await _seeder.clearEntireDatabase();
      _addLog('✅ ENTIRE database cleared successfully!');
      
      setState(() {
        _status = 'ENTIRE database cleared!';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ENTIRE database cleared!'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Clearing failed';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _checkDatabaseStatus() async {
    setState(() {
      _isSeeding = true;
      _status = 'Checking database...';
      _logs.clear();
    });

    try {
      _addLog('📊 Checking database status...');
      await _seeder.checkDatabaseStatus();
      _addLog('✅ Status check completed!');
      
      setState(() {
        _status = 'Status check completed!';
        _isSeeding = false;
      });
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Status check failed';
        _isSeeding = false;
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Data Seeder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSeeding
                                ? Icons.hourglass_empty
                                : Icons.check_circle_outline,
                            color: _isSeeding ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _status,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isSeeding) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _isSeeding ? null : _seedAllData,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Seed All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isSeeding ? null : _checkDatabaseStatus,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Check Database Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isSeeding ? null : _clearAllData,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Seeded Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isSeeding ? null : _clearEntireDatabase,
                icon: const Icon(Icons.delete_forever),
                label: const Text('⚠️ CLEAR ENTIRE DATABASE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Card(
                color: AppColors.infoContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 8),
                          const Text(
                            'What will be seeded?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• 15 Elite caregiver profiles across 6 major Indian cities\n'
                        '• 30 Service packages (Dog Walking, Pet Sitting, Grooming, Training, Vet Visit)\n'
                        '• 10 Adoptable pets for adoption feature\n'
                        '• 15 Sample bookings (2 active, 8 upcoming, 5 pending) - using YOUR user ID\n'
                        '• 25 Sample reviews for caregivers\n'
                        '• Market-researched pricing (₹200-₹12,000)\n'
                        '• Professional credentials & certifications\n\n'
                        '⚠️ Important: Login first so bookings use your user ID!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Logs Section
              const Text(
                'Logs:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
