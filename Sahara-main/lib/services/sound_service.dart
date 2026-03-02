import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  // Initialize and load sound preference
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    await _audioPlayer.setVolume(0.5);
  }

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  bool get isSoundEnabled => _soundEnabled;

  // Play success sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Play error sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Play click sound
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Play tap sound (lighter than click)
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Play notification sound
  Future<void> playNotification() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Play swipe sound
  Future<void> playSwipe() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/swipe.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}
