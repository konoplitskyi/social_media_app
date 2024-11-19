import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/chat/presentation/chat_list/chat_list_cubit/chat_list_cubit.dart';
import 'package:social_media_app/features/chat/presentation/chat_list/chat_list_cubit/chat_list_states.dart';
import 'package:social_media_app/features/chat/presentation/chat_list/components/chat_user_tile.dart';
import 'package:social_media_app/responsive/constrained_scaffold.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final chatListCubit = context.read<ChatListCubit>();
  late final authCubit = context.read<AuthCubit>();

  @override
  void initState() {
    final String senderId = authCubit.currentUser!.uid;
    chatListCubit.fetchChatUsers(senderId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<ChatListCubit, ChatListState>(
      builder: (context, state) {
        if (state is ChatListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatListError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is ChatListLoaded) {
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return ChatUserTile(
                user: user.item1!,
                lastMessage: user.item2,
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );

    // return StreamBuilder(
    //   stream: chatService.getUsersIdStream(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return const Text('Error');
    //     }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Text('Loading...');
    //     }

    //     final List<String> userIds = snapshot.data ?? [];

    //     return ListView.builder(
    //       itemCount: userIds.length,
    //       itemBuilder: (context, index) {
    //         final String uid = userIds[index];

    //         return FutureBuilder<ProfileUser?>(
    //           future: profileCubit.getUserProfile(uid),
    //           builder: (context, userSnapshot) {
    //             if (userSnapshot.connectionState == ConnectionState.waiting) {
    //               return const LoadingUserTile();
    //               // return const ListTile(
    //               //   title: Text('Loading user...'),
    //               // );
    //             }
    //             if (userSnapshot.hasError || userSnapshot.data == null) {
    //               return const ListTile(
    //                 title: Text('Error loading user'),
    //               );
    //             }

    //             final ProfileUser user = userSnapshot.data!;
    //             String senderId = authCubit.currentUser!.uid;

    //             return FutureBuilder<Message?>(
    //               future: chatService.getLastMessage(user.uid, senderId),
    //               builder: (context, userSnapshot) {
    //                 if (userSnapshot.connectionState ==
    //                     ConnectionState.waiting) {
    //                   return ChatUserTile(
    //                     user: user,
    //                     lastMessage: null,
    //                   );

    //                   // return const ListTile(
    //                   //   title: Text('Loading last message...'),
    //                   // );
    //                 }
    //                 if (userSnapshot
    //                     .hasError /* || userSnapshot.data == null */) {
    //                   return const ListTile(
    //                     title: Text('Error loading last message'),
    //                   );
    //                 }

    //                 final Message? message = userSnapshot.data;

    //                 return ChatUserTile(
    //                   user: user,
    //                   lastMessage: message,
    //                 );
    //               },
    //             );
    //           },
    //         );
    //       },
    //     );
    //   },
    // );
  }
}
