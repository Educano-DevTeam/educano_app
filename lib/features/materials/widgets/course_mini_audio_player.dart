import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/educano_colors.dart';
import '../models/material_route_args.dart';
import '../services/audio_playback_service.dart';
import 'material_playback_controls.dart';

class CourseMiniAudioPlayer extends StatelessWidget {
  const CourseMiniAudioPlayer({super.key});

  String _format(Duration? value) {
    if (value == null) return '--:--';
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final service = AudioPlaybackService.instance;
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        if (!service.minimized || service.title == null) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<Duration>(
          stream: service.positionStream,
          initialData: Duration.zero,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration?>(
              stream: service.durationStream,
              initialData: service.duration,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? service.duration;
                return Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
                    boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 3))],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: EducanoColors.successGreen.withValues(alpha: .10), shape: BoxShape.circle),
                        child: const Icon(Icons.headphones_rounded, color: EducanoColors.successGreen, size: 25),
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(service.title!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(service.subtitle ?? 'Audio', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
                      ])),
                      Text(_format(duration), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54)),
                      IconButton(
                        tooltip: 'Fechar player e interromper audio',
                        visualDensity: VisualDensity.compact,
                        onPressed: service.stop,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    MaterialPlaybackControls(
                      position: position,
                      duration: duration,
                      isPlaying: service.isPlaying,
                      loading: service.loading,
                      volume: service.volume,
                      onPlayPause: () => service.isPlaying ? service.pause() : service.play(),
                      onSeek: service.seek,
                      onVolumeChanged: service.setVolume,
                      onSettings: () => _showSettings(context, service),
                      onFullscreen: () => _restoreMaterial(context, service),
                    ),
                  ]),
                );
              },
            );
          },
        );
      },
    );
  }

  void _restoreMaterial(BuildContext context, AudioPlaybackService service) {
    final arguments = service.restoreArguments;
    if (arguments is! MaterialRouteArgs) return;
    service.restore();
    Navigator.of(context).pushNamed(AppRoutes.material, arguments: arguments);
  }

  void _showSettings(BuildContext context, AudioPlaybackService service) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Configuracoes de audio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.volume_up_outlined), Expanded(child: Slider(value: service.volume, onChanged: (v) { service.setVolume(v); setModalState(() {}); }))]),
          Row(children: [const Icon(Icons.speed_rounded), const SizedBox(width: 12), const Text('Velocidade'), const Spacer(), DropdownButton<double>(value: service.speed, items: const <double>[0.75, 1, 1.25, 1.5, 2].map((v) => DropdownMenuItem<double>(value: v, child: Text('${v}x'))).toList(), onChanged: (v) { if (v != null) { service.setSpeed(v); setModalState(() {}); } })]),
        ]),
      )),
    );
  }
}
