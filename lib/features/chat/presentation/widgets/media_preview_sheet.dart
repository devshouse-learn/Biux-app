import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

/// Bottom sheet que muestra una vista previa de los archivos seleccionados
/// (imágenes y videos) y permite confirmar el envío.
class MediaPreviewSheet extends StatefulWidget {
  final List<File> files;
  final bool isDark;

  const MediaPreviewSheet({
    super.key,
    required this.files,
    required this.isDark,
  });

  /// Muestra el sheet y retorna la lista de archivos a enviar (o null si se cancela).
  static Future<List<File>?> show(
    BuildContext context, {
    required List<File> files,
    required bool isDark,
  }) {
    return showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaPreviewSheet(files: files, isDark: isDark),
    );
  }

  @override
  State<MediaPreviewSheet> createState() => _MediaPreviewSheetState();
}

class _MediaPreviewSheetState extends State<MediaPreviewSheet> {
  late List<File> _files;
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.files);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isVideo(File file) {
    final mime = lookupMimeType(file.path) ?? '';
    return mime.startsWith('video');
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
      if (_files.isEmpty) {
        Navigator.pop(context);
        return;
      }
      if (_currentPage >= _files.length) {
        _currentPage = _files.length - 1;
      }
      _pageController.jumpToPage(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF0D1B2A) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subtitleColor = widget.isDark ? Colors.white60 : Colors.black54;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    _files.length == 1
                        ? (_isVideo(_files[0]) ? 'Video' : 'Imagen')
                        : '${_currentPage + 1} de ${_files.length}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Botón eliminar archivo actual
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _removeFile(_currentPage),
                ),
              ],
            ),
          ),

          // Preview grande (PageView)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _files.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, index) {
                final file = _files[index];
                if (_isVideo(file)) {
                  return _VideoPreviewItem(file: file, isDark: widget.isDark);
                }
                return InteractiveViewer(
                  child: Center(child: Image.file(file, fit: BoxFit.contain)),
                );
              },
            ),
          ),

          // Miniaturas horizontales (si hay más de 1)
          if (_files.length > 1)
            Container(
              height: 72,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _files.length,
                itemBuilder: (_, index) {
                  final file = _files[index];
                  final isSelected = index == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E8BC3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _isVideo(file)
                            ? Container(
                                color: Colors.black54,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white70,
                                  size: 28,
                                ),
                              )
                            : Image.file(file, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Contador + botón enviar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Text(
                    '${_files.length} archivo${_files.length > 1 ? 's' : ''}',
                    style: TextStyle(color: subtitleColor, fontSize: 13),
                  ),
                  const Spacer(),
                  // Botón circular de enviar (flecha)
                  GestureDetector(
                    onTap: () => Navigator.pop(context, _files),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8BC3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreviewItem extends StatelessWidget {
  final File file;
  final bool isDark;

  const _VideoPreviewItem({required this.file, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_rounded,
              size: 56,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: file.length(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final mb = snap.data! / (1024 * 1024);
              return Text(
                '${mb.toStringAsFixed(1)} MB',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
