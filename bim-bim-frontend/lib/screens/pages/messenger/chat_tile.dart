import 'package:flutter/material.dart';
import 'package:bim_bim_app/constants/constants.dart';
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
  Color backgroundColor = const Color(0xFF1E1E1E);

  return StatefulBuilder(
    builder: (context, setState) => Container(
      decoration: BoxDecoration(
        color: isDeclined ? Colors.red : backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(chat['avatar']),
          backgroundColor: const Color(0xFF64FFDA),
        ),
        title: Text(
          chat['username'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: const Text(
          'Нажми, чтобы открыть чат',
          style: TextStyle(
            color: Colors.white70,
          ),
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
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text(
                          'Удалить чат?',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            child: const Text(
                              'Нет',
                              style: TextStyle(color: Colors.white70),
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
                                    SnackBar(content: Text('Ошибка при отклонении запроса: ${response.body}')),
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
  Color backgroundColor = const Color(0xFF2C2C2C);

  return StatefulBuilder(
    builder: (context, setState) => Container(
      decoration: BoxDecoration(
        color: actionCompleted ? backgroundColor : const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64FFDA), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(chat['avatar']),
          backgroundColor: const Color(0xFF64FFDA),
        ),
        title: Text(
          chat['username'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: const Text(
          'Входящие запросы',
          style: TextStyle(
            color: Colors.white70,
          ),
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
                            backgroundColor = const Color(0xFF1D4E3F);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Запрос принят')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка при принятии запроса: ${response.body}')),
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
                            backgroundColor = const Color(0xFF5C1D1D);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Запрос отклонен')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка при отклонении запроса: ${response.body}')),
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
        onTap: () {
        },
      ),
    ),
  );
}


  Widget _buildSentRequestChat(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF003C8F),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBB86FC), width: 2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFBB86FC).withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat['avatar']),
        backgroundColor: const Color(0xFFBB86FC),
      ),
      title: Text(
        chat['username'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: const Text(
        'Исходящие запросы',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      onTap: () {
      },
    ),
  );
}
}
