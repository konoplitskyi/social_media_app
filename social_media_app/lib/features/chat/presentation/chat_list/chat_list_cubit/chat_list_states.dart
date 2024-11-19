import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:tuple/tuple.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Tuple2<ProfileUser?, Message?>> users;

  ChatListLoaded(
    this.users,
  );
}

class ChatListError extends ChatListState {
  final String message;

  ChatListError(this.message);
}
