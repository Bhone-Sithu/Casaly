import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../entities/chat_room.dart';

abstract class IChatRepository {
  /// Get or create the main chat room for a dorm
  Future<Either<Failure, ChatRoom>> getDormChatRoom(String dormId);

  /// Get messages for the dorm chat room
  Stream<Either<Failure, List<Message>>> getDormMessages(String dormId);

  /// Send a text message to the dorm chat
  Future<Either<Failure, void>> sendMessage({
    required String dormId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
  });

  /// Mark messages as read for a user in the dorm chat
  Future<Either<Failure, void>> markMessagesAsRead({
    required String dormId,
    required String userId,
  });

  /// Get unread message count for a user in the dorm chat
  Stream<Either<Failure, int>> getUnreadMessageCount({
    required String dormId,
    required String userId,
  });
}