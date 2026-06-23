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
import 'package:biux/shared/services/permission_service.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:provider/provider.dart';

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
  final void Function(bool isTyping)? onTypingChanged;
  final VoidCallback? onCamera;
  final VoidCallback? onAttach;
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
    this.onTypingChanged,
    this.onCamera,
    this.onAttach,
    this.isDark = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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
    '🔗˜€': [
      '🔗˜€',
      '🔗˜ƒ',
      '🔗˜„',
      '🔗˜',
      '🔗˜†',
      '🔗˜…',
      '🔗¤£',
      '🔗˜‚',
      '🔗™‚',
      '🔗™ƒ',
      '🔗˜‰',
      '🔗˜Š',
      '🔗˜‡',
      '🔗¥°',
      '🔗˜',
      '🔗¤©',
      '🔗˜˜',
      '🔗˜—',
      '🔗˜š',
      '🔗˜™',
      '🔗¥²',
      '🔗˜‹',
      '🔗˜›',
      '🔗˜œ',
      '🔗¤ª',
      '🔗˜',
      '🔗¤‘',
      '🔗¤—',
      '🔗¤­',
      '🔗¤«',
      '🔗¤”',
      '🔗¤',
      '🔗¤¨',
      '🔗˜',
      '🔗˜‘',
      '🔗˜¶',
      '🔗˜',
      '🔗˜’',
      '🔗™„',
      '🔗˜¬',
      '🔗¤¥',
      '🔗˜Œ',
      '🔗˜”',
      '🔗˜ª',
      '🔗¤¤',
      '🔗˜´',
      '🔗˜·',
      '🔗¤’',
      '🔗¤•',
      '🔗¤¢',
      '🔗¤®',
      '🔗¤§',
      '🔗¥µ',
      '🔗¥¶',
      '🔗¥´',
      '🔗˜µ',
      '🔗¤¯',
      '🔗¤ ',
      '🔗¥¸',
      '🔗˜Ž',
      '🔗§',
      '🔗˜•',
      '🔗˜Ÿ',
      '🔗™',
      'a˜¹ï¸',
      '🔗˜®',
      '🔗˜¯',
      '🔗˜²',
      '🔗˜³',
      '🔗¥º',
      '🔗˜¦',
      '🔗˜§',
      '🔗˜¨',
      '🔗˜°',
      '🔗˜¥',
      '🔗˜¢',
      '🔗˜­',
      '🔗˜±',
      '🔗˜–',
      '🔗˜£',
      '🔗˜ž',
      '🔗˜“',
      '🔗˜©',
      '🔗˜«',
      '🔗¥±',
      '🔗˜¤',
      '🔗˜¡',
      '🔗˜ ',
      '🔗¤¬',
      '🔗˜ˆ',
      '🔗‘¿',
      '🔗’€',
      'a˜ ï¸',
      '🔗’©',
      '🔗¤¡',
      '🔗‘¹',
    ],
    'a¤ï¸': [
      'a¤ï¸',
      '🔗§¡',
      '🔗’›',
      '🔗’š',
      '🔗’™',
      '🔗’œ',
      '🔗–¤',
      '🔗¤',
      '🔗¤Ž',
      '🔗’”',
      'a£ï¸',
      '🔗’•',
      '🔗’ž',
      '🔗’“',
      '🔗’—',
      '🔗’–',
      '🔗’˜',
      '🔗’',
      '🔗’Ÿ',
      '🔗«€',
      '🔗’‹',
      '🔗’Œ',
      '🌐¹',
      '🌐·',
      '🌐¸',
      '🔗’',
      '🌐º',
      '🌐»',
      '🌐¼',
      '🔗ª·',
      '🔗ª»',
      '🔗Ž€',
      '🔗Ž',
      '🔗ŽŠ',
      '🔗Ž‰',
      'aœ¨',
      '🌐Ÿ',
      'a­',
      '🔗’«',
      '🔗”¥',
      '🌐ˆ',
      '🔗’¯',
      '🔗†•',
      '🔗†“',
      'a™¾ï¸',
    ],
    '🔗‘‹': [
      '🔗‘‹',
      '🔗¤š',
      '🔗–ï¸',
      'aœ‹',
      '🔗––',
      '🔗«±',
      '🔗«²',
      '🔗«³',
      '🔗«´',
      '🔗‘Œ',
      '🔗¤Œ',
      '🔗¤',
      'aœŒï¸',
      '🔗¤ž',
      '🔗«°',
      '🔗¤Ÿ',
      '🔗¤˜',
      '🔗¤™',
      '🔗‘ˆ',
      '🔗‘‰',
      '🔗‘†',
      '🔗–•',
      '🔗‘‡',
      'a˜ï¸',
      '🔗«µ',
      '🔗‘',
      '🔗‘Ž',
      'aœŠ',
      '🔗‘Š',
      '🔗¤›',
      '🔗¤œ',
      '🔗‘',
      '🔗™Œ',
      '🔗«¶',
      '🔗‘',
      '🔗¤²',
      '🔗™',
      'aœï¸',
      '🔗’…',
      '🔗¤³',
      '🔗’ª',
      '🔗¦¾',
      '🔗¦µ',
      '🔗¦¶',
      '🔗‘‚',
      '🔗¦»',
      '🔗‘ƒ',
      '🔗‘ï¸',
      '🔗‘€',
    ],
    '🔗‘¤': [
      '🔗§‘',
      '🔗‘¶',
      '🔗§’',
      '🔗‘¦',
      '🔗‘§',
      '🔗‘±',
      '🔗‘¨',
      '🔗§”',
      '🔗‘©',
      '🔗§“',
      '🔗‘´',
      '🔗‘µ',
      '🔗™',
      '🔗™Ž',
      '🔗™…',
      '🔗™†',
      '🔗’',
      '🔗™‹',
      '🔗§',
      '🔗™‡',
      '🔗¤¦',
      '🔗¤·',
      '🔗‘®',
      '🔗•µï¸',
      '🔗’‚',
      '🔗¥·',
      '🔗‘·',
      '🔗¤´',
      '🔗‘¸',
      '🔗‘³',
      '🔗‘²',
      '🔗§•',
      '🔗¤µ',
      '🔗‘°',
      '🔗¤°',
      '🔗¤±',
      '🔗‘¼',
      '🔗Ž…',
      '🔗¤¶',
      '🔗§™',
      '🔗§š',
      '🔗§›',
      '🔗§œ',
      '🔗§',
      '🔗§ž',
      '🔗¤–',
      '🔗‘«',
      '🔗‘¬',
      '🔗‘­',
      '🔗‘ª',
      '🔗«‚',
      '🔗’†',
      '🔗’‡',
      '🔗š¶',
      '🔗§',
      '🔗ƒ',
      '🔗’ƒ',
      '🔗•º',
    ],
    '🔗š´': [
      '🔗š´',
      '🔗šµ',
      '🔗‹ï¸',
      '🔗¤¸',
      '🔗¤º',
      '🔗Œï¸',
      '🔗‡',
      '🔗§˜',
      '🔗„',
      '🔗Š',
      '🔗¤½',
      '🔗š£',
      '🔗§—',
      'a›·ï¸',
      '🔗‚',
      '🔗ª‚',
      'a›¹ï¸',
      '🔗Ž¯',
      '🔗Ž±',
      '🔗Ž®',
      '🔗Ž²',
      'a™Ÿï¸',
      '🔗ƒ',
      '🔗Ž­',
      '🔗Ž¨',
      '🔗Ž¬',
      '🔗Ž¤',
      '🔗Ž§',
      '🔗Ž¼',
      '🔗Žµ',
      '🔗Ž¶',
      '🔗Ž¹',
      '🔗¥',
      '🔗ª˜',
      '🔗Ž·',
      '🔗Žº',
      '🔗Ž¸',
      '🔗Ž»',
      '🔗†',
      '🔗¥‡',
      '🔗¥ˆ',
      '🔗¥‰',
      '🔗…',
      '🔗Ž–ï¸',
      '🔗Ÿï¸',
      'aš½',
      '🔗€',
      '🔗ˆ',
      'aš¾',
      '🔗¥Ž',
      '🔗Ž¾',
      '🔗',
      '🔗‰',
      '🔗¥',
      '🔗Ž³',
      '🔗',
      '🔗‘',
      '🔗’',
      '🔗¥',
      '🔗“',
      '🔗¸',
      '🔗¥Š',
      '🔗¥‹',
      '🔗¥…',
      'a›³',
      '🔗¹',
      '🔗›',
      '🔗Ž£',
      '🔗¤¿',
      '🔗‹ï¸',
      '🔗›·',
      '🔗Ž¿',
    ],
    '🔗Ž': [
      '🔗Ž',
      '🔗Š',
      '🔗‹',
      '🔗‡',
      '🔗“',
      '🔗«',
      '🔗ˆ',
      '🔗’',
      '🔗‘',
      '🔗¥­',
      '🔗',
      '🔗¥¥',
      '🔗¥',
      '🔗…',
      '🔗†',
      '🔗¥‘',
      '🔗«’',
      '🔗¥¦',
      '🔗¥¬',
      '🔗¥’',
      '🌐¶ï¸',
      '🔗«‘',
      '🔗§„',
      '🔗§…',
      '🔗¥”',
      '🌐½',
      '🔗•',
      '🔗”',
      '🔗Ÿ',
      '🌐­',
      '🔗«“',
      '🔗¥ª',
      '🔗¥™',
      '🔗§†',
      '🔗¥š',
      '🔗³',
      '🔗¥ž',
      '🔗§‡',
      '🔗¥“',
      '🔗¥©',
      '🔗—',
      '🔗–',
      '🔗œ',
      '🔗',
      '🔗›',
      '🔗£',
      '🔗±',
      '🔗˜',
      '🔗™',
      '🔗š',
      '🔗¤',
      '🔗¥',
      '🔗¥®',
      '🔗¢',
      '🔗¡',
      '🔗¥Ÿ',
      '🔗¥ ',
      '🔗¥¡',
      '🔗¦',
      '🔗§',
      '🔗¨',
      '🔗©',
      '🔗ª',
      '🔗Ž‚',
      '🔗°',
      '🔗§',
      '🔗«',
      '🔗¬',
      '🔗­',
      '🔗®',
      '🔗¯',
      'a˜•',
      '🔗«–',
      '🔗µ',
      '🔗§ƒ',
      '🔗¥¤',
      '🔗§‹',
      '🔗¶',
      '🔗º',
      '🔗»',
      '🔗¥‚',
      '🔗·',
      '🔗¥ƒ',
      '🔗¸',
      '🔗¹',
      '🔗§‰',
      '🔗¾',
      '🔗§Š',
      '🔗¥›',
      '🔗’§',
      '🔗«—',
    ],
    'aœˆï¸': [
      'aœˆï¸',
      '🔗š€',
      '🔗›¸',
      '🔗š',
      '🔗›¶',
      'a›µ',
      '🔗š¢',
      '🔗›³ï¸',
      '🔗š‚',
      '🔗š„',
      '🔗š‡',
      '🔗š—',
      '🔗š•',
      '🔗›»',
      '🔗Žï¸',
      '🔗š‘',
      '🔗š’',
      '🔗š“',
      '🔗›µ',
      '🔗ï¸',
      '🔗š²',
      '🔗›´',
      '🔗›¹',
      '🔗›¼',
      '🔗—ºï¸',
      '🌐',
      '🌐Ž',
      '🌐',
      '🔗§­',
      '🔗”ï¸',
      'a›°ï¸',
      '🌐‹',
      '🔗—»',
      '🔗•ï¸',
      '🔗–ï¸',
      '🔗œï¸',
      '🔗ï¸',
      '🔗žï¸',
      '🔗›ï¸',
      '🔗—ï¸',
      '🔗 ',
      '🔗¡',
      '🔗¢',
      '🔗¥',
      '🔗¦',
      '🔗¨',
      '🔗ª',
      '🔗«',
      '🔗¬',
      '🔗­',
      '🔗¯',
      '🔗°',
      '🔗’’',
      '🔗—¼',
      '🔗—½',
      'a›ª',
      '🔗•Œ',
      '🔗•',
      'a›©ï¸',
      '🔗•‹',
      'a›²',
      'a›º',
      '🌐',
      '🌐ƒ',
      '🔗™ï¸',
      '🌐„',
      '🌐…',
      '🌐†',
      '🌐‡',
      '🌐‰',
      '🌐Œ',
      '🌐 ',
    ],
    '🔗”®': [
      '🔗”®',
      '🔗’Ž',
      '🔗’',
      '🔗‘‘',
      '🔗Ž©',
      '🔗§¢',
      '🔗‘’',
      '🔗Ž“',
      '🔗“¿',
      '🔗‘“',
      '🔗•¶ï¸',
      '🔗¥½',
      '🌐‚',
      '🔗’¼',
      '🔗‘œ',
      '🔗‘›',
      '🔗Ž’',
      '🔗§³',
      '🔗’°',
      '🔗’³',
      '🔗’µ',
      '🔗“±',
      '🔗’»',
      '🔗–¥ï¸',
      'Ó¨ï¸',
      '🔗–±ï¸',
      '🔗’¾',
      '🔗’¿',
      '🔗“€',
      '🔗“ ',
      '🔗“ž',
      'a˜Žï¸',
      '🔗“º',
      '🔗“»',
      'a°',
      '🔗“¡',
      '🔗”‹',
      '🔗”Œ',
      '🔗’¡',
      '🔗”¦',
      '🔗•¯ï¸',
      '🔗§¯',
      '🔗”‘',
      '🔗—ï¸',
      '🔗”¨',
      '🔗ª“',
      'a›ï¸',
      '🔗”§',
      '🔗”©',
      'aš™ï¸',
      'aš–ï¸',
      '🔗”—',
      'a›“ï¸',
      '🔗§°',
      '🔗”­',
      '🔗”¬',
      '🔗©º',
      '🔗’Š',
      '🔗©¹',
      '🔗§¬',
      '🔗§ª',
      '🔗“š',
      '🔗“–',
      '🔗“',
      'aœï¸',
      '🔗–Šï¸',
      '🔗–‹ï¸',
      '🔗“Œ',
      '🔗“',
      '🔗“Ž',
      'aœ‚ï¸',
      '🔗—ƒï¸',
    ],
    'a™ˆ': [
      'a™ˆ',
      'a™‰',
      'a™Š',
      'a™‹',
      'a™Œ',
      'a™',
      'a™Ž',
      'a™',
      'a™',
      'a™‘',
      'a™’',
      'a™“',
      'a›Ž',
      'a˜€ï¸',
      '🌐¤ï¸',
      'a›…',
      '🌐¥ï¸',
      '🌐¦ï¸',
      '🌐§ï¸',
      'a›ˆï¸',
      '🌐©ï¸',
      '🌐¨ï¸',
      'a„ï¸',
      'a˜ƒï¸',
      'a›„',
      '🌐¬ï¸',
      '🔗’¨',
      '🔗’§',
      '🔗’¦',
      '🌐Š',
      '🌐€',
      '🌐ˆ',
      '🔗”´',
      '🔗Ÿ ',
      '🔗Ÿ¡',
      '🔗Ÿ¢',
      '🔗”µ',
      '🔗Ÿ£',
      'aš«',
      'ašª',
      '🔗Ÿ¤',
      '🔗”¶',
      '🔗”·',
      '🔗”¸',
      '🔗”¹',
      '🔗”º',
      '🔗”»',
      '🔗’ ',
      '🔗”˜',
      '✅',
      'aŽ',
      '🔗†—',
      '🔗†™',
      '🔗†’',
      '🔗†•',
      '🔗†“',
      '🔗”',
      '🔗”›',
      '🔗”œ',
      '🔗”š',
      'a­•',
      'aŒ',
      'a“',
      'a—',
      '🔗’¤',
      '🔗”ž',
      '🔗“µ',
      '🔗š«',
      'a›”',
      '🔗š³',
      '🔗š­',
      '🔗š¯',
      '🔗š±',
    ],
    '🔗³ï¸': [
      '🔗³ï¸',
      '🔗´',
      '🔗',
      '🔗š©',
      '🔗³ï¸a€🌐ˆ',
      '🔗³ï¸a€aš§ï¸',
      '🔗´a€a˜ ï¸',
      '🔗‡¨🔗‡´',
      '🔗‡²🔗‡½',
      '🔗‡¦🔗‡·',
      '🔗‡§🔗‡·',
      '🔗‡¨🔗‡±',
      '🔗‡µ🔗‡ª',
      '🔗‡»🔗‡ª',
      '🔗‡ª🔗‡¨',
      '🔗‡§🔗‡´',
      '🔗‡µ🔗‡¾',
      '🔗‡º🔗‡¾',
      '🔗‡¨🔗‡·',
      '🔗‡µ🔗‡¦',
      '🔗‡¬🔗‡¹',
      '🔗‡­🔗‡³',
      '🔗‡¸🔗‡»',
      '🔗‡³🔗‡®',
      '🔗‡©🔗‡´',
      '🔗‡¨🔗‡º',
      '🔗‡º🔗‡¸',
      '🔗‡¨🔗‡¦',
      '🔗‡¬🔗‡§',
      '🔗‡ª🔗‡¸',
      '🔗‡«🔗‡·',
      '🔗‡©🔗‡ª',
      '🔗‡®🔗‡¹',
      '🔗‡µ🔗‡¹',
      '🔗‡¯🔗‡µ',
      '🔗‡°🔗‡·',
      '🔗‡¨🔗‡³',
      '🔗‡·🔗‡º',
      '🔗‡®🔗‡³',
      '🔗‡¦🔗‡º',
      '🔗‡¿🔗‡¦',
      '🔗‡³🔗‡¬',
      '🔗‡ª🔗‡¬',
      '🔗‡²🔗‡¦',
      '🔗‡¸🔗‡¦',
      '🔗‡¦🔗‡ª',
      '🔗‡¹🔗‡·',
      '🔗‡®🔗‡±',
      '🔗‡¬🔗‡·',
      '🔗‡µ🔗‡±',
      '🔗‡¸🔗‡ª',
      '🔗‡³🔗‡´',
      '🔗‡©🔗‡°',
      '🔗‡«🔗‡®',
      '🔗‡¨🔗‡­',
      '🔗‡¦🔗‡¹',
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

  // a”€a”€ Texto a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    if (_showEmojiPanel) setState(() => _showEmojiPanel = false);
    widget.onSendText(text);
  }

  // a”€a”€ Emoji panel a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
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

  // a”€a”€ Grabación a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
  Future<void> _startRecording() async {
    // Pedir permiso de micrófono
    final granted = await PermissionService().ensurePermission(
      Permission.microphone,
      context: context,
    );
    if (!granted) return;

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
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.t('error_recording')}: $e')),
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
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Provider.of<LocaleNotifier>(context, listen: false).t('error_sending_audio')}: $e')));
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

  // a”€a”€ Build a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? ColorTokens.primary20 : Colors.white;
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
              // Ãrea de texto o indicador de grabación/subida
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
                          ? ColorTokens.primary10
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showEmojiPanel
                                ? Icons.keyboard_rounded
                                : Icons.emoji_emotions_outlined,
                            color: _showEmojiPanel
                                ? const Color(0xFF1E8BC3)
                                : Colors.grey,
                            size: 22,
                          ),
                          onPressed: _toggleEmojiPanel,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
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
                              hintText: l.t('write_message'),
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
                        if (widget.onCamera != null)
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.grey,
                              size: 22,
                            ),
                            onPressed: widget.onCamera,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        if (widget.onAttach != null)
                          IconButton(
                            icon: const Icon(
                              Icons.attach_file_rounded,
                              color: Colors.grey,
                              size: 22,
                            ),
                            onPressed: widget.onAttach,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: 6),

              // Botón send/mic a€” estilo WhatsApp
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
            color: widget.isDark ? ColorTokens.primary10 : Colors.grey.shade50,
            child: Column(
              children: [
                TabBar(
                  controller: _emojiTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: ColorTokens.primary30,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  tabs: [
                    // Pestaña de recientes
                    const Tab(
                      child: Text('🔗•', style: TextStyle(fontSize: 20)),
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
                                l.t('no_recent_emojis'),
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

// a”€a”€ Reply Bar a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
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
      color: isDark ? ColorTokens.primary20 : Colors.grey.shade100,
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
                      ? '🔗Ž¤ Audio'
                      : message.type == MessageType.image
                      ? '🔗–¼ï¸ Imagen'
                      : message.type == MessageType.video
                      ? '🔗Ž¬ Video'
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

// a”€a”€ Holding Recording Bar (sostenido, no bloqueado) a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
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

// a”€a”€ Recording Bar (bloqueado) a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€a”€
class _RecordingBar extends StatefulWidget {
  final int seconds;
  final void Function() onCancel;

  const _RecordingBar({required this.seconds, required this.onCancel});

  @override
  State<_RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<_RecordingBar> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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
            // Papelera a€” siempre visible, animada segúnn deslizamiento
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
