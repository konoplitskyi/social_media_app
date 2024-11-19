import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<String>> getUsersIdStream() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore.collection('chat_rooms').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.id)
          .where((chatRoomId) => chatRoomId.contains(currentUserId))
          .map((chatRoomId) {
        final List<String> ids = chatRoomId.split('_');

        return ids.firstWhere(
          (id) => id != currentUserId,
          orElse: () => 'Not found',
        );
      }).toList();
    });
  }

  Future<Message?> getLastMessage(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final doc =
          await _firestore.collection('chat_rooms').doc(chatRoomId).get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final Message message =
              Message.fromJson(data['lastMessage'] as Map<String, dynamic>);

          return message;
        }
      }

      return null;
    } catch (e) {
      throw Exception(e);
    }
  }
}
