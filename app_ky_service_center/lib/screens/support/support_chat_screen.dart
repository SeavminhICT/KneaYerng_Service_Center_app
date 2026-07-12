import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/support_chat.dart';
import '../../services/api_service.dart';
import '../Auth/login_screen.dart';
import '../Auth/register_screen.dart';

// ── Palette/Theme Helper ───────────────────────────────────────────────────────
class _SupportTheme {
  _SupportTheme(this.context);
  final BuildContext context;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get surface => isDark ? const Color(0xFF161B22) : Colors.white;
  Color get border => isDark ? const Color(0xFF2B3442) : const Color(0xFFE2E8F0);
  Color get text => isDark ? const Color(0xFFE6EDF7) : const Color(0xFF0F172A);
  Color get muted => isDark ? const Color(0xFF97A2B5) : const Color(0xFF64748B);
  Color get primary => const Color(0xFF0F6BFF);
  Color get accent => isDark ? const Color(0xFF1D2635) : const Color(0xFFECF4FF);
  Color get success => const Color(0xFF0F9D58);
  Color get warning => const Color(0xFFF97316);
}

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({
    super.key,
    this.contextType,
    this.contextId,
    this.subject,
  });

  final String? contextType;
  final int? contextId;
  final String? subject;

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  SupportConversation? _conversation;
  Timer? _pollingTimer;
  Timer? _recordTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSending = false;
  bool _isGuest = false;
  bool _isUploadingMedia = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  int? _playingMessageId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadConversation(silent: true),
    );
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingMessageId = null);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _recordTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadConversation({bool silent = false}) async {
    if (_isRefreshing) return;

    if (!silent && mounted) {
      setState(() {
        _isLoading = _conversation == null;
        _errorMessage = null;
      });
    }

    _isRefreshing = true;
    try {
      final conversation = await ApiService.fetchSupportConversation(
        contextType: widget.contextType,
        contextId: widget.contextId,
        subject: widget.subject,
      );

      if (!mounted) return;

      setState(() {
        _conversation = conversation;
        _isLoading = false;
        _isGuest = false;
        _errorMessage = null;
      });

      _jumpToLatest();
    } catch (error) {
      if (!mounted) return;
      final msg = error.toString().replaceFirst('Exception: ', '');
      final isAuth = msg.toLowerCase().contains('auth');
      setState(() {
        _isLoading = false;
        _isGuest = isAuth;
        _errorMessage = isAuth ? null : msg;
      });
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _sendMessage() async {
    final conversation = _conversation;
    final body = _messageController.text.trim();
    if (conversation == null || body.isEmpty || _isSending) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);

    try {
      await ApiService.sendSupportMessage(
        conversationId: conversation.id,
        body: body,
      );

      _messageController.clear();
      await _loadConversation(silent: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _pickImage() async {
    final conversation = _conversation;
    if (conversation == null || _isUploadingMedia || _isSending) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedCamera01),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedImage02),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploadingMedia = true);
    try {
      final mediaUrl = await ApiService.uploadSupportMedia(
        filePath: picked.path,
        type: 'image',
      );
      await ApiService.sendSupportMessage(
        conversationId: conversation.id,
        messageType: 'image',
        mediaUrl: mediaUrl,
      );
      await _loadConversation(silent: true);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isSending || _isUploadingMedia) return;

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      _showError(Exception('Microphone permission is required to record voice messages.'));
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/support_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordSeconds += 1);
    });
  }

  Future<void> _stopRecording({required bool send}) async {
    if (!_isRecording) return;

    _recordTimer?.cancel();
    final path = await _audioRecorder.stop();
    final durationSec = _recordSeconds;
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });

    if (!send || path == null) {
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      return;
    }

    if (durationSec < 1) {
      _showError(Exception('Recording was too short.'));
      return;
    }

    final conversation = _conversation;
    if (conversation == null) return;

    setState(() => _isUploadingMedia = true);
    try {
      final mediaUrl = await ApiService.uploadSupportMedia(
        filePath: path,
        type: 'voice',
      );
      await ApiService.sendSupportMessage(
        conversationId: conversation.id,
        messageType: 'voice',
        mediaUrl: mediaUrl,
        mediaDurationSec: durationSec,
      );
      await _loadConversation(silent: true);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _toggleVoicePlayback(SupportChatMessage message) async {
    final mediaUrl = ApiService.normalizeMediaUrl(message.mediaUrl);
    if (mediaUrl == null) return;

    if (_playingMessageId == message.id) {
      await _audioPlayer.stop();
      setState(() => _playingMessageId = null);
      return;
    }

    await _audioPlayer.stop();
    setState(() => _playingMessageId = message.id);
    try {
      await _audioPlayer.play(UrlSource(mediaUrl));
    } catch (error) {
      if (mounted) setState(() => _playingMessageId = null);
      _showError(error);
    }
  }

  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    final theme = _SupportTheme(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: theme.text,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).supportChat,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.text,
                ),
              ),
              Text(
                conversation == null
                    ? 'Reply in a few minutes'
                    : _supportStatusLabel(conversation.status),
                style: TextStyle(fontSize: 12, color: theme.muted),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SupportHeader(conversation: conversation),
              ),
              Expanded(
                child: _isGuest
                    ? _GuestSupportState(
                        onLoginDone: () => _loadConversation(),
                      )
                    : _isLoading
                    ? Skeletonizer(
                        enabled: true,
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return _MessageBubble(
                              message: SupportChatMessage(
                                id: index,
                                conversationId: 1,
                                senderType: index % 2 == 0 ? 'customer' : 'support',
                                messageType: 'text',
                                body: index % 2 == 0
                                    ? 'Hello, I need some help with my order status'
                                    : 'Hi! Sure, I can help you. What is your order ID?',
                                deliveryStatus: 'seen',
                                createdAt: DateTime.now().subtract(Duration(minutes: 5 - index)),
                              ),
                            );
                          },
                        ),
                      )
                    : _errorMessage != null
                    ? _SupportErrorState(
                        message: _errorMessage!,
                        onRetry: () => _loadConversation(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadConversation(),
                        color: theme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                          itemCount: conversation?.messages.length ?? 0,
                          itemBuilder: (context, index) {
                            final messages =
                                conversation?.messages ??
                                const <SupportChatMessage>[];
                            final message =
                                messages[messages.length - 1 - index];
                            return _MessageBubble(
                              message: message,
                              isPlaying: _playingMessageId == message.id,
                              onPlayVoice: () => _toggleVoicePlayback(message),
                            );
                          },
                        ),
                      ),
              ),
              _Composer(
                controller: _messageController,
                isSending: _isSending,
                isUploading: _isUploadingMedia,
                isRecording: _isRecording,
                recordSeconds: _recordSeconds,
                onSend: _sendMessage,
                onPickImage: _pickImage,
                onStartRecording: _startRecording,
                onStopRecording: () => _stopRecording(send: true),
                onCancelRecording: () => _stopRecording(send: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  const _SupportHeader({required this.conversation});

  final SupportConversation? conversation;

  @override
  Widget build(BuildContext context) {
    final currentConversation = conversation;
    final theme = _SupportTheme(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              HugeIcons.strokeRoundedCustomerSupport,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentConversation?.subject?.trim().isNotEmpty == true
                      ? currentConversation!.subject!.trim()
                      : 'General support inbox',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentConversation == null
                      ? 'We help with orders, repairs, delivery, and products.'
                      : 'Context: ${_supportContextLabel(currentConversation)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _supportStatusColor(
                context,
                currentConversation?.status,
              ).withAlpha(24),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              currentConversation == null
                  ? 'Online'
                  : _supportShortStatus(currentConversation.status),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _supportStatusColor(context, currentConversation?.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.isPlaying = false,
    this.onPlayVoice,
  });

  final SupportChatMessage message;
  final bool isPlaying;
  final VoidCallback? onPlayVoice;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomer;
    final align = isCustomer
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final theme = _SupportTheme(context);
    final bubbleColor = isCustomer ? theme.primary : theme.surface;
    final textColor = isCustomer ? Colors.white : theme.text;
    final time = message.createdAt == null
        ? ''
        : DateFormat('hh:mm a').format(message.createdAt!.toLocal());

    Widget content;
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    );

    if (message.isImage) {
      padding = const EdgeInsets.all(4);
      final imageUrl = ApiService.normalizeMediaUrl(message.mediaUrl);
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTap: imageUrl == null
              ? null
              : () => _openImagePreview(context, imageUrl),
          child: imageUrl == null
              ? const SizedBox(
                  height: 160,
                  width: 200,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 160,
                    width: 200,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
        ),
      );
    } else if (message.isVoice) {
      content = _VoiceMessageTile(
        message: message,
        isCustomer: isCustomer,
        isPlaying: isPlaying,
        onTap: onPlayVoice,
      );
    } else {
      content = Text(
        message.body?.trim().isNotEmpty == true
            ? message.body!.trim()
            : 'Message',
        style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isCustomer ? 54 : 0,
        right: isCustomer ? 0 : 54,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              border: isCustomer ? null : Border.all(color: theme.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: content,
          ),
          const SizedBox(height: 4),
          Text(
            isCustomer ? '$time  ${_deliveryLabel(message)}' : time,
            style: TextStyle(fontSize: 11.5, color: theme.muted),
          ),
        ],
      ),
    );
  }

  void _openImagePreview(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceMessageTile extends StatelessWidget {
  const _VoiceMessageTile({
    required this.message,
    required this.isCustomer,
    this.isPlaying = false,
    this.onTap,
  });

  final SupportChatMessage message;
  final bool isCustomer;
  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _SupportTheme(context);
    final color = isCustomer ? Colors.white : theme.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlaying
                ? HugeIcons.strokeRoundedPauseCircle
                : HugeIcons.strokeRoundedPlayCircle,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            'Voice message ${_formatDuration(message.mediaDurationSec)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.isUploading,
    required this.isRecording,
    required this.recordSeconds,
    required this.onSend,
    required this.onPickImage,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isUploading;
  final bool isRecording;
  final int recordSeconds;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;

  @override
  Widget build(BuildContext context) {
    final theme = _SupportTheme(context);
    final busy = isSending || isUploading;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: SafeArea(
        top: false,
        child: isRecording
            ? _buildRecordingRow(context, theme)
            : _buildComposerRow(context, theme, busy),
      ),
    );
  }

  Widget _buildRecordingRow(BuildContext context, _SupportTheme theme) {
    return Row(
      children: [
        IconButton(
          onPressed: onCancelRecording,
          icon: const Icon(HugeIcons.strokeRoundedDelete02, color: Colors.red),
          tooltip: 'Cancel recording',
        ),
        Expanded(
          child: Row(
            children: [
              const Icon(HugeIcons.strokeRoundedMic01, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Recording  ${_formatDuration(recordSeconds)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onStopRecording,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 39, 93, 240),
              shape: BoxShape.circle,
            ),
            child: const Icon(HugeIcons.strokeRoundedSent, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildComposerRow(BuildContext context, _SupportTheme theme, bool busy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: busy ? null : onPickImage,
          icon: Icon(HugeIcons.strokeRoundedImage02, color: theme.muted),
          tooltip: 'Send image',
        ),
        IconButton(
          onPressed: busy ? null : onStartRecording,
          icon: Icon(HugeIcons.strokeRoundedMic01, color: theme.muted),
          tooltip: 'Voice message',
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.border),
            ),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLength: 500,
              style: TextStyle(color: theme.text),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: theme.muted),
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: busy ? null : onSend,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: busy
                  ? theme.muted
                  : const Color.fromARGB(255, 39, 93, 240),
              borderRadius: BorderRadius.circular(20),
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : const Icon(HugeIcons.strokeRoundedSent, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _GuestSupportState extends StatelessWidget {
  const _GuestSupportState({required this.onLoginDone});

  final VoidCallback onLoginDone;

  @override
  Widget build(BuildContext context) {
    final theme = _SupportTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B63FF), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedCustomerSupport,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).supportChat,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create an account or login to start\na live conversation with our team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: theme.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Login button
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B63FF), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B63FF).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ))
                      .then((_) => onLoginDone()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).login,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Register button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ))
                    .then((_) => onLoginDone()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B63FF),
                  side: const BorderSide(color: Color(0xFF3B63FF), width: 1.6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).createAccount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportErrorState extends StatelessWidget {
  const _SupportErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = _SupportTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              HugeIcons.strokeRoundedMessage01,
              size: 42,
              color: theme.muted,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).somethingWentWrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => onRetry(),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

String _supportStatusLabel(String status) {
  switch (status) {
    case 'waiting_for_support':
      return 'Waiting for support reply';
    case 'waiting_for_user':
      return 'Support replied';
    case 'resolved':
      return 'Resolved conversation';
    case 'closed':
      return 'Closed conversation';
    case 'new':
      return 'New conversation';
    case 'open':
    default:
      return 'Reply in a few minutes';
  }
}

String _supportShortStatus(String status) {
  switch (status) {
    case 'waiting_for_support':
      return 'Queued';
    case 'waiting_for_user':
      return 'Replied';
    case 'resolved':
      return 'Resolved';
    case 'closed':
      return 'Closed';
    case 'new':
      return 'New';
    case 'open':
    default:
      return 'Online';
  }
}

Color _supportStatusColor(BuildContext context, String? status) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  switch (status) {
    case 'waiting_for_support':
      return const Color(0xFFF97316);
    case 'resolved':
    case 'waiting_for_user':
      return const Color(0xFF0F9D58);
    case 'closed':
      return isDark ? const Color(0xFF97A2B5) : const Color(0xFF64748B);
    case 'new':
    case 'open':
    default:
      return const Color(0xFF0F6BFF);
  }
}

String _supportContextLabel(SupportConversation conversation) {
  if (conversation.contextType == null || conversation.contextType!.isEmpty) {
    return 'General support';
  }

  final type = conversation.contextType!.replaceAll('_', ' ').trim();
  if (conversation.contextId != null) {
    return '$type #${conversation.contextId}';
  }
  return type;
}

String _deliveryLabel(SupportChatMessage message) {
  if (message.deliveryStatus == 'seen') return 'Seen';
  if (message.deliveryStatus == 'delivered') return 'Delivered';
  if (message.deliveryStatus == 'sending') return 'Sending';
  return 'Sent';
}

String _formatDuration(int? seconds) {
  final safe = seconds ?? 0;
  final minutes = safe ~/ 60;
  final remainder = safe % 60;
  return '$minutes:${remainder.toString().padLeft(2, '0')}';
}
