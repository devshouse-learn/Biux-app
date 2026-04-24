import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/ride_recommendations/domain/entities/ride_recommendation_entity.dart';
import 'package:biux/features/ride_recommendations/presentation/providers/ride_recommendation_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class SendRecommendationSheet extends StatefulWidget {
  final RideTrackEntity track;
  const SendRecommendationSheet({super.key, required this.track});

  @override
  State<SendRecommendationSheet> createState() =>
      _SendRecommendationSheetState();
}

class _SendRecommendationSheetState extends State<SendRecommendationSheet> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  UserEntity? _selectedFriend;
  RecommendationType _type = RecommendationType.organizedRoute;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _highlightCtrl = TextEditingController();
  final List<String> _highlights = [];
  File? _coverImage;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final d = widget.track.startTime;
    _nameCtrl.text = 'Mi rodada del ${d.day}/${d.month}/${d.year}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideRecommendationProvider>().loadFriends();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _highlightCtrl.dispose();
    super.dispose();
  }

  void _addHighlight() {
    final text = _highlightCtrl.text.trim();
    if (text.isNotEmpty && _highlights.length < 5) {
      setState(() {
        _highlights.add(text);
        _highlightCtrl.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  void _removeImage() => setState(() => _coverImage = null);

  Future<void> _send() async {
    if (_selectedFriend == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('select_friend'))));
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('add_route_name'))),
      );
      return;
    }
    setState(() => _sending = true);
    final ok = await context
        .read<RideRecommendationProvider>()
        .sendRecommendation(
          track: widget.track,
          toUser: _selectedFriend!,
          routeName: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          type: _type,
          highlights: _highlights,
          coverImageFile: _coverImage,
        );
    if (mounted) {
      setState(() => _sending = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recomendación enviada a ${_selectedFriend!.fullName}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('error_sending')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideRecommendationProvider>(
      builder: (context, prov, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTokens.primary30.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.share_location_rounded,
                        color: ColorTokens.primary30,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.t('recommend_route'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${widget.track.totalKm.toStringAsFixed(1)} km · ${widget.track.durationFormatted}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Stats resumen
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat(
                        '${widget.track.totalKm.toStringAsFixed(1)} km',
                        l.t('distance'),
                      ),
                      _stat(widget.track.durationFormatted, l.t('duration')),
                      _stat(
                        '${widget.track.avgSpeed.toStringAsFixed(1)} km/h',
                        'Vel avg',
                      ),
                      _stat('${widget.track.calories} kcal', 'Calorías'),
                    ],
                  ),
                ),
                SizedBox(height: 14),

                // Nombre
                Text(
                  l.t('route_name'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: l.t('route_name_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 14),

                // Tipo
                Text(
                  l.t('route_type'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RecommendationType.values.map((t) {
                    final selected = _type == t;
                    return GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? ColorTokens.primary30
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? ColorTokens.primary30
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14),

                // Descripción
                Text(
                  l.t('description'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Cuéntale a tu amigo qué encontrará en esta ruta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sitios destacados
                Text(
                  'Sitios destacados (máx. 5)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: _highlightCtrl,
                  decoration: InputDecoration(
                    hintText: l.t('point_of_interest_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.keyboard_return_rounded, size: 18),
                      onPressed: _addHighlight,
                      tooltip: l.t('add_label'),
                    ),
                  ),
                  onSubmitted: (_) => _addHighlight(),
                ),
                if (_highlights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _highlights
                        .map(
                          (h) => Chip(
                            label: Text(
                              h,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () =>
                                setState(() => _highlights.remove(h)),
                            backgroundColor: ColorTokens.primary30.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(
                              color: ColorTokens.primary30.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                SizedBox(height: 16),

                // Foto de portada (opcional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.t('cover_photo_label'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Opcional',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (_coverImage == null)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 6),
                          Text(
                            l.t('tap_to_add_photo'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _coverImage!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Cambiar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 16),

                // Enviar a
                Text(
                  l.t('send_to'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (prov.loading)
                  const Center(child: CircularProgressIndicator())
                else if (prov.friends.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey[400]),
                        const SizedBox(width: 10),
                        Text(
                          'Aún no sigues a nadie',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: prov.friends.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final f = prov.friends[i];
                        final selected = _selectedFriend?.id == f.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFriend = f),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? ColorTokens.primary30
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: f.photo.isNotEmpty
                                      ? NetworkImage(f.photo)
                                      : null,
                                  backgroundColor: Colors.grey[200],
                                  child: f.photo.isEmpty
                                      ? Text(
                                          f.fullName.isNotEmpty
                                              ? f.fullName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.fullName.split(' ').first,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? ColorTokens.primary30
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),

                // Botón enviar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.send_rounded),
                    label: Text(
                      _sending ? 'Enviando...' : l.t('send_recommendation'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String value, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ],
  );
}
