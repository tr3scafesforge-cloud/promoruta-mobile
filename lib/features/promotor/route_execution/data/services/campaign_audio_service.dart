import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'package:promoruta/core/utils/logger.dart';

/// Audio playback state for UI
enum AudioPlaybackState {
  idle,
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
}

/// Service for playing campaign audio during execution
class CampaignAudioService {
  final AudioPlayer _player = AudioPlayer();

  String? _currentAudioUrl;
  String? _errorMessage;

  CampaignAudioService() {
    _initAudioSession();
  }

  /// Initialize audio session for proper audio handling
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      AppLogger.audio.w('Failed to configure audio session: $e');
    }
  }

  /// Load audio from URL (campaign audio file)
  ///
  /// Returns true if loaded successfully
  /// If [restorePosition] is provided, seeks to that position after loading
  Future<bool> loadAudio(String audioUrl, {Duration? restorePosition}) async {
    if (audioUrl.isEmpty) {
      _errorMessage = 'No audio URL provided';
      return false;
    }

    try {
      _currentAudioUrl = audioUrl;
      _errorMessage = null;

      AppLogger.audio.i('Loading campaign audio: $audioUrl');

      await _player.setUrl(audioUrl);

      // Restore position if provided
      if (restorePosition != null && restorePosition > Duration.zero) {
        final duration = _player.duration;
        if (duration != null && restorePosition < duration) {
          await _player.seek(restorePosition);
          AppLogger.audio.i('Restored audio position: $restorePosition');
        }
      }

      AppLogger.audio.i('Campaign audio loaded successfully');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load audio: $e';
      AppLogger.audio.e('Failed to load campaign audio: $e');
      return false;
    }
  }

  /// Play the loaded audio
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      AppLogger.audio.e('Failed to play audio: $e');
    }
  }

  /// Pause the audio
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      AppLogger.audio.e('Failed to pause audio: $e');
    }
  }

  /// Stop the audio and reset position
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      AppLogger.audio.e('Failed to stop audio: $e');
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      AppLogger.audio.e('Failed to seek audio: $e');
    }
  }

  /// Restart audio from beginning
  Future<void> restart() async {
    await seek(Duration.zero);
    await play();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Current playback position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Current buffered position stream
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  /// Duration stream (null until audio is loaded)
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Processing state stream
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Combined playback state for UI
  Stream<AudioPlaybackState> get playbackStateStream {
    return _player.playerStateStream.map((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        return AudioPlaybackState.loading;
      }

      if (state.processingState == ProcessingState.completed) {
        return AudioPlaybackState.completed;
      }

      if (state.processingState == ProcessingState.ready) {
        return state.playing
            ? AudioPlaybackState.playing
            : AudioPlaybackState.paused;
      }

      if (state.processingState == ProcessingState.idle) {
        return _currentAudioUrl != null
            ? AudioPlaybackState.ready
            : AudioPlaybackState.idle;
      }

      return AudioPlaybackState.idle;
    });
  }

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Current position
  Duration get position => _player.position;

  /// Total duration (null if not loaded)
  Duration? get duration => _player.duration;

  /// Current audio URL
  String? get currentAudioUrl => _currentAudioUrl;

  /// Error message if loading failed
  String? get errorMessage => _errorMessage;

  /// Whether audio is loaded and ready
  bool get isReady =>
      _player.processingState == ProcessingState.ready ||
      _player.processingState == ProcessingState.completed;

  /// Dispose the player and release resources
  void dispose() {
    AppLogger.audio.d('Disposing campaign audio service');
    _player.dispose();
  }
}
