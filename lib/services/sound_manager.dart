import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class SoundManager {
  // Singleton instance
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Audio players
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  // Sound effect players pool
  final Map<String, List<AudioPlayer>> _effectsPlayerPool = {};
  final Map<String, DateTime> _lastPlayedTime = {};

  // Throttle durations for different sound effects (in milliseconds)
  final Map<String, int> _throttleDurations = {
    'fire.wav': 100, // Shorter throttle for rapid fire
    'explosion.wav': 300, // Longer throttle for explosions
    'collect.wav': 100, // Medium throttle for item collection
    'move.wav': 50, // Short throttle for movement
    'game_over.wav': 0, // No throttle for game over
  };

  // Maximum number of concurrent players for each sound type
  final Map<String, int> _maxPlayers = {
    'fire.wav': 3,
    'explosion.wav': 2,
    'collect.wav': 2,
    'move.wav': 1,
    'game_over.wav': 1,
  };

  // Sound state
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  // Getters for sound state
  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  // Initialize sound manager
  Future<void> initialize() async {
    // Set background music to loop
    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);

    // Initialize player pools
    _initializePlayerPools();
  }

  // Initialize player pools for different sound effects
  void _initializePlayerPools() {
    for (final entry in _maxPlayers.entries) {
      final soundEffect = entry.key;
      final maxCount = entry.value;

      _effectsPlayerPool[soundEffect] = [];

      for (int i = 0; i < maxCount; i++) {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.release); // Auto-release when done
        _effectsPlayerPool[soundEffect]!.add(player);
      }
    }
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _backgroundMusicPlayer
          .play(AssetSource('audio/background_music.wav'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _backgroundMusicPlayer.resume();
  }

  // Play sound effect with throttling and pooling
  Future<void> playSoundEffect(String soundEffect) async {
    if (!_soundEnabled) return;

    // Check if this sound effect should be throttled
    final now = DateTime.now();
    final throttleDuration = _throttleDurations[soundEffect] ?? 0;

    if (_lastPlayedTime.containsKey(soundEffect)) {
      final lastPlayed = _lastPlayedTime[soundEffect]!;
      final elapsed = now.difference(lastPlayed).inMilliseconds;

      // Skip if we're trying to play too soon after the last play
      if (elapsed < throttleDuration) {
        return;
      }
    }

    // Update last played time
    _lastPlayedTime[soundEffect] = now;

    try {
      // Get an available player from the pool
      final playerPool = _effectsPlayerPool[soundEffect];
      if (playerPool == null || playerPool.isEmpty) {
        // Fallback to creating a temporary player if no pool exists for this sound
        final tempPlayer = AudioPlayer();
        await tempPlayer.play(AssetSource('audio/$soundEffect'));
        // Dispose after playing to avoid memory leaks
        tempPlayer.onPlayerComplete.listen((_) {
          tempPlayer.dispose();
        });
        return;
      }

      // Find an available player or use the oldest one
      AudioPlayer? selectedPlayer;

      for (final player in playerPool) {
        final state = player.state;
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          selectedPlayer = player;
          break;
        }
      }

      // If no stopped player is found, use the first one (oldest)
      selectedPlayer ??= playerPool.first;

      // Play the sound effect
      await selectedPlayer.play(AssetSource('audio/$soundEffect'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound effect: $e');
      }
    }
  }

  // Toggle sound effects
  void toggleSoundEffects() {
    _soundEnabled = !_soundEnabled;
  }

  // Toggle background music
  void toggleBackgroundMusic() async {
    _musicEnabled = !_musicEnabled;

    if (_musicEnabled) {
      await resumeBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  // Set sound effects volume
  Future<void> setSoundEffectsVolume(double volume) async {
    // Set volume for all effect players in the pool
    for (final playerList in _effectsPlayerPool.values) {
      for (final player in playerList) {
        await player.setVolume(volume);
      }
    }
  }

  // Set background music volume
  Future<void> setBackgroundMusicVolume(double volume) async {
    await _backgroundMusicPlayer.setVolume(volume);
  }

  // Dispose resources
  Future<void> dispose() async {
    await _backgroundMusicPlayer.dispose();

    // Dispose all players in the pool
    for (final playerList in _effectsPlayerPool.values) {
      for (final player in playerList) {
        await player.dispose();
      }
    }
    _effectsPlayerPool.clear();
  }

  // Play specific game sound effects
  Future<void> playFireSound() async {
    await playSoundEffect('fire.wav');
  }

  Future<void> playExplosionSound() async {
    await playSoundEffect('explosion.wav');
  }

  Future<void> playItemCollectSound() async {
    await playSoundEffect('collect.wav');
  }

  Future<void> playGameOverSound() async {
    await playSoundEffect('game_over.wav');
  }

  Future<void> playAirplaneMoveSound() async {
    await playSoundEffect('move.wav');
  }
}
