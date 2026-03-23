import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/firebase_chat_repository.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';

// Repository provider
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return FirebaseChatRepository();
});

// Dorm chat room provider
final dormChatRoomProvider = FutureProvider.family<ChatRoom, String>((ref, dormId) async {
  final repository = ref.watch(chatRepositoryProvider);
  final result = await repository.getDormChatRoom(dormId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (chatRoom) => chatRoom,
  );
});

// Messages provider for a specific dorm
final dormMessagesProvider = StreamProvider.family<List<Message>, String>((ref, dormId) {
  final repository = ref.watch(chatRepositoryProvider);
  final stream = repository.getDormMessages(dormId);
  
  return stream.map((either) => either.fold(
    (failure) => throw Exception(failure.message),
    (messages) => messages,
  ));
});

// Unread messages count provider
final unreadMessagesProvider = StreamProvider.family<int, ({String dormId, String userId})>((ref, params) {
  final repository = ref.watch(chatRepositoryProvider);
  final stream = repository.getUnreadMessageCount(
    dormId: params.dormId, 
    userId: params.userId,
  );
  
  return stream.map((either) => either.fold(
    (failure) => throw Exception(failure.message),
    (count) => count,
  ));
});

// Provider for sending messages
final sendMessageProvider = Provider<Future<void> Function({
  required String dormId,
  required String senderId,
  required String senderName,
  required String content,
  MessageType type,
})>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  
  return ({
    required String dormId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final result = await repository.sendMessage(
      dormId: dormId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
    );
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  };
});

// Provider for marking messages as read
final markMessagesAsReadProvider = Provider<Future<void> Function({
  required String dormId,
  required String userId,
})>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  
  return ({
    required String dormId,
    required String userId,
  }) async {
    final result = await repository.markMessagesAsRead(
      dormId: dormId,
      userId: userId,
    );
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  };
});