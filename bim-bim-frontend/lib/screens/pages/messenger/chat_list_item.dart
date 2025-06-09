import 'package:flutter/material.dart';
import 'chat_tile.dart';

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String state;
  final Future<void> Function(String)? onAccept;

  const ChatListItem({
    super.key, 
    required this.chat, 
    required this.state,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTile(
      chat: chat,
      state: state,
      onAccept: onAccept,
    );
  }
}