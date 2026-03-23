import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final String dormId;
  final String name;
  final String description;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.dormId,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  ChatRoom copyWith({
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
    return ChatRoom(
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

  @override
  List<Object?> get props => [
        id,
        dormId,
        name,
        description,
        memberIds,
        createdAt,
        lastMessageAt,
        lastMessage,
        lastMessageSenderId,
        unreadCount,
      ];
}