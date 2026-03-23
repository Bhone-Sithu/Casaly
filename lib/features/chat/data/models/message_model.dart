import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.chatRoomId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.type,
    required super.timestamp,
    super.isRead,
    super.imageUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatRoomId: map['chatRoomId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  @override
  MessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}