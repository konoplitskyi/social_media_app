import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';

abstract class ChatRepo {
  Future<Message?> getLastMessage(String userId, String otherUserId);
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId);
  Future<void> sendMesagge(String receiverId, String messageText);
  Stream<List<String>> getChatUsersIdStream();
}
