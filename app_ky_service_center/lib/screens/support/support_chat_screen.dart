import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/support_chat.dart';
import '../../services/api_service.dart';

const _supportBg = Color(0xFFF4F7FB);
const _supportSurface = Colors.white;
const _supportBorder = Color(0xFFE2E8F0);
const _supportText = Color(0xFF0F172A);
const _supportMuted = Color(0xFF64748B);
const _supportPrimary = Color(0xFF0F6BFF);
const _supportAccent = Color(0xFFECF4FF);
const _supportSuccess = Color(0xFF0F9D58);
const _supportWarning = Color(0xFFF97316);

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

  SupportConversation? _conversation;
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadConversation(silent: true),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
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
        _errorMessage = null;
      });

      _jumpToLatest();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
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
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _supportBg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _supportBg,
          foregroundColor: _supportText,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chat Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _supportText,
                ),
              ),
              Text(
                conversation == null
                    ? 'Reply in a few minutes'
                    : _supportStatusLabel(conversation.status),
                style: const TextStyle(
                  fontSize: 12,
                  color: _supportMuted,
                ),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _SupportErrorState(
                        message: _errorMessage!,
                        onRetry: () => _loadConversation(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadConversation(),
                        color: _supportPrimary,
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
                            return _MessageBubble(message: message);
                          },
                        ),
                      ),
              ),
              _Composer(
                controller: _messageController,
                isSending: _isSending,
                onSend: _sendMessage,
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _supportSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _supportBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: _supportAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _supportPrimary,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _supportText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentConversation == null
                      ? 'We help with orders, repairs, delivery, and products.'
                      : 'Context: ${_supportContextLabel(currentConversation)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _supportMuted,
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
                color: _supportStatusColor(currentConversation?.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomer;
    final align = isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isCustomer ? _supportPrimary : _supportSurface;
    final textColor = isCustomer ? Colors.white : _supportText;
    final time = message.createdAt == null
        ? ''
        : DateFormat('hh:mm a').format(message.createdAt!.toLocal());

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              border: isCustomer ? null : Border.all(color: _supportBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: message.isVoice
                ? _VoiceMessageTile(message: message, isCustomer: isCustomer)
                : Text(
                    message.body?.trim().isNotEmpty == true
                        ? message.body!.trim()
                        : 'Message',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            isCustomer ? '$time  ${_deliveryLabel(message)}' : time,
            style: const TextStyle(
              fontSize: 11.5,
              color: _supportMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceMessageTile extends StatelessWidget {
  const _VoiceMessageTile({
    required this.message,
    required this.isCustomer,
  });

  final SupportChatMessage message;
  final bool isCustomer;

  @override
  Widget build(BuildContext context) {
    final color = isCustomer ? Colors.white : _supportText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_circle_fill_rounded, color: color, size: 22),
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
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: _supportSurface,
        border: Border(top: BorderSide(color: _supportBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Voice recording is not enabled yet in this app build.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.mic_none_rounded,
                color: _supportMuted,
              ),
              tooltip: 'Voice message',
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _supportBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _supportBorder),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: _supportMuted),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: isSending ? null : onSend,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isSending ? _supportMuted : _supportPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
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
  const _SupportErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 42,
              color: _supportMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to open support chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _supportText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _supportMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
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

Color _supportStatusColor(String? status) {
  switch (status) {
    case 'waiting_for_support':
      return _supportWarning;
    case 'resolved':
    case 'waiting_for_user':
      return _supportSuccess;
    case 'closed':
      return _supportMuted;
    case 'new':
    case 'open':
    default:
      return _supportPrimary;
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
  return '${minutes}:${remainder.toString().padLeft(2, '0')}';
}
