import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String chatName;
  final int chatId;
  final String avatar;

  const ChatPage(
      {super.key,
      required this.chatName,
      required this.chatId,
      required this.avatar});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool isLoading = true;
  Timer? _updateTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages(isInitialLoad: true);

    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _uploadImage(XFile imageFile) async {
    try {
      final file = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );

      final response = await _apiClient.uploadMultipart(
          endpoint: '$baseUrl/chat/${widget.chatId}/uploadImage',
          files: [file],
          fields: {'type': 'image'});

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      // Уведомления об ошибках убраны
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        await _uploadImage(pickedFile);
      }
    } catch (e) {
      // Уведомления об ошибках убраны
    }
  }

  Future<void> _loadMessages({bool isInitialLoad = false}) async {
    try {
      final response =
          await _apiClient.get('$baseUrl/chat/${widget.chatId}/messages');

      if (response.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      if (!mounted) return;

      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);

      if (data.length == _messages.length && !isInitialLoad) {
        return;
      }

      bool shouldScroll = false;
      if (isInitialLoad) {
        shouldScroll = true;
      } else if (_scrollController.hasClients) {
        final position = _scrollController.position;
        bool isAtBottom = (position.maxScrollExtent - position.pixels) <= 50.0;
        if (isAtBottom) {
          shouldScroll = true;
        }
      }

      setState(() {
        _messages = data.map((message) {
          return {
            'isMe': message['isMe'],
            'content': message['content'],
            'image': message['image'],
          };
        }).toList();
        if (isInitialLoad) {
          isLoading = false;
        }
      });
      
      if (shouldScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      final response = await _apiClient.post(
          '$baseUrl/chat/${widget.chatId}/messages',
          body: _controller.text.trim());

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': true,
            'content': _controller.text.trim(),
            'image': null,
          });
          _controller.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      // Уведомления об ошибках убраны
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.chatName),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['isMe'];
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isMe
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.colorScheme.secondary.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          child: message['image'] != null
                              ? Image.network(
                                  message['image'],
                                  fit: BoxFit.cover,
                                )
                              : Text(
                                  message['content'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo, color: theme.colorScheme.onSurface),
                  onPressed: _pickImage,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}