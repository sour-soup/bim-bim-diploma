import 'package:flutter/material.dart';
import 'chat_tile.dart';

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String state;

  const ChatListItem({super.key, required this.chat, required this.state});

  @override
  Widget build(BuildContext context) {
    return ChatTile(
      chat: chat,
      state: state,
    );
  }
}
