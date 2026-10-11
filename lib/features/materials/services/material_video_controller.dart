import 'dart:typed_data';

import 'package:video_player/video_player.dart';

import 'material_video_controller_stub.dart'
    if (dart.library.io) 'material_video_controller_io.dart'
    if (dart.library.js_interop) 'material_video_controller_web.dart' as platform;

VideoPlayerController createMaterialVideoController({
  required String source,
  Uint8List? bytes,
  String? path,
  String? fileName,
}) => platform.createMaterialVideoController(
  source: source,
  bytes: bytes,
  path: path,
  fileName: fileName,
);
