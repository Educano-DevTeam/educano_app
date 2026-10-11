import 'dart:typed_data';

import 'package:video_player/video_player.dart';

VideoPlayerController createMaterialVideoController({
  required String source,
  Uint8List? bytes,
  String? path,
  String? fileName,
}) {
  if (bytes != null) {
    return VideoPlayerController.networkUrl(
      Uri.dataFromBytes(bytes, mimeType: _mimeType(fileName)),
    );
  }
  final uri = Uri.tryParse(source);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return VideoPlayerController.networkUrl(uri);
  }
  return VideoPlayerController.asset(source);
}

String _mimeType(String? name) {
  final ext = name?.split('.').last.toLowerCase();
  return switch (ext) {
    'webm' => 'video/webm',
    'mov' => 'video/quicktime',
    'm4v' => 'video/x-m4v',
    _ => 'video/mp4',
  };
}
