import 'package:biux/core/design_system/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class StoryEditorScreen extends StatefulWidget {
  final List<AssetEntity> images;

  const StoryEditorScreen({Key? key, required this.images}) : super(key: key);

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  late TextEditingController _descriptionController;

  // Estados de edición
  double _textPositionY = 0.5; // 0 = arriba, 0.5 = centro, 1 = abajo
  double _textSize = 18.0;
  Color _textColor = Colors.white;
  double _photoZoom = 1.0;
  bool _isAdvertisement = false;
  int _currentImageIndex = 0;

  // Lista de colores disponibles
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Color(0xFFFFD700), // Oro
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final sizeScreen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        title: Text(l.t('edit_story'), style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'description': _descriptionController.text,
                  'isAdvertisement': _isAdvertisement,
                });
              },
              icon: const Icon(Icons.check),
              label: Text(
                l.t('publish'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Preview de la historia
            Container(
              height: sizeScreen.height * 0.45,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Foto con zoom
                  Transform.scale(
                    scale: _photoZoom,
                    child: Image(
                      image: AssetEntityImageProvider(
                        widget.images[_currentImageIndex],
                        isOriginal: false,
                      ),
                      fit: BoxFit.cover,
                      width: sizeScreen.width,
                      height: sizeScreen.height * 0.45,
                    ),
                  ),

                  // Overlay oscuro semitransparente
                  Container(color: Colors.black.withValues(alpha: 0.3)),

                  // Texto de descripción posicionable
                  if (_descriptionController.text.isNotEmpty)
                    Positioned(
                      top: _textPositionY == 0
                          ? 40
                          : (_textPositionY == 0.5
                                ? (sizeScreen.height * 0.45 - 50) / 2
                                : sizeScreen.height * 0.45 - 80),
                      left: 20,
                      right: 20,
                      child: Text(
                        _descriptionController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _textSize,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Indicador de fotos
            if (widget.images.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() => _currentImageIndex = index);
                      },
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? ColorTokens.secondary50
                              : ColorTokens.neutral30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Controles de edición
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l.t('add_description_placeholder'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Posición del texto
                  Text(
                    l.t('text_position'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPositionButton(l.t('position_top'), 0.0),
                      _buildPositionButton(l.t('position_center'), 0.5),
                      _buildPositionButton(l.t('position_bottom'), 1.0),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tamaño del texto
                  Text(
                    '${l.t('text_size_label')}: ${_textSize.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  Slider(
                    value: _textSize,
                    min: 12,
                    max: 40,
                    activeColor: ColorTokens.secondary50,
                    onChanged: (value) {
                      setState(() => _textSize = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Color del texto
                  Text(
                    l.t('text_color_label'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colorOptions.map((color) {
                        final isSelected = _textColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _textColor = color);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Zoom de la foto
                  Text(
                    '${l.t('photo_zoom_label')}: ${_photoZoom.toStringAsFixed(2)}x',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  Slider(
                    value: _photoZoom,
                    min: 1.0,
                    max: 3.0,
                    activeColor: ColorTokens.secondary50,
                    onChanged: (value) {
                      setState(() => _photoZoom = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Publicidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isAdvertisement
                            ? [Color(0xFFFFD700), Color(0xFFFFA500)]
                            : [ColorTokens.neutral10, ColorTokens.neutral20],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAdvertisement
                            ? Color(0xFFFFD700)
                            : ColorTokens.neutral30,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: _isAdvertisement
                                  ? Color(0xFFFFD700)
                                  : ColorTokens.neutral60,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.t('publish_as_advertisement'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isAdvertisement
                                    ? Color(0xFF1A1A1A)
                                    : ColorTokens.neutral80,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isAdvertisement,
                          activeThumbColor: Color(0xFFFFD700),
                          onChanged: (value) {
                            setState(() => _isAdvertisement = value);
                          },
                        ),
                      ],
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

  Widget _buildPositionButton(String label, double position) {
    final isSelected = _textPositionY == position;
    return GestureDetector(
      onTap: () {
        setState(() => _textPositionY = position);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorTokens.secondary50 : ColorTokens.neutral20,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorTokens.secondary50 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : ColorTokens.neutral80,
          ),
        ),
      ),
    );
  }
}
