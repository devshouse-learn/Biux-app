// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

class ChatInput extends StatefulWidget {
  final String chatId;
  final String senderName;
  final String? senderAvatar;
  final MessageEntity? replyingTo;
  final void Function(String text) onSendText;
  final void Function(String audioUrl, int durationSeconds) onSendVoice;
  final void Function() onCancelReply;
  final bool isDark;

  const ChatInput({
    super.key,
    required this.chatId,
    required this.senderName,
    this.senderAvatar,
    this.replyingTo,
    required this.onSendText,
    required this.onSendVoice,
    required this.onCancelReply,
    this.isDark = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _audioRecorder = AudioRecorder();

  bool _hasText = false;
  bool _isRecording = false;
  bool _isUploadingAudio = false;
  bool _showEmojiPanel = false;

  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;

  static const _emojis = [
    '😀','😂','😍','🥰','😎','🤩','😅','😭','😤','🥹',
    '👍','❤️','🔥','🎉','💪','🚴','⚡','🏆','👏','🙌',
    '😮','��','😡','🤔','🤣','😏','🥺','😴','🤯','🫶',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ── Texto ──────────────────────────────────────────────────────────────────
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
    if (_showEmojiPanel) setState(() => _showEmojiPanel = false);
  }

  // ── Emoji panel ────────────────────────────────────────────────────────────
  void _toggleEmojiPanel() {
    setState(() => _showEmojiPanel = !_showEmojiPanel);
    if (_showEmojiPanel) FocusScope.of(context).unfocus();
  }

  void _insertEmoji(String emoji) {
    final pos = _controller.selection.baseOffset;
    final text = _controller.text;
    final newText = pos < 0
        ? text + emoji
        : text.substring(0, pos) + emoji + text.substring(pos);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: pos < 0 ? newText.length : pos + emoji.length),
    );
  }

  // ── Grabación ──────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    // Pedir permiso de micrófono
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Se necesita permiso de micrófono para grabar')),
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      _recordingPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _showEmojiPanel = false;
      });

      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingSeconds++);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar grabación: $e')),
        );
      }
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recordingTimer?.cancel();
    final secs = _recordingSeconds;

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
        _isUploadingAudio = true;
      });

      if (path == null || path.isEmpty) {
        setState(() => _isUploadingAudio = false);
        return;
      }

      // Subir a Firebase Storage
      final file = File(path);
      final fileName =
          'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_audios')
          .child(widget.chatId)
          .child(fileName);

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      widget.onSendVoice(url, secs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAudio = false);
    }
  }

  void _cancelRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1A2B3C) : Colors.white;
    final borderColor =
        widget.isDark ? const Color(0xFF2C3E50) : Colors.grey.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply bar
        if (widget.replyingTo != null)
          _ReplyBar(
            message: widget.replyingTo!,
            onCancel: widget.onCancelReply,
            isDark: widget.isDark,
          ),

        Container(
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Área de texto o indicador de grabación/subida
              if (_isUploadingAudio)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text('Enviando audio...',
                            style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white54
                                    : Colors.grey)),
                      ],
                    ),
                  ),
                )
              else if (_isRecording)
                Expanded(
                  child: _RecordingBar(
                    seconds: _recordingSeconds,
                    onCancel: _cancelRecording,
                  ),
                )
              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF0D1B2A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            onTap: () {
                              if (_showEmojiPanel) {
                                setState(() => _showEmojiPanel = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white38
                                      : Colors.grey.shade400),
                            ),
                            style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showEmojiPanel
                                ? Icons.keyboard_rounded
                                : Icons.emoji_emotions_outlined,
                            color: _showEmojiPanel
                                ? const Color(0xFF1E8BC3)
                                : Colors.grey,
                          ),
                          onPressed: _toggleEmojiPanel,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: 6),

              // Botón send/mic/stop
              if (_isRecording)
                // Botón enviar grabación
                GestureDetector(
                  onTap: _stopAndSendRecording,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E8BC3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                )
              else
                GestureDetector(
                  onTap: _hasText ? _send : null,
                  onLongPress: _isUploadingAudio ? null : _startRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasText
                          ? const Color(0xFF1E8BC3)
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _hasText
                          ? Icons.send_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Panel de emojis
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showEmojiPanel
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            height: 220,
            color: widget.isDark
                ? const Color(0xFF0D1B2A)
                : Colors.grey.shade50,
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _emojis.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _insertEmoji(_emojis[i]),
                child: Container(
                  alignment: Alignment.center,
                  child:
                      Text(_emojis[i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Reply Bar ──────────────────────────────────────────────────────────────────
class _ReplyBar extends StatelessWidget {
  final MessageEntity message;
  final void Function() onCancel;
  final bool isDark;

  const _ReplyBar({
    required this.message,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isDark ? const Color(0xFF1A2B3C) : Colors.grey.shade100,
      child: Row(
        children: [
          Container(
              width: 3, height: 36, color: const Color(0xFF1E8BC3)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.senderName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E8BC3))),
                Text(
                  message.type == MessageType.voice
                      ? '🎤 Audio'
                      : message.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// ── Recording Bar ──────────────────────────────────────────────────────────────
class _RecordingBar extends StatelessWidget {
  final int seconds;
  final void Function() onCancel;

  const _RecordingBar({required this.seconds, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return Row(
      children: [
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onCancel,
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
        ),
        const SizedBox(width: 8),
        Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Colors.red, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          'Grabando $min:$sec',
          style: const TextStyle(
              color: Colors.red, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        const Text('Suelta para enviar',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 8),
      ],
    );
  }
}
