import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/user_chat_cubit/user_chat_cubit.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/components/chat_bubble.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/user_chat_cubit/user_chat_states.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/responsive/constrained_scaffold.dart';

class UserChatPage extends StatefulWidget {
  final ProfileUser receiverUser;

  const UserChatPage({
    super.key,
    required this.receiverUser,
  });

  @override
  State<UserChatPage> createState() => _UserCharPageState();
}

class _UserCharPageState extends State<UserChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final userChatCubit = context.read<UserChatCubit>();
  late final authCubit = context.read<AuthCubit>();

  final ScrollController _scrollController = ScrollController();
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    final String senderId = authCubit.currentUser!.uid;
    userChatCubit.fetchMessages(widget.receiverUser.uid, senderId);

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    myFocusNode.dispose();

    super.dispose();
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await userChatCubit.sendMessage(
        widget.receiverUser.uid,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: Text(widget.receiverUser.name),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: myFocusNode.unfocus,
              child: _buildMessageList(),
            ),
          ),
          _buildUserInput(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocConsumer<UserChatCubit, UserChatState>(
      listener: (context, state) {
        if (state is UserChatLoaded) {
          scrollDown();
        }
      },
      builder: (context, state) {
        if (state is UserChatLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserChatError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is UserChatLoaded) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _buildMessageItem(message);
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );

    // return StreamBuilder(
    //   stream: _chatService.getMessages(widget.receiverUser.uid, senderId),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return const Text('Error');
    //     }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Text('Loading...');
    //     }
    //     if (snapshot.data == null) {
    //       return const Text('No messages');
    //     }
    //     return ListView(
    //       controller: _scrollController,
    //       children:
    //           snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList()
    //             ..insert(
    //               0,
    //               const SizedBox(height: 20),
    //             ),
    //     );
    //   },
    // );
  }

  Widget _buildMessageItem(Message message) {
    bool isCurrentUser = message.senderId == authCubit.currentUser!.uid;

    return ChatBubble(
      message: message.message,
      isCurrentUser: isCurrentUser,
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: MyTextField(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.only(right: 25),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
