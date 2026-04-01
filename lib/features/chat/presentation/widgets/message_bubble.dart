// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool showAvatar;
  final bool isDark;
  final String chatId;
  final String currentUserId;
  final void Function(MessageEntity) onReply;
  final void Function(MessageEntity, String) onReact;
  final void Function(MessageEntity) onDeleteForMe;
  final void Function(MessageEntity) onDeleteForAll;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.isDark,
    required this.chatId,
    required this.currentUserId,
    required this.onReply,
    required this.onReact,
    required this.onDeleteForMe,
    required this.onDeleteForAll,
  });

  @override
  Widget build(BuildContext context) {
    // Ocultar si fue eliminado para el usuario actual
    if (message.deletedFor.contains(currentUserId)) {
      return const SizedBox.shrink();
    }
    if (message.deleted) return _DeletedBubble(isMe: isMe);

    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 48 : 8,
          right: isMe ? 8 : 48,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: message.senderAvatar != null
                    ? NetworkImage(message.senderAvatar!)
                    : null,
                child: message.senderAvatar == null
                    ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 6),
            ] else if (!isMe) ...[
              const SizedBox(width: 38),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe && showAvatar)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  if (message.replyToId != null)
                    _ReplyPreview(message: message, isDark: isDark),
                  _BubbleContent(message: message, isMe: isMe, isDark: isDark),
                  if (message.reactions.isNotEmpty)
                    _ReactionsRow(reactions: message.reactions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Responder'),
              onTap: () {
                Navigator.pop(context);
                onReply(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: const Text('Reaccionar'),
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showEmojiPicker(context);
                });
              },
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Eliminar para mí',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteForMe(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Eliminar para todos',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteForAll(message);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🔥', '💪', '🚴'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: emojis
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReact(message, e);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool isDark;

  const _BubbleContent({
    required this.message,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe
        ? const Color(0xFF1E8BC3)
        : (isDark ? const Color(0xFF1A2B3C) : Colors.white);
    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white70 : Colors.black87);

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildContent(textColor),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatTime(message.sentAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 3),
                _MessageStatusTicks(
                  isRead: message.isRead,
                  isDelivered: message.isDelivered,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    switch (message.type) {
      case MessageType.voice:
        return _VoiceMessage(
          message: message,
          isMe: isMe,
          textColor: textColor,
        );
      case MessageType.image:
        return _ImageMessage(url: message.mediaUrl ?? '');
      case MessageType.location:
        return _LocationMessage(
          lat: message.locationLat ?? 0,
          lng: message.locationLng ?? 0,
        );
      default:
        return Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: 14),
        );
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:$minute $period';
  }
}

class _VoiceMessage extends StatefulWidget {
  final MessageEntity message;
  final bool isMe;
  final Color textColor;

  const _VoiceMessage({
    required this.message,
    required this.isMe,
    required this.textColor,
  });

  @override
  State<_VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<_VoiceMessage> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = Duration.zero;
          _player.seek(Duration.zero);
          _player.stop();
        }
      });
    });

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final url = widget.message.mediaUrl ?? '';
    if (url.isEmpty) return;

    if (_isPlaying) {
      await _player.pause();
      return;
    }

    setState(() => _loading = true);
    try {
      // Siempre re-setear la URL para garantizar que funcione en cualquier estado
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede reproducir el audio')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final totalSecs = widget.message.audioDurationSeconds ?? 0;
    final fallbackDuration = Duration(seconds: totalSecs);
    final total = _duration.inSeconds > 0 ? _duration : fallbackDuration;
    final progress = total.inSeconds > 0
        ? (_position.inSeconds / total.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 200,
      child: Row(
        children: [
          // Botón play/pause
          GestureDetector(
            onTap: _togglePlay,
            child: _loading
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.textColor,
                    ),
                  )
                : Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: widget.textColor,
                    size: 36,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    backgroundColor: widget.textColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                // Tiempo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isPlaying || _position.inSeconds > 0
                          ? _fmt(_position)
                          : _fmt(fallbackDuration),
                      style: TextStyle(color: widget.textColor, fontSize: 10),
                    ),
                    Text(
                      _fmt(total),
                      style: TextStyle(
                        color: widget.textColor.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  final String url;
  const _ImageMessage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, width: 200, height: 150, fit: BoxFit.cover),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  final double lat;
  final double lng;
  const _LocationMessage({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.green, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Lat: ${lat.toStringAsFixed(4)}\nLng: ${lng.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final MessageEntity message;
  final bool isDark;
  const _ReplyPreview({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF1E8BC3), width: 3),
        ),
      ),
      child: Text(
        message.replyPreview ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }
}

class _ReactionsRow extends StatelessWidget {
  final Map<String, String> reactions;
  const _ReactionsRow({required this.reactions});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final e in reactions.values) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 4,
        children: counts.entries
            .map(
              (e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '${e.key} ${e.value}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Chulos de estado del mensaje (estilo WhatsApp)
/// - 1 gris: enviado
/// - 2 grises: entregado
/// - 2 azules: leído
class _MessageStatusTicks extends StatelessWidget {
  final bool isRead;
  final bool isDelivered;

  const _MessageStatusTicks({required this.isRead, required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    if (isRead) {
      // Dos chulos azules
      return _buildTicks(Colors.lightBlue, isDouble: true);
    } else if (isDelivered) {
      // Dos chulos blancos/grises
      return _buildTicks(Colors.white70, isDouble: true);
    } else {
      // Un chulo blanco/gris: enviado
      return _buildTicks(Colors.white70, isDouble: false);
    }
  }

  Widget _buildTicks(Color color, {required bool isDouble}) {
    return SizedBox(
      width: isDouble ? 20 : 10,
      height: 12,
      child: CustomPaint(
        painter: _TickPainter(color: color, isDouble: isDouble),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  final Color color;
  final bool isDouble;

  _TickPainter({required this.color, required this.isDouble});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawTick(double offsetX) {
      final h = size.height;
      // Palo corto bajando
      canvas.drawLine(
        Offset(offsetX, h * 0.45),
        Offset(offsetX + h * 0.25, h * 0.75),
        paint,
      );
      // Palo largo subiendo
      canvas.drawLine(
        Offset(offsetX + h * 0.25, h * 0.75),
        Offset(offsetX + h * 0.7, h * 0.15),
        paint,
      );
    }

    if (isDouble) {
      drawTick(0);
      drawTick(size.width * 0.45);
    } else {
      drawTick(size.width * 0.15);
    }
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.color != color || old.isDouble != isDouble;
}

class _DeletedBubble extends StatelessWidget {
  final bool isMe;
  const _DeletedBubble({required this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
        bottom: 4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Mensaje eliminado',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
