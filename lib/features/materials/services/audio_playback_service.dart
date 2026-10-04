import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlaybackService extends ChangeNotifier {
  AudioPlaybackService._();
  static final AudioPlaybackService instance = AudioPlaybackService._();

  final AudioPlayer player = AudioPlayer();

  String? title;
  String? subtitle;
  String? source;
  Object? restoreArguments;
  bool minimized = false;
  bool loading = false;
  Object? lastError;
  Duration? _durationHint;
  int _loadGeneration = 0;

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<bool> get playingStream => player.playingStream;

  Duration? get duration => player.duration ?? _durationHint;
  bool get isPlaying => player.playing;
  double get volume => player.volume;
  double get speed => player.speed;

  Future<void> load({
    required String source,
    required String title,
    String? subtitle,
    Duration? duration,
  }) async {
    final generation = ++_loadGeneration;
    this.title = title;
    this.subtitle = subtitle;
    this.source = source;
    restoreArguments = null;
    _durationHint = duration;
    minimized = false;
    loading = true;
    lastError = null;
    notifyListeners();

    try {
      await player.stop();
      if (_isNetwork(source)) {
        await player.setUrl(source);
      } else {
        await player.setAsset(source);
      }
      if (generation != _loadGeneration) return;
      loading = false;
      notifyListeners();
    } catch (error) {
      if (generation == _loadGeneration) {
        loading = false;
        lastError = error;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> play() => player.play();

  Future<void> pause() => player.pause();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setVolume(double value) async {
    await player.setVolume(value.clamp(0.0, 1.0).toDouble());
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    await player.setSpeed(value.clamp(0.5, 2.0).toDouble());
    notifyListeners();
  }

  Future<void> seekRelative(Duration delta) async {
    var target = player.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    final total = player.duration;
    if (total != null && target > total) target = total;
    await player.seek(target);
  }

  void minimize({Object? restoreArguments}) {
    if (title == null || loading) return;
    minimized = true;
    this.restoreArguments = restoreArguments;
    notifyListeners();
  }

  void restore() {
    if (!minimized) return;
    minimized = false;
    notifyListeners();
  }

  Future<void> stop() async {
    ++_loadGeneration;
    minimized = false;
    title = null;
    subtitle = null;
    source = null;
    restoreArguments = null;
    _durationHint = null;
    loading = false;
    lastError = null;
    notifyListeners();
    try {
      await player.stop();
    } catch (error) {
      lastError = error;
      notifyListeners();
    }
  }

  static bool _isNetwork(String source) =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
