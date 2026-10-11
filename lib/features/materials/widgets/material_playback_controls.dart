import 'package:flutter/material.dart';

/// Shared seek, volume, settings, and fullscreen controls for audio and video.
class MaterialPlaybackControls extends StatelessWidget {
  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final bool loading;
  final double volume;
  final Future<void> Function() onPlayPause;
  final Future<void> Function(Duration) onSeek;
  final Future<void> Function(double) onVolumeChanged;
  final VoidCallback onSettings;
  final VoidCallback onFullscreen;
  final bool fullscreen;

  const MaterialPlaybackControls({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.loading,
    required this.volume,
    required this.onPlayPause,
    required this.onSeek,
    required this.onVolumeChanged,
    required this.onSettings,
    required this.onFullscreen,
    this.fullscreen = false,
  });

  String _format(Duration? value) {
    if (value == null) return '--:--';
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final durationMs = duration?.inMilliseconds ?? 0;
    final max = durationMs > 0 ? durationMs.toDouble() : 1.0;
    final current = position.inMilliseconds
        .clamp(0, durationMs > 0 ? durationMs : 0)
        .toDouble();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF505050),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        IconButton(
          tooltip: isPlaying ? 'Pausar' : 'Reproduzir',
          visualDensity: VisualDensity.compact,
          onPressed: loading ? null : () => onPlayPause(),
          color: Colors.white,
          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: current.clamp(0, max).toDouble(),
            min: 0,
            max: max,
            activeColor: const Color(0xFF20D500),
            inactiveColor: Colors.white30,
            onChanged: loading || durationMs <= 0
                ? null
                : (value) => onSeek(Duration(milliseconds: value.round())),
          ),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '${_format(position)} / ${_format(duration)}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
        IconButton(
          tooltip: volume == 0 ? 'Ativar som' : 'Silenciar',
          visualDensity: VisualDensity.compact,
          onPressed: () => onVolumeChanged(volume == 0 ? 1 : 0),
          color: Colors.white,
          icon: Icon(volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded),
        ),
        IconButton(
          tooltip: 'Configurações',
          visualDensity: VisualDensity.compact,
          onPressed: onSettings,
          color: Colors.white,
          icon: const Icon(Icons.tune_rounded),
        ),
        IconButton(
          tooltip: fullscreen ? 'Sair da tela cheia' : 'Tela cheia',
          visualDensity: VisualDensity.compact,
          onPressed: onFullscreen,
          color: Colors.white,
          icon: Icon(fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
        ),
      ]),
    );
  }
}
