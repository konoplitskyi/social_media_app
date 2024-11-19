import 'package:social_media_app/features/chat/domain/entities/message.dart';

abstract class UserChatState {}

class UserChatInitial extends UserChatState {}

class UserChatLoading extends UserChatState {}

class UserChatLoaded extends UserChatState {
  final List<Message> messages;

  UserChatLoaded(this.messages);
}

class UserChatError extends UserChatState {
  final String message;

  UserChatError(this.message);
}
