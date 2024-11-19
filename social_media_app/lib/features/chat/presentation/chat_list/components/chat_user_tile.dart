import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/features/chat/domain/entities/message.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/pages/user_chat_page.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';

class ChatUserTile extends StatelessWidget {
  final ProfileUser user;
  final Message? lastMessage;

  const ChatUserTile({
    super.key,
    required this.user,
    required this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(
        lastMessage == null ? '' : lastMessage!.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
      leading: SizedBox(
        height: 40,
        width: 40,
        child: user.profileImageUrl.isEmpty
            ? const Icon(Icons.person)
            : CachedNetworkImage(
                imageUrl: user.profileImageUrl,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.person),
                ),
                imageBuilder: (context, imageProvider) => Container(
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
      trailing: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserChatPage(receiverUser: user),
        ),
      ),
    );
  }
}
