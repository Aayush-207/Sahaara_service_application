import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Message Model
/// Represents a single message in a chat conversation
class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.parse(map['timestamp']))
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }
}

/// Chat Room Model
/// Represents a conversation between two users
class ChatRoomModel {
  final String id;
  final String ownerId;
  final String caregiverId;
  final String ownerName;
  final String caregiverName;
  final String? caregiverPhotoUrl;
  final String? caregiverEmail;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final int unreadCount;

  ChatRoomModel({
    required this.id,
    required this.ownerId,
    required this.caregiverId,
    required this.ownerName,
    required this.caregiverName,
    this.caregiverPhotoUrl,
    this.caregiverEmail,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
      caregiverPhotoUrl: map['caregiverPhotoUrl'],
      caregiverEmail: map['caregiverEmail'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] is Timestamp
              ? (map['lastMessageAt'] as Timestamp).toDate()
              : DateTime.parse(map['lastMessageAt']))
          : DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'caregiverId': caregiverId,
      'ownerName': ownerName,
      'caregiverName': caregiverName,
      'caregiverPhotoUrl': caregiverPhotoUrl,
      'caregiverEmail': caregiverEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
    };
  }
}
