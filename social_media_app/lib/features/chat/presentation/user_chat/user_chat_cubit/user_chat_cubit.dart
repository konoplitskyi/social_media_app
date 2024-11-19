import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:social_media_app/features/chat/domain/repository/chat_repo.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/user_chat_cubit/user_chat_states.dart';

class UserChatCubit extends Cubit<UserChatState> {
  final ChatRepo chatRepo;

  UserChatCubit({
    required this.chatRepo,
  }) : super(UserChatInitial());

  Future<void> sendMessage(String receiverId, String messageText) async {
    try {
      chatRepo.sendMesagge(receiverId, messageText);
    } catch (e) {
      emit(UserChatError('Failed to send message: $e'));
    }
  }

  Future<void> fetchMessages(String receiverId, String senderId) async {
    try {
      emit(UserChatLoading());
      chatRepo.getMessages(receiverId, senderId).listen(
        (snapshot) {
          if (snapshot.docs.isEmpty) {
            emit(UserChatError('No messages'));
          } else {
            final messages = snapshot.docs
                .map((doc) =>
                    Message.fromJson(doc.data() as Map<String, dynamic>))
                .toList();

            emit(UserChatLoaded(messages));
          }
        },
        onError: (error) {
          emit(UserChatError(error.toString()));
        },
      );
    } catch (e) {
      emit(UserChatError(e.toString()));
    }
  }
}
