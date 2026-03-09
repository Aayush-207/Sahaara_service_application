import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  late final AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  bool _initialized = false;

  // Initialize and load sound preference
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      _audioPlayer = AudioPlayer();
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      await _audioPlayer.setVolume(0.5);
      _initialized = true;
      debugPrint('✅ SoundService initialized successfully');
    } catch (e) {
      debugPrint('❌ SoundService initialization error: $e');
      _initialized = true; // Mark as initialized to avoid retry loops
    }
  }

  // Ensure initialization before playing
  Future<void> _ensureInit() async {
    if (!_initialized) {
      await init();
    }
  }

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    debugPrint('🔊 Sound toggled: $_soundEnabled');
  }

  bool get isSoundEnabled => _soundEnabled;

  // Play success sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      debugPrint('✅ Playing success sound');
    } catch (e) {
      debugPrint('❌ Error playing success sound: $e');
    }
  }

  // Play error sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      debugPrint('❌ Playing error sound');
    } catch (e) {
      debugPrint('⚠️ Error playing error sound: $e');
    }
  }

  // Play click sound
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      debugPrint('👆 Playing click sound');
    } catch (e) {
      debugPrint('⚠️ Error playing click sound: $e');
    }
  }

  // Play tap sound (alias for click)
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      // Use click.mp3 instead of tap.mp3 which doesn't exist
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      debugPrint('👆 Playing tap sound');
    } catch (e) {
      debugPrint('⚠️ Error playing tap sound: $e');
    }
  }

  // Play notification sound (alias for success)
  Future<void> playNotification() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      // Use success.mp3 instead of notification.mp3 which doesn't exist
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      debugPrint('🔔 Playing notification sound');
    } catch (e) {
      debugPrint('⚠️ Error playing notification sound: $e');
    }
  }

  // Play swipe sound (alias for click)
  Future<void> playSwipe() async {
    if (!_soundEnabled) return;
    await _ensureInit();
    try {
      // Use click.mp3 instead of swipe.mp3 which doesn't exist
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      debugPrint('🎵 Playing swipe sound');
    } catch (e) {
      debugPrint('⚠️ Error playing swipe sound: $e');
    }
  }

  // Dispose
  void dispose() {
    if (_initialized) {
      _audioPlayer.dispose();
    }
  }
}

