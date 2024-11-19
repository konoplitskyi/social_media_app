import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  final void Function()? onPressed;

  const ChatButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MaterialButton(
        onPressed: onPressed,
        padding: const EdgeInsets.all(20),
        color: Colors.green,
        child: Text(
          'Chat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
