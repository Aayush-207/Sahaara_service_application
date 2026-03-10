import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_message_model.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../widgets/report_dialog.dart';
import 'package:intl/intl.dart';

/// Chat Screen - WhatsApp-like messaging interface for booked caregivers
/// Features: Real-time messaging, caregiver profiles, info dialog
class ChatScreen extends StatefulWidget {
  final String? chatRoomId; // Optional - will be created if not provided
  final String ownerId;
  final String ownerName;
  final String caregiverId;
  final String caregiverName;
  final String caregiverPhotoUrl;
  final String caregiverEmail;
  final double? caregiverRating;

  const ChatScreen({
    super.key,
    this.chatRoomId,
    required this.ownerId,
    required this.ownerName,
    required this.caregiverId,
    required this.caregiverName,
    required this.caregiverPhotoUrl,
    required this.caregiverEmail,
    this.caregiverRating,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestoreService = FirestoreService();
  final _soundService = SoundService();
  late String _currentUserId;
  late String _actualChatRoomId;
  bool _isSending = false;
  bool _hasReported = false;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _initializeChatRoom();
  }

  /// Initialize or create chat room if needed
  Future<void> _initializeChatRoom() async {
    try {
      if (widget.chatRoomId != null && widget.chatRoomId!.isNotEmpty) {
        // Use provided chat room ID
        _actualChatRoomId = widget.chatRoomId!;
      } else {
        // Create/get chat room using owner and caregiver info
        final roomId = await _firestoreService.getOrCreateChatRoom(
          ownerId: widget.ownerId,
          caregiverId: widget.caregiverId,
          ownerName: widget.ownerName,
          caregiverName: widget.caregiverName,
          caregiverPhotoUrl: widget.caregiverPhotoUrl,
          caregiverEmail: widget.caregiverEmail,
        );

        if (roomId == null) {
          throw Exception('Failed to create chat room');
        }
        _actualChatRoomId = roomId;
      }

      if (mounted) {
        setState(() => _isInitializing = false);
      }
      
      _checkIfAlreadyReported();
    } catch (e) {
      debugPrint('❌ Error initializing chat room: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Check if current user has already reported this caregiver
  Future<void> _checkIfAlreadyReported() async {
    try {
      final reports = await _firestoreService.getCaregiverReports(widget.caregiverId);
      
      // Check if current user has already reported this caregiver
      final hasReported = reports.any((report) => report['reporterId'] == _currentUserId);
      
      if (mounted) {
        setState(() => _hasReported = hasReported);
      }
    } catch (e) {
      debugPrint('Error checking report status: $e');
    }
  }

  /// Make a phone call to the caregiver
  Future<void> _makeCall() async {
    final phoneNumber = '+919970065440';
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to make call. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Report the caregiver
  void _reportCaregiver() {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        caregiverId: widget.caregiverId,
        caregiverName: widget.caregiverName,
        onReported: () {
          setState(() => _hasReported = true);
        },
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      debugPrint('📤 Attempting to send message: $message');
      
      final success = await _firestoreService.sendChatMessage(
        chatRoomId: _actualChatRoomId,
        senderId: _currentUserId,
        senderName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        message: message,
      );
      
      if (success) {
        debugPrint('✅ Message sent successfully');
        await _soundService.playTap();
        
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        debugPrint('❌ Message send returned false');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showCaregiverInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Photo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: widget.caregiverPhotoUrl.isNotEmpty
                      ? Image.network(
                          widget.caregiverPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name
              Text(
                widget.caregiverName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              
              // Email
              Text(
                widget.caregiverEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              
              // Rating
              if (widget.caregiverRating != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.caregiverRating!.toStringAsFixed(1)} Rating',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              
              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isInitializing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _initError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to initialize chat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _initError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isInitializing = true;
                                  _initError = null;
                                });
                                _initializeChatRoom();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _firestoreService.getChatMessages(_actualChatRoomId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            );
                          }

                          if (snapshot.hasError) {
                            debugPrint('Chat stream error: ${snapshot.error}');
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
                                  const SizedBox(height: 8),
                                  Text(
                                    snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => setState(() {}),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final messages = snapshot.data ?? [];

                          if (messages.isEmpty) {
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
                                  const Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Start the conversation',
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

                return ListView.builder(
                  key: const ValueKey('chat-messages'),
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final message = ChatMessageModel.fromMap(
                      messageData,
                      messageData['id'] ?? '',
                    );
                    final isMe = message.senderId == _currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) const SizedBox(width: 40),
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.65,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : AppColors.background,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.textTertiary,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Message options menu (only for own messages)
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              onSelected: (String choice) {
                                if (choice == 'edit') {
                                  _editMessage(message);
                                } else if (choice == 'delete') {
                                  _deleteMessage(message.id);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Edit', style: TextStyle(fontFamily: 'Montserrat')),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(fontFamily: 'Montserrat', color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              offset: const Offset(0, 24),
                            ),
                          ],
                        ],
                      ),
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
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: InkWell(
        onTap: _showCaregiverInfo,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: widget.caregiverPhotoUrl.isNotEmpty
                    ? Image.network(
                        widget.caregiverPhotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.caregiverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Tap for profile',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_rounded, color: AppColors.textPrimary),
          tooltip: 'Call Caregiver',
          onPressed: _makeCall,
        ),
        if (_hasReported)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, 
                    color: AppColors.error, 
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Reported',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.flag_rounded, color: AppColors.error),
            tooltip: 'Report Caregiver',
            onPressed: _reportCaregiver,
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
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
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48, maxHeight: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
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
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
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
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
                      padding: EdgeInsets.zero,
                      tooltip: 'Send message',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _editMessage(ChatMessageModel message) {
    _messageController.text = message.message;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Message',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: _messageController,
          maxLines: 4,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Edit your message...',
            hintStyle: const TextStyle(fontFamily: 'Montserrat', color: AppColors.textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _messageController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Montserrat', color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_messageController.text.trim().isNotEmpty) {
                try {
                  await _firestoreService.updateMessage(
                    _actualChatRoomId,
                    message.id,
                    _messageController.text.trim(),
                  );
                  _soundService.playSuccess();
                  _messageController.clear();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  _soundService.playError();
                  debugPrint('Error updating message: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Update',
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Message',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Montserrat', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Montserrat', color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteMessage(_actualChatRoomId, messageId);
                _soundService.playSuccess();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                _soundService.playError();
                debugPrint('Error deleting message: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    
    return DateFormat('MMM dd').format(dateTime);
  }
}


