import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileUser profileUser;

  ProfileLoaded(this.profileUser);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
