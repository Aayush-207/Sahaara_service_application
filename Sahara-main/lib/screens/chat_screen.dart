import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Chat Screen - Industry Standard Design
/// 
/// Features:
/// - WhatsApp/iMessage inspired UI
/// - Real-time messaging
/// - Image sharing
/// - Message timestamps
/// - Read receipts (future)
/// - Typing indicators (future)
/// - Message reactions (future)
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  UserModel? _otherUser;

  @override
  void initState() {
    super.initState();
    _chatService.markMessagesAsRead(widget.chatId, widget.currentUserId);
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final user = await _firestoreService.getUserById(widget.otherUserId);
    if (mounted) {
      setState(() => _otherUser = user);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        message: message,
      );

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => _isSending = true);

      final imageUrl = await _storageService.uploadChatImage(File(image.path));
      
      if (imageUrl != null) {
        await _chatService.sendMessage(
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
          message: '',
          imageUrl: imageUrl,
        );
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    final showDate = index == messages.length - 1 ||
                        !_isSameDay(message.timestamp, messages[index + 1].timestamp);

                    return Column(
                      children: [
                        if (showDate) _buildDateDivider(message.timestamp),
                        _buildMessageBubble(message, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: InkWell(
        onTap: () {
          // TODO: Navigate to user profile
        },
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _otherUser?.photoUrl != null && _otherUser!.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _otherUser!.photoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_otherUser?.location != null)
                    Text(
                      _otherUser!.location!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Voice call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Show menu
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border,
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMMM dd, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: message.imageUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 200,
                          height: 200,
                          color: AppColors.borderLight,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 200,
                          height: 200,
                          color: AppColors.borderLight,
                          child: const Icon(Icons.error_outline, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    if (message.message.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormat.format(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe 
                              ? AppColors.surface.withValues(alpha: 0.7) 
                              : AppColors.textTertiary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: AppColors.surface.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Emoji/More button
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              onPressed: () {
                // TODO: Show more options
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    height: 1.4,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {}); // Update send button
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            
            // Image/Send button
            if (_messageController.text.trim().isEmpty)
              IconButton(
                icon: Icon(
                  Icons.image_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                onPressed: _isSending ? null : _sendImage,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.surface,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.surface, size: 20),
                        onPressed: _sendMessage,
                        padding: EdgeInsets.zero,
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No messages yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to start the conversation',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'Unable to load messages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
