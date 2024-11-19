import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/pages/user_chat_page.dart';
import 'package:social_media_app/features/post/presentation/components/post_tile.dart';
import 'package:social_media_app/features/post/presentation/cubit/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubit/post_states.dart';
import 'package:social_media_app/features/profile/presentation/components/bio_box.dart';
import 'package:social_media_app/features/profile/presentation/components/chat_button.dart';
import 'package:social_media_app/features/profile/presentation/components/follow_button.dart';
import 'package:social_media_app/features/profile/presentation/components/profile_stats.dart';
import 'package:social_media_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/cubit/profile_states.dart';
import 'package:social_media_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_media_app/features/profile/presentation/pages/follower_page.dart';
import 'package:social_media_app/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;

  int postCount = 0;

  @override
  void initState() {
    super.initState();

    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() async {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistically update ui
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError(
      (error) {
        // revert update if there's an error
        setState(() {
          if (isFollowing) {
            profileUser.followers.add(currentUser!.uid);
          } else {
            profileUser.followers.remove(currentUser!.uid);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.settings),
                  )
              ],
            ),
            body: ListView(
              children: [
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: user.profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : CachedNetworkImage(
                            imageUrl: user.profileImageUrl,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                ProfileStats(
                  postCount: postCount,
                  followersCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowerPage(
                        followers: user.followers,
                        following: user.following,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                if (!isOwnPost)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: FollowButton(
                            onPressed: followButtonPressed,
                            isFollowing:
                                user.followers.contains(currentUser!.uid),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: ChatButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserChatPage(receiverUser: user),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                BioBox(text: user.bio),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostsLoaded) {
                      final userPosts = state.posts
                          .where((post) => post.userId == widget.uid)
                          .toList();

                      postCount = userPosts.length;

                      return ListView.builder(
                        itemCount: postCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final post = userPosts[index];

                          return PostTile(
                            post: post,
                            onDeletePressed: () =>
                                context.read<PostCubit>().deletePost(post.id),
                          );
                        },
                      );
                    } else if (state is PostsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return const Center(
                        child: Text('No posts...'),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text('No profile found...'),
          );
        }
      },
    );
  }
}
