// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

const _kRecentEmojisKey = 'recent_emojis_v1';
const _kMaxRecentEmojis = 32;

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

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _audioRecorder = AudioRecorder();

  bool _hasText = false;
  bool _isRecording = false;
  bool _isUploadingAudio = false;
  bool _showEmojiPanel = false;
  bool _isLocked = false; // grabación bloqueada (no requiere mantener)
  double _recordingDragX = 0; // arrastre horizontal desde origen
  double _recordingDragY = 0; // arrastre vertical desde origen

  static const double _kCancelThreshold = -80.0;
  static const double _kLockThreshold = -70.0;

  late TabController _emojiTabController;
  List<String> _recentEmojis = [];

  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;

  static const _emojiCategories = <String, List<String>>{
    '😀': [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '😚',
      '😙',
      '🥲',
      '😋',
      '😛',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤭',
      '🤫',
      '🤔',
      '🤐',
      '🤨',
      '😐',
      '😑',
      '😶',
      '😏',
      '😒',
      '🙄',
      '😬',
      '🤥',
      '😌',
      '😔',
      '😪',
      '🤤',
      '😴',
      '😷',
      '🤒',
      '🤕',
      '🤢',
      '🤮',
      '🤧',
      '🥵',
      '🥶',
      '🥴',
      '😵',
      '🤯',
      '🤠',
      '🥸',
      '😎',
      '🧐',
      '😕',
      '😟',
      '🙁',
      '☹️',
      '😮',
      '😯',
      '😲',
      '😳',
      '🥺',
      '😦',
      '😧',
      '😨',
      '😰',
      '😥',
      '😢',
      '😭',
      '😱',
      '😖',
      '😣',
      '😞',
      '😓',
      '😩',
      '😫',
      '🥱',
      '😤',
      '😡',
      '😠',
      '🤬',
      '😈',
      '👿',
      '💀',
      '☠️',
      '💩',
      '🤡',
      '👹',
    ],
    '❤️': [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💔',
      '❣️',
      '💕',
      '💞',
      '💓',
      '💗',
      '💖',
      '💘',
      '💝',
      '💟',
      '🫀',
      '💋',
      '💌',
      '🌹',
      '🌷',
      '🌸',
      '💐',
      '🌺',
      '🌻',
      '🌼',
      '🪷',
      '🪻',
      '🎀',
      '🎁',
      '🎊',
      '🎉',
      '✨',
      '🌟',
      '⭐',
      '💫',
      '🔥',
      '🌈',
      '💯',
      '🆕',
      '🆓',
      '♾️',
    ],
    '👋': [
      '👋',
      '🤚',
      '🖐️',
      '✋',
      '🖖',
      '🫱',
      '🫲',
      '🫳',
      '🫴',
      '👌',
      '🤌',
      '🤏',
      '✌️',
      '🤞',
      '🫰',
      '🤟',
      '🤘',
      '🤙',
      '👈',
      '👉',
      '👆',
      '🖕',
      '👇',
      '☝️',
      '🫵',
      '👍',
      '👎',
      '✊',
      '👊',
      '🤛',
      '🤜',
      '👏',
      '🙌',
      '🫶',
      '👐',
      '🤲',
      '🙏',
      '✍️',
      '💅',
      '🤳',
      '💪',
      '🦾',
      '🦵',
      '🦶',
      '👂',
      '🦻',
      '👃',
      '👁️',
      '👀',
    ],
    '👤': [
      '🧑',
      '👶',
      '🧒',
      '👦',
      '👧',
      '👱',
      '👨',
      '🧔',
      '👩',
      '🧓',
      '👴',
      '👵',
      '🙍',
      '🙎',
      '🙅',
      '🙆',
      '💁',
      '🙋',
      '🧏',
      '🙇',
      '🤦',
      '🤷',
      '👮',
      '🕵️',
      '💂',
      '🥷',
      '👷',
      '🤴',
      '👸',
      '👳',
      '👲',
      '🧕',
      '🤵',
      '👰',
      '🤰',
      '🤱',
      '👼',
      '🎅',
      '🤶',
      '🧙',
      '🧚',
      '🧛',
      '🧜',
      '🧝',
      '🧞',
      '🤖',
      '👫',
      '👬',
      '👭',
      '👪',
      '🫂',
      '💆',
      '💇',
      '🚶',
      '🧍',
      '🏃',
      '💃',
      '🕺',
    ],
    '🚴': [
      '🚴',
      '🚵',
      '🏋️',
      '🤸',
      '🤺',
      '🏌️',
      '🏇',
      '🧘',
      '🏄',
      '🏊',
      '🤽',
      '🚣',
      '🧗',
      '⛷️',
      '🏂',
      '🪂',
      '⛹️',
      '🎯',
      '🎱',
      '🎮',
      '🎲',
      '♟️',
      '🃏',
      '🎭',
      '🎨',
      '🎬',
      '🎤',
      '🎧',
      '🎼',
      '🎵',
      '🎶',
      '🎹',
      '🥁',
      '🪘',
      '🎷',
      '🎺',
      '🎸',
      '🎻',
      '🏆',
      '🥇',
      '🥈',
      '🥉',
      '🏅',
      '🎖️',
      '🏟️',
      '⚽',
      '🏀',
      '🏈',
      '⚾',
      '🥎',
      '🎾',
      '🏐',
      '🏉',
      '🥏',
      '🎳',
      '🏏',
      '🏑',
      '🏒',
      '🥍',
      '🏓',
      '🏸',
      '🥊',
      '🥋',
      '🥅',
      '⛳',
      '🏹',
      '🛝',
      '🎣',
      '🤿',
      '🏋️',
      '🛷',
      '🎿',
    ],
    '🍎': [
      '🍎',
      '🍊',
      '🍋',
      '🍇',
      '🍓',
      '🫐',
      '🍈',
      '🍒',
      '🍑',
      '🥭',
      '🍍',
      '🥥',
      '🥝',
      '🍅',
      '🍆',
      '🥑',
      '🫒',
      '🥦',
      '🥬',
      '🥒',
      '🌶️',
      '🫑',
      '🧄',
      '🧅',
      '🥔',
      '🌽',
      '🍕',
      '🍔',
      '🍟',
      '🌭',
      '🫓',
      '🥪',
      '🥙',
      '🧆',
      '🥚',
      '🍳',
      '🥞',
      '🧇',
      '🥓',
      '🥩',
      '🍗',
      '🍖',
      '🍜',
      '🍝',
      '🍛',
      '🍣',
      '🍱',
      '🍘',
      '🍙',
      '🍚',
      '🍤',
      '🍥',
      '🥮',
      '🍢',
      '🍡',
      '🥟',
      '🥠',
      '🥡',
      '🍦',
      '🍧',
      '🍨',
      '🍩',
      '🍪',
      '🎂',
      '🍰',
      '🧁',
      '🍫',
      '🍬',
      '🍭',
      '🍮',
      '🍯',
      '☕',
      '🫖',
      '🍵',
      '🧃',
      '🥤',
      '🧋',
      '🍶',
      '🍺',
      '🍻',
      '🥂',
      '🍷',
      '🥃',
      '🍸',
      '🍹',
      '🧉',
      '🍾',
      '🧊',
      '🥛',
      '💧',
      '🫗',
    ],
    '✈️': [
      '✈️',
      '🚀',
      '🛸',
      '🚁',
      '🛶',
      '⛵',
      '🚢',
      '🛳️',
      '🚂',
      '🚄',
      '🚇',
      '🚗',
      '🚕',
      '🛻',
      '🏎️',
      '🚑',
      '🚒',
      '🚓',
      '🛵',
      '🏍️',
      '🚲',
      '🛴',
      '🛹',
      '🛼',
      '🗺️',
      '🌍',
      '🌎',
      '🌏',
      '🧭',
      '🏔️',
      '⛰️',
      '🌋',
      '🗻',
      '🏕️',
      '🏖️',
      '🏜️',
      '🏝️',
      '🏞️',
      '🏛️',
      '🏗️',
      '🏠',
      '🏡',
      '🏢',
      '🏥',
      '🏦',
      '🏨',
      '🏪',
      '🏫',
      '🏬',
      '🏭',
      '🏯',
      '🏰',
      '💒',
      '🗼',
      '🗽',
      '⛪',
      '🕌',
      '🕍',
      '⛩️',
      '🕋',
      '⛲',
      '⛺',
      '🌁',
      '🌃',
      '🏙️',
      '🌄',
      '🌅',
      '🌆',
      '🌇',
      '🌉',
      '🌌',
      '🌠',
    ],
    '🔮': [
      '🔮',
      '💎',
      '💍',
      '👑',
      '🎩',
      '🧢',
      '👒',
      '🎓',
      '📿',
      '👓',
      '🕶️',
      '🥽',
      '🌂',
      '💼',
      '👜',
      '👛',
      '🎒',
      '🧳',
      '💰',
      '💳',
      '💵',
      '📱',
      '💻',
      '🖥️',
      '⌨️',
      '🖱️',
      '💾',
      '💿',
      '📀',
      '📠',
      '📞',
      '☎️',
      '📺',
      '📻',
      '⏰',
      '📡',
      '🔋',
      '🔌',
      '💡',
      '🔦',
      '🕯️',
      '🧯',
      '🔑',
      '🗝️',
      '🔨',
      '🪓',
      '⛏️',
      '🔧',
      '🔩',
      '⚙️',
      '⚖️',
      '🔗',
      '⛓️',
      '🧰',
      '🔭',
      '🔬',
      '🩺',
      '💊',
      '🩹',
      '🧬',
      '🧪',
      '📚',
      '📖',
      '📝',
      '✏️',
      '🖊️',
      '🖋️',
      '📌',
      '📍',
      '📎',
      '✂️',
      '🗃️',
    ],
    '♈': [
      '♈',
      '♉',
      '♊',
      '♋',
      '♌',
      '♍',
      '♎',
      '♏',
      '♐',
      '♑',
      '♒',
      '♓',
      '⛎',
      '☀️',
      '🌤️',
      '⛅',
      '🌥️',
      '🌦️',
      '🌧️',
      '⛈️',
      '🌩️',
      '🌨️',
      '❄️',
      '☃️',
      '⛄',
      '🌬️',
      '💨',
      '💧',
      '💦',
      '🌊',
      '🌀',
      '🌈',
      '🔴',
      '🟠',
      '🟡',
      '🟢',
      '🔵',
      '🟣',
      '⚫',
      '⚪',
      '🟤',
      '🔶',
      '🔷',
      '🔸',
      '🔹',
      '🔺',
      '🔻',
      '💠',
      '🔘',
      '✅',
      '❎',
      '🆗',
      '🆙',
      '🆒',
      '🆕',
      '🆓',
      '🔝',
      '🔛',
      '🔜',
      '🔚',
      '⭕',
      '❌',
      '❓',
      '❗',
      '💤',
      '🔞',
      '📵',
      '🚫',
      '⛔',
      '🚳',
      '🚭',
      '🚯',
      '🚱',
    ],
    '🏳️': [
      '🏳️',
      '🏴',
      '🏁',
      '🚩',
      '🏳️‍🌈',
      '🏳️‍⚧️',
      '🏴‍☠️',
      '🇨🇴',
      '🇲🇽',
      '🇦🇷',
      '🇧🇷',
      '🇨🇱',
      '🇵🇪',
      '🇻🇪',
      '🇪🇨',
      '🇧🇴',
      '🇵🇾',
      '🇺🇾',
      '🇨🇷',
      '🇵🇦',
      '🇬🇹',
      '🇭🇳',
      '🇸🇻',
      '🇳🇮',
      '🇩🇴',
      '🇨🇺',
      '🇺🇸',
      '🇨🇦',
      '🇬🇧',
      '🇪🇸',
      '🇫🇷',
      '🇩🇪',
      '🇮🇹',
      '🇵🇹',
      '🇯🇵',
      '🇰🇷',
      '🇨🇳',
      '🇷🇺',
      '🇮🇳',
      '🇦🇺',
      '🇿🇦',
      '🇳🇬',
      '🇪🇬',
      '🇲🇦',
      '🇸🇦',
      '🇦🇪',
      '🇹🇷',
      '🇮🇱',
      '🇬🇷',
      '🇵🇱',
      '🇸🇪',
      '🇳🇴',
      '🇩🇰',
      '🇫🇮',
      '🇨🇭',
      '🇦🇹',
    ],
  };

  @override
  void initState() {
    super.initState();
    _emojiTabController = TabController(
      length: _emojiCategories.length + 1, // +1 para recientes
      vsync: this,
    );
    _loadRecentEmojis();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  Future<void> _loadRecentEmojis() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kRecentEmojisKey) ?? [];
    if (mounted) setState(() => _recentEmojis = saved);
  }

  Future<void> _saveRecentEmoji(String emoji) async {
    final updated = [
      emoji,
      ..._recentEmojis.where((e) => e != emoji),
    ].take(_kMaxRecentEmojis).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecentEmojisKey, updated);
    if (mounted) setState(() => _recentEmojis = updated);
  }

  @override
  void dispose() {
    _emojiTabController.dispose();
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
        offset: pos < 0 ? newText.length : pos + emoji.length,
      ),
    );
    _saveRecentEmoji(emoji);
  }

  // ── Grabación ──────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    // Pedir permiso de micrófono
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se necesita permiso de micrófono para grabar'),
          ),
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      _recordingPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 32000),
        path: _recordingPath!,
      );

      // Sonido y vibración de activación
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _showEmojiPanel = false;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_audios')
          .child(widget.chatId)
          .child(fileName);

      await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'audio/mp4',
          cacheControl: 'public, max-age=31536000',
        ),
      );
      final url = await ref.getDownloadURL();

      widget.onSendVoice(url, secs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar audio: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAudio = false);
    }
  }

  void _cancelRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    HapticFeedback.lightImpact();
    setState(() {
      _isRecording = false;
      _isLocked = false;
      _recordingSeconds = 0;
      _recordingDragX = 0;
      _recordingDragY = 0;
    });
  }

  void _lockRecording() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLocked = true;
      _recordingDragX = 0;
      _recordingDragY = 0;
    });
  }

  void _onRecordingDrag(Offset offset) {
    if (!_isRecording || _isLocked) return;
    setState(() {
      _recordingDragX = offset.dx;
      _recordingDragY = offset.dy;
    });
    if (_recordingDragX < _kCancelThreshold) {
      _cancelRecording();
      return;
    }
    if (_recordingDragY < _kLockThreshold) {
      _lockRecording();
    }
  }

  void _onRecordingRelease() {
    if (!_isRecording || _isLocked) return;
    _stopAndSendRecording();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1A2B3C) : Colors.white;
    final borderColor = widget.isDark
        ? const Color(0xFF2C3E50)
        : Colors.grey.shade300;

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
                        Text(
                          'Enviando audio...',
                          style: TextStyle(
                            color: widget.isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isRecording && _isLocked)
                Expanded(
                  child: _RecordingBar(
                    seconds: _recordingSeconds,
                    onCancel: _cancelRecording,
                  ),
                )
              else if (_isRecording)
                // Holding: indicador con hints de deslizamiento
                Expanded(
                  child: _HoldingRecordingBar(
                    seconds: _recordingSeconds,
                    dragX: _recordingDragX,
                    dragY: _recordingDragY,
                    cancelThreshold: _kCancelThreshold,
                    lockThreshold: _kLockThreshold,
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
                                    : Colors.grey.shade400,
                              ),
                            ),
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
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

              // Botón send/mic — estilo WhatsApp
              if (_isRecording && _isLocked)
                // Bloqueado: botón enviar tappable
                GestureDetector(
                  onTap: _stopAndSendRecording,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E8BC3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              else if (_hasText && !_isRecording)
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E8BC3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              else
                // Mic: mantener para grabar
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Candado flotante arriba (hint de bloqueo)
                    if (_isRecording && !_isLocked)
                      Positioned(
                        top: -56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _recordingDragY < _kLockThreshold * 0.6
                                ? const Color(0xFF1E8BC3)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _recordingDragY < _kLockThreshold * 0.6
                                ? Icons.lock
                                : Icons.lock_open,
                            size: 18,
                            color: _recordingDragY < _kLockThreshold * 0.6
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    if (_isRecording && !_isLocked)
                      Positioned(
                        top: -22,
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    // Botón mic
                    GestureDetector(
                      onLongPressStart: _isUploadingAudio
                          ? null
                          : (_) => _startRecording(),
                      onLongPressMoveUpdate: (d) =>
                          _onRecordingDrag(d.offsetFromOrigin),
                      onLongPressEnd: (_) => _onRecordingRelease(),
                      onLongPressCancel: () {
                        if (_isRecording && !_isLocked) _cancelRecording();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red
                              : (_isUploadingAudio
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade400),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Panel de emojis con categorías
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showEmojiPanel
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            height: 280,
            color: widget.isDark
                ? const Color(0xFF0D1B2A)
                : Colors.grey.shade50,
            child: Column(
              children: [
                TabBar(
                  controller: _emojiTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: const Color(0xFF16242D),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  tabs: [
                    // Pestaña de recientes
                    const Tab(
                      child: Text('🕐', style: TextStyle(fontSize: 20)),
                    ),
                    // Pestañas de categorías
                    ..._emojiCategories.keys.map(
                      (k) => Tab(
                        child: Text(k, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _emojiTabController,
                    children: [
                      // Vista de recientes
                      _recentEmojis.isEmpty
                          ? Center(
                              child: Text(
                                'Aún no hay emojis recientes',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: widget.isDark
                                      ? Colors.white38
                                      : Colors.grey[400],
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    mainAxisSpacing: 2,
                                    crossAxisSpacing: 2,
                                  ),
                              itemCount: _recentEmojis.length,
                              itemBuilder: (_, i) => GestureDetector(
                                onTap: () => _insertEmoji(_recentEmojis[i]),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _recentEmojis[i],
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                      // Vistas de cada categoría
                      ..._emojiCategories.values.map((emojis) {
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 2,
                              ),
                          itemCount: emojis.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => _insertEmoji(emojis[i]),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                emojis[i],
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
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
          Container(width: 3, height: 36, color: const Color(0xFF1E8BC3)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E8BC3),
                  ),
                ),
                Text(
                  message.type == MessageType.voice
                      ? '🎤 Audio'
                      : message.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
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

// ── Holding Recording Bar (sostenido, no bloqueado) ────────────────────────────
class _HoldingRecordingBar extends StatelessWidget {
  final int seconds;
  final double dragX;
  final double dragY;
  final double cancelThreshold;
  final double lockThreshold;

  const _HoldingRecordingBar({
    required this.seconds,
    required this.dragX,
    required this.dragY,
    required this.cancelThreshold,
    required this.lockThreshold,
  });

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final cancelProgress = (dragX / cancelThreshold).clamp(0.0, 1.0);
    final translateX = dragX.clamp(cancelThreshold, 0.0);

    return Transform.translate(
      offset: Offset(translateX, 0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Punto rojo pulsante de grabación
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _fmt(seconds),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          // Hint de cancelar (desaparece al deslizar)
          AnimatedOpacity(
            opacity: (1.0 - cancelProgress * 1.5).clamp(0.0, 1.0),
            duration: const Duration(milliseconds: 80),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 16, color: Colors.grey.shade500),
                Text(
                  'Desliza para cancelar',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Icono de cancelar cuando se desliza suficiente
          AnimatedOpacity(
            opacity: cancelProgress.clamp(0.0, 1.0),
            duration: const Duration(milliseconds: 80),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Recording Bar (bloqueado) ──────────────────────────────────────────────────
class _RecordingBar extends StatefulWidget {
  final int seconds;
  final void Function() onCancel;

  const _RecordingBar({required this.seconds, required this.onCancel});

  @override
  State<_RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<_RecordingBar> {
  double _dragOffset = 0;
  static const double _cancelThreshold = -80;

  String _formatTime(int s) {
    final min = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final cancelProgress = (_dragOffset / _cancelThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          setState(() {
            _dragOffset += details.delta.dx;
          });
          if (_dragOffset < _cancelThreshold * 0.5) {
            HapticFeedback.selectionClick();
          }
        }
      },
      onHorizontalDragEnd: (_) {
        if (_dragOffset < _cancelThreshold) {
          HapticFeedback.mediumImpact();
          widget.onCancel();
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: Transform.translate(
        offset: Offset(_dragOffset.clamp(_cancelThreshold, 0), 0),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Papelera — siempre visible, animada según deslizamiento
            GestureDetector(
              onTap: widget.onCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.red.shade100,
                    Colors.red,
                    cancelProgress,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Color.lerp(Colors.red, Colors.white, cancelProgress),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Punto pulsante rojo
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatTime(widget.seconds),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 10),
            // Indicador de deslizamiento
            AnimatedOpacity(
              opacity: _dragOffset < -10 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: 16,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                  Text(
                    'Desliza para cancelar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.withOpacity(0.8),
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
}
