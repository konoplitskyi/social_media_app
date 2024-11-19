import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/chat/domain/repository/chat_repo.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseChatRepo extends ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<List<String>> getChatUsersIdStream() {
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

  @override
  Future<void> sendMesagge(String receiverId, String messageText) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: messageText,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomId = ids.join('_');

    await _firestore.collection('chat_rooms').doc(chatRoomId).set(
      {
        'lastMessage': newMessage.toJson(),
      },
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toJson());
  }

  @override
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    final snapshots = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();

    return snapshots;
  }

  @override
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
