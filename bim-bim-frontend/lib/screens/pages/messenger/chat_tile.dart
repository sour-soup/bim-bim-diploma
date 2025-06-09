import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';
import '../chat_page.dart';

class ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String state;

  const ChatTile({super.key, required this.chat, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case 'active':
        return _buildActiveChat(context);
      case 'pending-requests':
        return _buildPendingRequestChat(context);
      case 'sent-requests':
        return _buildSentRequestChat(context);
      default:
        return _buildActiveChat(context);
    }
  }

  Widget _buildActiveChat(BuildContext context) {
    final apiClient = ApiClient();
    bool isDeclined = false;
    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: isDeclined ? Colors.red.withOpacity(0.3) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['avatar']),
            backgroundColor: theme.colorScheme.primary,
          ),
          title: Text(
            chat['username'],
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Нажми, чтобы открыть чат',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: isDeclined
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: theme.dialogBackgroundColor,
                          title: Text(
                            'Удалить чат?',
                            style: theme.textTheme.titleLarge,
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                'Нет',
                                style: TextStyle(color: theme.hintColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Да',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  final response = await apiClient.post('$baseUrl/chat/${chat['id']}/decline');
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      isDeclined = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Чат отклонен')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Ошибка: ${response.body}')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
          onTap: () {
            if (!isDeclined) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(chatName: chat['username'], chatId: chat['id'], avatar: chat['avatar']),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPendingRequestChat(BuildContext context) {
    final apiClient = ApiClient();
    bool actionCompleted = false;
    Color? finalColor;
    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: finalColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['avatar']),
            backgroundColor: theme.colorScheme.primary,
          ),
          title: Text(
            chat['username'],
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Входящий запрос',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: actionCompleted
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        try {
                          final response = await apiClient.post('$baseUrl/chat/${chat['id']}/accept');
                          if (response.statusCode == 200) {
                            setState(() {
                              actionCompleted = true;
                              finalColor = Colors.green.withOpacity(0.2);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Запрос принят')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: ${response.body}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        try {
                          final response = await apiClient.post('$baseUrl/chat/${chat['id']}/decline');
                          if (response.statusCode == 200) {
                            setState(() {
                              actionCompleted = true;
                              finalColor = Colors.red.withOpacity(0.2);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Запрос отклонен')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: ${response.body}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSentRequestChat(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(chat['avatar']),
          backgroundColor: theme.colorScheme.secondary,
        ),
        title: Text(
          chat['username'],
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Исходящий запрос',
          style: theme.textTheme.bodyMedium,
        ),
        onTap: () {},
      ),
    );
  }
}