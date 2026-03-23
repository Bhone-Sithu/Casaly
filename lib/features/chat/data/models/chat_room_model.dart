import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.dormId,
    required super.name,
    required super.description,
    required super.memberIds,
    required super.createdAt,
    required super.lastMessageAt,
    super.lastMessage,
    super.lastMessageSenderId,
    super.unreadCount,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      id: id,
      dormId: map['dormId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      memberIds: List<String>.from(map['memberIds'] as List),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (map['lastMessageAt'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'dormId': dormId,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }

  @override
  ChatRoomModel copyWith({
    String? id,
    String? dormId,
    String? name,
    String? description,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    String? lastMessageSenderId,
    int? unreadCount,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}