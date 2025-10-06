import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget para mostrar el progreso de compresión de multimedia
class CompressionProgressWidget extends StatelessWidget {
  final String fileName;
  final double progress;
  final String? status;
  final bool isCompleted;
  final VoidCallback? onCancel;

  const CompressionProgressWidget({
    super.key,
    required this.fileName,
    required this.progress,
    this.status,
    this.isCompleted = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con archivo y acción de cancelar
          Row(
            children: [
              Icon(_getFileIcon(), color: ColorTokens.primary50, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isCompleted && onCancel != null)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  color: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : ColorTokens.primary50,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.green : ColorTokens.primary50,
                ),
              ),
            ],
          ),

          // Status text
          if (status != null) ...[
            const SizedBox(height: 8),
            Text(
              status!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return Icons.video_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }
}

/// Widget para mostrar múltiples progresos de compresión
class MultiCompressionProgressWidget extends StatelessWidget {
  final List<CompressionProgressItem> items;
  final VoidCallback? onCancelAll;

  const MultiCompressionProgressWidget({
    super.key,
    required this.items,
    this.onCancelAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final activeItems = items.where((item) => !item.isCompleted).toList();
    final completedItems = items.where((item) => item.isCompleted).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Procesando multimedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (activeItems.isNotEmpty && onCancelAll != null)
                TextButton(
                  onPressed: onCancelAll,
                  child: const Text('Cancelar todo'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Lista de progresos activos
          ...activeItems.map(
            (item) => CompressionProgressWidget(
              fileName: item.fileName,
              progress: item.progress,
              status: item.status,
              isCompleted: item.isCompleted,
              onCancel: item.onCancel,
            ),
          ),

          // Lista de completados (colapsada)
          if (completedItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Completados (${completedItems.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              initiallyExpanded: false,
              children:
                  completedItems
                      .map(
                        (item) => CompressionProgressWidget(
                          fileName: item.fileName,
                          progress: item.progress,
                          status: item.status,
                          isCompleted: item.isCompleted,
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modelo para items de progreso de compresión
class CompressionProgressItem {
  final String fileName;
  final double progress;
  final String? status;
  final bool isCompleted;
  final VoidCallback? onCancel;

  const CompressionProgressItem({
    required this.fileName,
    required this.progress,
    this.status,
    this.isCompleted = false,
    this.onCancel,
  });

  CompressionProgressItem copyWith({
    String? fileName,
    double? progress,
    String? status,
    bool? isCompleted,
    VoidCallback? onCancel,
  }) {
    return CompressionProgressItem(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      onCancel: onCancel ?? this.onCancel,
    );
  }
}
