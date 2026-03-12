import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Diálogo para previsualizar videos antes de agregarlos
class VideoPreviewDialog extends StatefulWidget {
  final File videoFile;
  final String? title;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const VideoPreviewDialog({
    super.key,
    required this.videoFile,
    this.title,
    this.onAccept,
    this.onReject,
  });

  @override
  State<VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.videoFile);
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Auto-play el video
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTokens.primary50.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.video_library,
                    color: ColorTokens.primary50,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title ?? l.t('video_preview'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Video player area
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _buildVideoPlayer(),
              ),
            ),

            // Controls y información del video
            if (_isInitialized) _buildVideoInfo(),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onReject?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isInitialized && !_hasError
                          ? () {
                              Navigator.of(context).pop();
                              widget.onAccept?.call();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary50,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l.t('use_video'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 8),
              Text(
                '${Provider.of<LocaleNotifier>(context).t('error_loading_video')}${_errorMessage != null ? ': $_errorMessage' : ''}',
                style: TextStyle(color: Colors.red[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_controller),

            // Overlay de controles
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    final duration = _controller.value.duration;
    final size = _controller.value.size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Progress bar
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: ColorTokens.primary50,
              bufferedColor: ColorTokens.primary50.withValues(alpha: 0.3),
              backgroundColor: Colors.grey[300]!,
            ),
          ),

          const SizedBox(height: 8),

          // Video info
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDuration(duration),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.aspect_ratio, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${size.width.toInt()}x${size.height.toInt()}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Función helper para mostrar el diálogo de vista previa
Future<bool?> showVideoPreviewDialog({
  required BuildContext context,
  required File videoFile,
  String? title,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => VideoPreviewDialog(
      videoFile: videoFile,
      title: title,
      onAccept: () => Navigator.of(context).pop(true),
      onReject: () => Navigator.of(context).pop(false),
    ),
  );
}
