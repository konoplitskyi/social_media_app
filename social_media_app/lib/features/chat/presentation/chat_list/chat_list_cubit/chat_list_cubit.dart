import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:social_media_app/features/chat/domain/repository/chat_repo.dart';
import 'package:social_media_app/features/chat/presentation/chat_list/chat_list_cubit/chat_list_states.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/domain/repository/profile_repo.dart';
import 'package:tuple/tuple.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepo chatRepo;
  final ProfileRepo profileRepo;

  ChatListCubit({
    required this.chatRepo,
    required this.profileRepo,
  }) : super(ChatListInitial());

  Future<void> fetchChatUsers(String senderId) async {
    try {
      emit(ChatListLoading());
      chatRepo.getChatUsersIdStream().listen(
        (ids) async {
          if (ids.isEmpty) {
            emit(ChatListError('No chat with users'));
            return;
          }

          final users = await Future.wait(
            ids.map((uid) async {
              final ProfileUser? user = await profileRepo.fetchUserProfile(uid);
              final Message? message =
                  await chatRepo.getLastMessage(user!.uid, senderId);

              return Tuple2(user, message);
            }),
          );

          emit(ChatListLoaded(users));
        },
        onError: (error) {
          emit(ChatListError(error.toString()));
        },
      );
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
