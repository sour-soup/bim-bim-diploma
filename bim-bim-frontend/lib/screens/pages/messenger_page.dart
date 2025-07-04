import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'messenger/chat_list_item.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final _apiClient = ApiClient();
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;
  String state = "active";

  final Map<String, String> stateLabels = {
    "active": "Чаты",
    "pending-requests": "Входящие запросы",
    "sent-requests": "Исходящие запросы",
  };

  final List<String> states = ["active", "pending-requests", "sent-requests"];
  String _selectedState = "active";

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      isLoading = true;
    });
    try {
      final chatResponse = await _apiClient.get('$baseUrl/chat/$state');

      if (chatResponse.statusCode != 200) {
        throw Exception('Failed to fetch chats');
      }

      final List<dynamic> chatData = json.decode(utf8.decode(chatResponse.bodyBytes));

      final List<Map<String, dynamic>> loadedChats = [];
      for (var chat in chatData) {
        final userId = chat['toUserId'];
        final userResponse = await _apiClient.get('$baseUrl/user/$userId');

        if (userResponse.statusCode != 200) {
          throw Exception('Failed to fetch user info for user $userId');
        }

        final userData = json.decode(utf8.decode(userResponse.bodyBytes));
        
        loadedChats.add({
          'chatId': chat['id'],
          'id': userData['id'],
          'username': userData['username'],
          'avatar': userData['avatar'],
          'description': userData['description'],
        });
      }

      if (mounted) {
        setState(() {
          chats = loadedChats;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptRequest(String chatId) async {
    try {
      final response = await _apiClient.post('$baseUrl/chat/$chatId/accept');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запрос принят!')),
        );
        await _fetchChats();
      } else {
        throw Exception('Failed to accept request: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: theme.hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: theme.cardColor,
              style: theme.textTheme.bodyMedium,
              items: states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(stateLabels[state]!),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedState = value;
                    state = value;
                  });
                  await _fetchChats();
                }
              },
            ),
            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : chats.isEmpty
                      ? Center(
                          child: Text(
                            'Здесь пока пусто',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            return ChatListItem(
                              chat: chat,
                              state: _selectedState,
                              onAccept: _acceptRequest,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}