import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget para reproducir videos en las experiencias
/// Soporta videos de hasta 30 segundos con controles automáticos
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onFinished;
  final VoidCallback? onTap;
  final bool autoPlay;
  final bool showControls;
  final bool isPlaying;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.onFinished,
    this.onTap,
    this.autoPlay = true,
    this.showControls = false,
    this.isPlaying = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambió la URL del video, reinicializar
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeVideo();
    }

    // Controlar reproducción basado en isPlaying
    if (oldWidget.isPlaying != widget.isPlaying && _isInitialized) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Validar URL
      if (widget.videoUrl.isEmpty) {
        throw Exception('URL del video está vacía');
      }

      // Crear controlador
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      }

      // Inicializar controlador
      await _controller.initialize();

      // Configurar listener para cuando termine el video
      _controller.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      // Auto-reproducir si está habilitado
      if (widget.autoPlay && widget.isPlaying) {
        await _controller.play();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      debugPrint('Error inicializando video: $e');
    }
  }

  void _videoListener() {
    // Verificar si el video terminó
    if (_controller.value.position >= _controller.value.duration) {
      widget.onFinished?.call();
    }
  }

  void _disposeController() {
    if (_isInitialized) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();

    // Si no hay controles personalizados, alternar play/pause
    if (!widget.showControls && _isInitialized) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),

        // Controles opcionales
        if (widget.showControls) _buildControls(),

        // Indicador de pausa (solo visible cuando está pausado)
        if (!_controller.value.isPlaying && !_isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de progreso
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                backgroundColor: Colors.white24,
                bufferedColor: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),

            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tiempo actual / duración
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final current = value.position.inSeconds;
                    final total = value.duration.inSeconds;
                    return Text(
                      '${_formatDuration(current)} / ${_formatDuration(total)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),

                // Botón play/pause
                IconButton(
                  onPressed: () {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
