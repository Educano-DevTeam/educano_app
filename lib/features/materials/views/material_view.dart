
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/educano_colors.dart';
import '../../course/models/course_models.dart';
import '../../course/repositories/course_local_repository.dart';
import '../config/material_test_paths.dart';
import '../models/material_route_args.dart';
import '../services/audio_playback_service.dart';
import '../widgets/material_playback_controls.dart';

class MaterialView extends StatefulWidget {
  final String courseId;
  final String sessionId;
  final String moduleId;
  final String materialId;

  const MaterialView({
    super.key,
    required this.courseId,
    required this.sessionId,
    required this.moduleId,
    required this.materialId,
  });

  @override
  State<MaterialView> createState() => _MaterialViewState();
}

class _MaterialViewState extends State<MaterialView> {
  final CourseLocalRepository _repository = CourseLocalRepository.instance;

  CourseMaterial? _material;
  bool _loading = true;
  bool _completedOnExit = false;

  @override
  void initState() {
    super.initState();
    _loadMaterial();
  }

  Future<void> _loadMaterial() async {
    final course = await _repository.getCourse(widget.courseId);
    CourseMaterial? found;

    if (course != null) {
      for (final session in course.sessions) {
        if (session.id != widget.sessionId) continue;
        for (final module in session.modules) {
          if (module.id != widget.moduleId) continue;
          for (final material in module.materials) {
            if (material.id == widget.materialId) {
              found = material;
              break;
            }
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _material = found;
      _loading = false;
    });
  }

  Future<void> _markCompletedAndExit({bool keepAudio = false}) async {
    if (_completedOnExit) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    _completedOnExit = true;

    if (!keepAudio && _material?.kind == MaterialKind.audio) {
      try {
        await AudioPlaybackService.instance.stop();
      } catch (error) {
        debugPrint('Failed to stop audio while leaving material: $error');
      }
    }

    await _markMaterialCompleted();

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _minimizeAudio() async {
    if (_material?.kind != MaterialKind.audio) return;

    _completedOnExit = true;
    AudioPlaybackService.instance.minimize(
      restoreArguments: MaterialRouteArgs(
        courseId: widget.courseId,
        sessionId: widget.sessionId,
        moduleId: widget.moduleId,
        materialId: widget.materialId,
      ),
    );
    await _markMaterialCompleted();

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _markMaterialCompleted() async {
    try {
      await _repository.markMaterialCompleted(
        courseId: widget.courseId,
        sessionId: widget.sessionId,
        moduleId: widget.moduleId,
        materialId: widget.materialId,
      );
    } catch (error) {
      debugPrint('Failed to mark material as completed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_material == null) {
      return _ErrorView(
          message: 'Não foi possível encontrar este material.',
          onBack: () => Navigator.of(context).pop(),
        );
    }

    switch (_material!.kind) {
      case MaterialKind.video:
        return _buildVideo();
      case MaterialKind.audio:
        return _buildAudio();
      case MaterialKind.pdf:
        return _buildPdf();
      case MaterialKind.activity:
        return _buildUnsupported();
    }
  }

  Widget _buildVideo() {
    return WillPopScope(
      onWillPop: () async {
        await _markCompletedAndExit();
        return false;
      },
      child: _VideoMaterialView(
        material: _material!,
        onBack: _markCompletedAndExit,
      ),
    );
  }

  Widget _buildAudio() {
    return WillPopScope(
      onWillPop: () async {
        await _markCompletedAndExit();
        return false;
      },
      child: _AudioMaterialView(
        material: _material!,
        onBack: _markCompletedAndExit,
        onMinimize: _minimizeAudio,
      ),
    );
  }

  Widget _buildPdf() {
    return WillPopScope(
      onWillPop: () async {
        await _markCompletedAndExit();
        return false;
      },
      child: _PdfMaterialView(
        material: _material!,
        onBack: _markCompletedAndExit,
      ),
    );
  }

  Widget _buildUnsupported() {
    return _ErrorView(
        message: 'Atividades possuem uma tela própria de simulado.',
        onBack: () => Navigator.of(context).pop(),
      );
  }
}

class _MaterialHeader extends StatelessWidget {
  final CourseMaterial material;
  final VoidCallback onBack;
  final Widget? trailing;

  const _MaterialHeader({
    required this.material,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 34),
            color: const Color(0xFF707070),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EducanoColors.successGreen.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              material.kind.icon,
              color: EducanoColors.successGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF454545),
                  ),
                ),
                Text(
                  material.kindLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: EducanoColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _VideoMaterialView extends StatefulWidget {
  final CourseMaterial material;
  final VoidCallback onBack;

  const _VideoMaterialView({
    required this.material,
    required this.onBack,
  });

  @override
  State<_VideoMaterialView> createState() => _VideoMaterialViewState();
}

class _VideoMaterialViewState extends State<_VideoMaterialView> {
  VideoPlayerController? _controller;
  bool _error = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final source = widget.material.fileUrl?.trim().isNotEmpty == true
          ? widget.material.fileUrl!.trim()
          : MaterialTestPaths.video;
      final isNetwork = source.startsWith('http://') || source.startsWith('https://');
      if (!isNetwork) await rootBundle.load(source);
      final controller = isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(source))
          : VideoPlayerController.asset(source);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.play();
      setState(() => _controller = controller);
    } catch (error) {
      debugPrint('Failed to load video: $error');
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = 'Video playback failed: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return SingleChildScrollView(
          padding: EdgeInsets.all(mobile ? 10 : 28),
          child: Column(
            children: [
              _MaterialHeader(
                material: widget.material,
                onBack: widget.onBack,
                trailing: Text(
                  widget.material.metadataLabel,
                  style: const TextStyle(
                    color: EducanoColors.successGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: mobile ? 14 : 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio:
                      _controller?.value.aspectRatio ?? (16 / 9),
                  child: _error ? _PlayerError(message: _errorMessage ?? 'Video playback unavailable.', color: Colors.white) : _controller == null
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_controller!),
                                _VideoControls(controller: _controller!),
                              ],
                            ),
                ),
              ),
              SizedBox(height: mobile ? 14 : 22),
              _DescriptionCard(
                title: 'Descrição',
                description: widget.material.description.isEmpty
                    ? 'Este material ainda não possui uma descrição.'
                    : widget.material.description,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool fullscreen;

  const _VideoControls({required this.controller, this.fullscreen = false});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Configuracoes de video', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            Row(children: [
              const Icon(Icons.volume_up_outlined),
              Expanded(child: Slider(
                value: widget.controller.value.volume.clamp(0.0, 1.0).toDouble(),
                onChanged: (volume) async {
                  await widget.controller.setVolume(volume);
                  setModalState(() {});
                },
              )),
            ]),
            Row(children: [
              const Icon(Icons.speed_rounded), const SizedBox(width: 12),
              const Text('Velocidade'), const Spacer(),
              DropdownButton<double>(
                value: const <double>[0.75, 1, 1.25, 1.5, 2].contains(widget.controller.value.playbackSpeed)
                    ? widget.controller.value.playbackSpeed : 1.0,
                items: const <double>[0.75, 1, 1.25, 1.5, 2]
                    .map((v) => DropdownMenuItem<double>(value: v, child: Text('${v}x'))).toList(),
                onChanged: (speed) async {
                  if (speed != null) {
                    await widget.controller.setPlaybackSpeed(speed);
                    setModalState(() {});
                  }
                },
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showFullscreen() {
    if (widget.fullscreen) {
      Navigator.of(context).pop();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: SafeArea(child: Stack(alignment: Alignment.center, children: [
          Center(child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(alignment: Alignment.bottomCenter, children: [
              VideoPlayer(widget.controller),
              _VideoControls(controller: widget.controller, fullscreen: true),
            ]),
          )),
          Positioned(top: 8, right: 8, child: IconButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          )),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MaterialPlaybackControls(
        position: value.position,
        duration: value.duration,
        isPlaying: value.isPlaying,
        loading: !value.isInitialized,
        volume: value.volume,
        onPlayPause: () async {
          if (value.isPlaying) {
            await widget.controller.pause();
          } else {
            await widget.controller.play();
          }
        },
        onSeek: widget.controller.seekTo,
        onVolumeChanged: widget.controller.setVolume,
        onSettings: _showSettings,
        onFullscreen: _showFullscreen,
        fullscreen: widget.fullscreen,
      ),
    );
  }
}
class _AudioMaterialView extends StatefulWidget {
  final CourseMaterial material;
  final VoidCallback onBack;
  final VoidCallback onMinimize;

  const _AudioMaterialView({
    required this.material,
    required this.onBack,
    required this.onMinimize,
  });

  @override
  State<_AudioMaterialView> createState() => _AudioMaterialViewState();
}

class _AudioMaterialViewState extends State<_AudioMaterialView> {
  final _service = AudioPlaybackService.instance;
  bool _error = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final source = widget.material.fileUrl?.trim().isNotEmpty == true
        ? widget.material.fileUrl!.trim()
        : MaterialTestPaths.audio;
    if (_service.title == widget.material.title &&
        _service.source == source &&
        !_service.loading) {
      _service.restore();
      return;
    }
    try {
      await _service.load(
        source: source,
        title: widget.material.title,
        subtitle: widget.material.kindLabel,
        duration: widget.material.durationSeconds == null
            ? null
            : Duration(seconds: widget.material.durationSeconds!),
      );
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('Failed to load audio: $error');
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = 'Audio playback failed: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.all(mobile ? 10 : 28),
          child: Column(
            children: [
              _MaterialHeader(
                material: widget.material,
                onBack: widget.onBack,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Minimizar e voltar ao curso',
                      onPressed: _service.loading || _error
                          ? null
                          : widget.onMinimize,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    Text(
                      widget.material.metadataLabel,
                      style: const TextStyle(
                        color: EducanoColors.successGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: _error
                        ? _PlayerError(message: _errorMessage ?? 'Audio playback unavailable.')
                        : _service.loading
                            ? const CircularProgressIndicator()
                            : _AudioPlayerCard(
                                title: widget.material.title,
                                service: _service,
                              ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AudioPlayerCard extends StatelessWidget {
  final String title;
  final AudioPlaybackService service;

  const _AudioPlayerCard({required this.title, required this.service});

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Configuracoes de audio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            Row(children: [
              const Icon(Icons.volume_up_outlined),
              Expanded(child: Slider(value: service.volume, onChanged: (value) { service.setVolume(value); setModalState(() {}); })),
            ]),
            Row(children: [
              const Icon(Icons.speed_rounded), const SizedBox(width: 12),
              const Text('Velocidade'), const Spacer(),
              DropdownButton<double>(
                value: service.speed,
                items: const <double>[0.75, 1, 1.25, 1.5, 2]
                    .map((v) => DropdownMenuItem<double>(value: v, child: Text('${v}x'))).toList(),
                onChanged: (value) { if (value != null) { service.setSpeed(value); setModalState(() {}); } },
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.headphones_rounded, color: EducanoColors.successGreen),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                IconButton(onPressed: () => Navigator.of(dialogContext).pop(), icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 24),
              _buildControls(dialogContext, fullscreen: true),
            ]),
          ),
        ))),
      ),
    );
  }

  Widget _buildControls(BuildContext context, {bool fullscreen = false}) {
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      initialData: Duration.zero,
      builder: (context, positionSnapshot) => StreamBuilder<Duration?>(
        stream: service.durationStream,
        initialData: service.duration,
        builder: (context, durationSnapshot) {
          return MaterialPlaybackControls(
            position: positionSnapshot.data ?? Duration.zero,
            duration: durationSnapshot.data ?? service.duration,
            isPlaying: service.isPlaying,
            loading: service.loading,
            volume: service.volume,
            onPlayPause: () => service.isPlaying ? service.pause() : service.play(),
            onSeek: service.seek,
            onVolumeChanged: service.setVolume,
            onSettings: () => _showSettings(context),
            onFullscreen: () {
              if (fullscreen) {
                Navigator.of(context).pop();
              } else {
                _showFullscreen(context);
              }
            },
            fullscreen: fullscreen,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.headphones_rounded, size: 88, color: EducanoColors.successGreen),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Color(0xFF454545))),
        const SizedBox(height: 22),
        _buildControls(context),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(tooltip: 'Voltar 10 segundos', onPressed: () => service.seekRelative(const Duration(seconds: -10)), icon: const Icon(Icons.replay_10_rounded)),
          IconButton(tooltip: 'Avancar 10 segundos', onPressed: () => service.seekRelative(const Duration(seconds: 10)), icon: const Icon(Icons.forward_10_rounded)),
        ]),
      ]),
    );
  }
}
class _PdfMaterialView extends StatefulWidget {
  final CourseMaterial material;
  final VoidCallback onBack;

  const _PdfMaterialView({
    required this.material,
    required this.onBack,
  });

  @override
  State<_PdfMaterialView> createState() => _PdfMaterialViewState();
}

class _PdfMaterialViewState extends State<_PdfMaterialView> {
  final PdfViewerController _controller = PdfViewerController();
  int _pageCount = 0;
  int _currentPage = 1;
  Uint8List? _pdfBytes;
  String? _loadError;
  bool _documentLoaded = false;
  Timer? _loadTimeout;

  String get _source {
    final configured = widget.material.fileUrl?.trim();
    return configured == null || configured.isEmpty
        ? MaterialTestPaths.pdf
        : configured;
  }

  bool get _isNetwork =>
      _source.startsWith('http://') || _source.startsWith('https://');

  @override
  void initState() {
    super.initState();
    _loadTimeout = Timer(const Duration(seconds: 25), () {
      if (mounted && !_documentLoaded) {
        _failPdfLoad('PDF loading timed out.');
      }
    });
    if (!_isNetwork) _loadLocalPdf();
  }

  Future<void> _loadLocalPdf() async {
    try {
      final data = await rootBundle.load(_source);
      if (!mounted) return;
      setState(() {
        _pdfBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      });
    } catch (error) {
      _failPdfLoad('Could not read the PDF asset: $error');
    }
  }

  void _failPdfLoad(String message) {
    _loadTimeout?.cancel();
    if (mounted) setState(() => _loadError = message);
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 10 : 28,
                mobile ? 10 : 28,
                mobile ? 10 : 28,
                12,
              ),
              child: _MaterialHeader(
                material: widget.material,
                onBack: widget.onBack,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Diminuir zoom',
                      onPressed: () {
                        _controller.zoomLevel =
                            (_controller.zoomLevel - .25).clamp(.5, 3.0);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${(_controller.zoomLevel * 100).round()}%'),
                    IconButton(
                      tooltip: 'Aumentar zoom',
                      onPressed: () {
                        _controller.zoomLevel =
                            (_controller.zoomLevel + .25).clamp(.5, 3.0);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    IconButton(
                      tooltip: 'Imprimir',
                      onPressed: () {},
                      icon: const Icon(Icons.print_outlined),
                    ),
                    IconButton(
                      tooltip: 'Baixar',
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (!mobile)
                    _PdfPageRail(
                      pageCount: _pageCount,
                      currentPage: _currentPage,
                      source: _source,
                      pdfBytes: _pdfBytes,
                      onPageSelected: _controller.jumpToPage,
                    ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                        mobile ? 10 : 28,
                        0,
                        mobile ? 10 : 28,
                        mobile ? 10 : 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD4D4D4),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(child: _buildViewer(mobile: mobile)),
                          if (mobile && _pageCount > 0)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 72,
                              child: Center(
                                child: _PdfMobilePageNavigation(
                                  currentPage: _currentPage,
                                  pageCount: _pageCount,
                                  onPrevious: () => _controller.previousPage(),
                                  onNext: () => _controller.nextPage(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewer({required bool mobile}) {
    if (_loadError != null) {
      return _PlayerError(message: _loadError!);
    }

    if (_isNetwork) {
      return SfPdfViewer.network(
        _source,
        controller: _controller,
        initialPageNumber: 1,
        pageLayoutMode: PdfPageLayoutMode.single,
        scrollDirection: mobile
            ? PdfScrollDirection.vertical
            : PdfScrollDirection.horizontal,
        canShowScrollHead: false,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: (_) => _failPdfLoad('Could not render the PDF.'),
      );
    }

    if (_pdfBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SfPdfViewer.memory(
      _pdfBytes!,
      controller: _controller,
      initialPageNumber: 1,
      pageLayoutMode: PdfPageLayoutMode.single,
      scrollDirection: mobile
          ? PdfScrollDirection.vertical
          : PdfScrollDirection.horizontal,
      canShowScrollHead: false,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onDocumentLoadFailed: (_) => _failPdfLoad('Could not render the PDF.'),
    );
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    _loadTimeout?.cancel();
    if (!mounted) return;
    setState(() {
      _documentLoaded = true;
      _pageCount = details.document.pages.count;
      _currentPage = 1;
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    if (mounted) setState(() => _currentPage = details.newPageNumber);
  }
}

class _PdfMobilePageNavigation extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PdfMobilePageNavigation({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Pagina anterior',
          onPressed: currentPage > 1 ? onPrevious : null,
          icon: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
        Text('$currentPage / $pageCount', style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Proxima pagina',
          onPressed: currentPage < pageCount ? onNext : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ]),
    );
  }
}

class _PdfPageRail extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final String source;
  final Uint8List? pdfBytes;
  final ValueChanged<int> onPageSelected;

  const _PdfPageRail({
    required this.pageCount,
    required this.currentPage,
    required this.source,
    required this.pdfBytes,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(left: 28, bottom: 28),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: pageCount == 0
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: pageCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final page = index + 1;
                final selected = page == currentPage;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onPageSelected(page),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: selected
                          ? EducanoColors.successGreen.withOpacity(.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? EducanoColors.successGreen
                            : const Color(0xFFD5D5D5),
                        width: selected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AspectRatio(
                      aspectRatio: .72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: pdfBytes != null
                            ? SfPdfViewer.memory(
                                pdfBytes!,
                                initialPageNumber: page,
                                pageLayoutMode: PdfPageLayoutMode.single,
                                scrollDirection: PdfScrollDirection.horizontal,
                                canShowScrollHead: false,
                                canShowPaginationDialog: false,
                                canShowScrollStatus: false,
                                enableTextSelection: false,
                                enableDoubleTapZooming: false,
                              )
                            : SfPdfViewer.network(
                                source,
                                initialPageNumber: page,
                                pageLayoutMode: PdfPageLayoutMode.single,
                                scrollDirection: PdfScrollDirection.horizontal,
                                canShowScrollHead: false,
                                canShowPaginationDialog: false,
                                canShowScrollStatus: false,
                                enableTextSelection: false,
                                enableDoubleTapZooming: false,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
class _DescriptionCard extends StatelessWidget {
  final String title;
  final String description;

  const _DescriptionCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF454545),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 17,
              height: 1.35,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  final String message;
  final Color color;

  const _PlayerError({required this.message, this.color = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onBack,
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
