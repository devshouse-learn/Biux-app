import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// Pantalla de cámara real con preview en vivo, flash, cambio de cámara
/// y toggle Foto/Video estilo WhatsApp.
class CameraModePicker extends StatefulWidget {
  const CameraModePicker({super.key});

  static Future<File?> open(BuildContext context) {
    return Navigator.of(context).push<File?>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => const CameraModePicker(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  State<CameraModePicker> createState() => _CameraModePickerState();
}

class _CameraModePickerState extends State<CameraModePicker>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0; // 0 = trasera, 1 = frontal
  bool _isVideo = false;
  bool _isRecording = false;
  bool _capturing = false;
  bool _initialized = false;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(_cameras[_cameraIndex]);
    }
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await _initController(_cameras[_cameraIndex]);
  }

  Future<void> _initController(CameraDescription camera) async {
    final prev = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await prev?.dispose();
    if (mounted) setState(() => _initialized = true);
  }

  void _toggleCamera() {
    if (_cameras.length < 2 || _isRecording) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _initialized = false);
    _initController(_cameras[_cameraIndex]);
  }

  void _cycleFlash() {
    if (_isRecording) return;
    const modes = [
      FlashMode.auto,
      FlashMode.always,
      FlashMode.off,
      FlashMode.torch,
    ];
    final nextIdx = (modes.indexOf(_flashMode) + 1) % modes.length;
    _flashMode = modes[nextIdx];
    _controller?.setFlashMode(_flashMode);
    setState(() {});
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
      case FlashMode.off:
        return Icons.flash_off;
    }
  }

  String get _flashLabel {
    switch (_flashMode) {
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.always:
        return 'On';
      case FlashMode.torch:
        return 'Linterna';
      case FlashMode.off:
        return 'Off';
    }
  }

  Future<void> _takePhoto() async {
    if (_capturing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final xFile = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, File(xFile.path));
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording) {
      return;
    }
    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (_) {}
  }

  Future<void> _stopVideoRecording() async {
    if (_controller == null || !_isRecording) return;
    try {
      final xFile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (mounted) Navigator.pop(context, File(xFile.path));
    } catch (_) {
      setState(() => _isRecording = false);
    }
  }

  void _onCaptureTap() {
    if (_isVideo) {
      _isRecording ? _stopVideoRecording() : _startVideoRecording();
    } else {
      _takePhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_initialized &&
              _controller != null &&
              _controller!.value.isInitialized)
            Center(child: CameraPreview(_controller!))
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2,
              ),
            ),

          // Barra superior: cerrar, flash, rotar cámara
          Positioned(
            top: topPad + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Flash
                GestureDetector(
                  onTap: _cycleFlash,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_flashIcon, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _flashLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Rotar cámara
                if (_cameras.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.cameraswitch_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _toggleCamera,
                  ),
              ],
            ),
          ),

          // Indicador de grabación
          if (_isRecording)
            Positioned(
              top: topPad + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Grabando...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Controles inferiores
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle Foto / Video
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeTab(
                      label: 'Video',
                      isActive: _isVideo,
                      onTap: _isRecording
                          ? null
                          : () => setState(() => _isVideo = true),
                    ),
                    const SizedBox(width: 32),
                    _ModeTab(
                      label: 'Foto',
                      isActive: !_isVideo,
                      onTap: _isRecording
                          ? null
                          : () => setState(() => _isVideo = false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Botón captura
                GestureDetector(
                  onTap: _onCaptureTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white,
                        width: 4,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: _capturing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _isVideo ? Colors.red : Colors.white,
                              shape: _isRecording
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: _isRecording
                                  ? BorderRadius.circular(8)
                                  : null,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isVideo
                      ? (_isRecording
                            ? 'Toca para detener'
                            : 'Toca para grabar')
                      : 'Toca para capturar',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ModeTab({required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontSize: 15,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 6 : 0,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
