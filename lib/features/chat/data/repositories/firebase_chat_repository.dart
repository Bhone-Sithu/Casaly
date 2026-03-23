import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;

  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, ChatRoom>> getDormChatRoom(String dormId) async {
    try {
      // Try to get existing dorm chat room
      final query = await _firestore
          .collection(FirestorePaths.chatRooms)
          .where('dormId', isEqualTo: dormId)
          .where('name', isEqualTo: 'General Chat')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Chat room exists, return it
        final chatRoom = ChatRoomModel.fromFirestore(query.docs.first);
        return Right(chatRoom);
      }

      // Chat room doesn't exist, create it
      final now = DateTime.now();
      final chatRoomData = ChatRoomModel(
        id: '',
        dormId: dormId,
        name: 'General Chat',
        description: 'Main chat room for all dorm members',
        memberIds: [], // Will be populated when messages are sent
        createdAt: now,
        lastMessageAt: now,
        unreadCount: 0,
      ).toMap();

      final docRef = await _firestore
          .collection(FirestorePaths.chatRooms)
          .add(chatRoomData);

      final chatRoom = ChatRoomModel.fromMap(chatRoomData, docRef.id);
      return Right(chatRoom);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get dorm chat room: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> getDormMessages(String dormId) {
    try {
      return _firestore
          .collection(FirestorePaths.chatRooms)
          .where('dormId', isEqualTo: dormId)
          .where('name', isEqualTo: 'General Chat')
          .snapshots()
          .asyncMap((chatRoomSnapshot) async {
        try {
          if (chatRoomSnapshot.docs.isEmpty) {
            // No chat room yet, return empty list
            return Right<Failure, List<Message>>([]);
          }

          final chatRoomId = chatRoomSnapshot.docs.first.id;
          final messagesSnapshot = await _firestore
              .collection(FirestorePaths.chatRooms)
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .get();

          final messages = messagesSnapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
          
          return Right<Failure, List<Message>>(messages);
        } catch (e) {
          return Left<Failure, List<Message>>(
            ServerFailure('Failed to get messages: $e'),
          );
        }
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get messages stream: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String dormId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
  }) async {
    try {
      // First, ensure the chat room exists
      final chatRoomResult = await getDormChatRoom(dormId);
      if (chatRoomResult.isLeft()) {
        return chatRoomResult.fold(
          (failure) => Left(failure),
          (r) => const Right(null),
        );
      }

      final chatRoom = chatRoomResult.getOrElse(() => throw Exception());
      final now = DateTime.now();
      
      final messageData = MessageModel(
        id: '', // Firestore will generate this
        chatRoomId: chatRoom.id,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        timestamp: now,
        isRead: false,
      ).toMap();

      // Use batch to update both message and chat room
      final batch = _firestore.batch();

      // Add message to messages subcollection
      final messageRef = _firestore
          .collection(FirestorePaths.chatRooms)
          .doc(chatRoom.id)
          .collection('messages')
          .doc();

      batch.set(messageRef, messageData);

      // Update chat room with latest message info and add sender to memberIds if not already there
      final chatRoomRef = _firestore
          .collection(FirestorePaths.chatRooms)
          .doc(chatRoom.id);

      batch.update(chatRoomRef, {
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'lastMessageAt': Timestamp.fromDate(now),
        'memberIds': FieldValue.arrayUnion([senderId]),
      });

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String dormId,
    required String userId,
  }) async {
    try {
      // Get the dorm chat room first
      final chatRoomResult = await getDormChatRoom(dormId);
      if (chatRoomResult.isLeft()) {
        return chatRoomResult.fold(
          (failure) => Left(failure),
          (r) => const Right(null),
        );
      }

      final chatRoom = chatRoomResult.getOrElse(() => throw Exception());
      
      final query = await _firestore
          .collection(FirestorePaths.chatRooms)
          .doc(chatRoom.id)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        final data = doc.data();
        // Only mark messages from other users as read
        if (data['senderId'] != userId) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to mark messages as read: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, int>> getUnreadMessageCount({
    required String dormId,
    required String userId,
  }) {
    try {
      return _firestore
          .collection(FirestorePaths.chatRooms)
          .where('dormId', isEqualTo: dormId)
          .where('name', isEqualTo: 'General Chat')
          .snapshots()
          .asyncMap((snapshot) async {
        try {
          if (snapshot.docs.isEmpty) {
            return Right<Failure, int>(0);
          }

          final chatRoomId = snapshot.docs.first.id;
          final unreadQuery = await _firestore
              .collection(FirestorePaths.chatRooms)
              .doc(chatRoomId)
              .collection('messages')
              .where('senderId', isNotEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

          return Right<Failure, int>(unreadQuery.docs.length);
        } catch (e) {
          return Left<Failure, int>(
            ServerFailure('Failed to count unread messages: $e'),
          );
        }
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get unread count stream: $e')),
      );
    }
  }
}