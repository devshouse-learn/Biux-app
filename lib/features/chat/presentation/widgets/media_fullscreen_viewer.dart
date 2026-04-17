import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Pantalla fullscreen para visualizar una imagen o video.
class MediaFullscreenViewer extends StatefulWidget {
  final String url;
  final bool isVideo;
  final String? heroTag;

  const MediaFullscreenViewer({
    super.key,
    required this.url,
    this.isVideo = false,
    this.heroTag,
  });

  static void open(
    BuildContext context, {
    required String url,
    bool isVideo = false,
    String? heroTag,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            MediaFullscreenViewer(url: url, isVideo: isVideo, heroTag: heroTag),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  State<MediaFullscreenViewer> createState() => _MediaFullscreenViewerState();
}

class _MediaFullscreenViewerState extends State<MediaFullscreenViewer> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..addListener(() {
          if (mounted) setState(() {});
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _videoReady = true);
            _videoController!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: widget.isVideo
            ? () => setState(() => _showControls = !_showControls)
            : () => Navigator.pop(context),
        child: Stack(
          children: [
            Center(child: widget.isVideo ? _buildVideo() : _buildImage()),
            // Botón cerrar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final child = InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: widget.url.startsWith('http')
          ? Image.network(
              widget.url,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                        : null,
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                );
              },
            )
          : Image.file(File(widget.url), fit: BoxFit.contain),
    );

    if (widget.heroTag != null) {
      return Hero(tag: widget.heroTag!, child: child);
    }
    return child;
  }

  Widget _buildVideo() {
    if (!_videoReady || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
      );
    }
    final vc = _videoController!;
    final position = vc.value.position;
    final duration = vc.value.duration;
    final isPlaying = vc.value.isPlaying;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video
        Center(
          child: AspectRatio(
            aspectRatio: vc.value.aspectRatio,
            child: VideoPlayer(vc),
          ),
        ),

        // Play/pause central (tap en video)
        if (_showControls)
          GestureDetector(
            onTap: () {
              isPlaying ? vc.pause() : vc.play();
            },
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

        // Controles inferiores: tiempo + seekbar
        if (_showControls)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seekbar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: const Color(0xFF1E8BC3),
                    inactiveTrackColor: Colors.white30,
                    thumbColor: const Color(0xFF1E8BC3),
                    overlayColor: const Color(
                      0xFF1E8BC3,
                    ).withValues(alpha: 0.3),
                  ),
                  child: Slider(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds.toDouble().clamp(
                            0,
                            duration.inMilliseconds.toDouble(),
                          )
                        : 0,
                    min: 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: (v) {
                      vc.seekTo(Duration(milliseconds: v.toInt()));
                    },
                  ),
                ),
                // Tiempos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
