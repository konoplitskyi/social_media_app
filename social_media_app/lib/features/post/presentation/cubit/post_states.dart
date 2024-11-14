import 'package:social_media_app/features/post/domain/entittes/post.dart';

abstract class PostState {}

class PostsInitial extends PostState {}

class PostsLoading extends PostState {}

class PostsUploading extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;

  PostsLoaded(this.posts);
}

class PostsError extends PostState {
  final String message;

  PostsError(this.message);
}
