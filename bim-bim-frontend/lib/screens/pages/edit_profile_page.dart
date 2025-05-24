import 'package:flutter/material.dart';
import 'package:bim_bim_app/constants/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _apiClient = ApiClient();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 'I am soup';
  }

  Future<void> _updateDescription() async {
    final description = _controller.text.trim();
    if (description.isEmpty) {
      _showMessage('Описание не может быть пустым', isError: true);
      return;
    }

    try {
      final response = await _apiClient.post('$baseUrl/user/setDescription', body: description);

      if (response.statusCode == 200) {
        _showMessage('Описание обновлено!');
        Navigator.pop(context);
      } else {
        _showMessage('Ошибка при обновлении!', isError: true);
      }
    } catch (_) {
      _showMessage('Ошибка при обновлении!', isError: true);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать описание'),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFF64FFDA)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'О себе',
                labelStyle: TextStyle(color: Colors.white70),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF64FFDA)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateDescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64FFDA),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Сохранить', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
