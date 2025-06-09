import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'package:bim_bim_app/config/constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiClient _apiClient = ApiClient();

  String _selectedCategory = '';
  List<String> _categories = [];
  Map<String, String> _categoryMap = {};
  bool isLoading = true;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerLeftController = TextEditingController();
  final TextEditingController _answerRightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _apiClient.get('$baseUrl/category/all');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        setState(() {
          _categories = data.map((category) {
            var name = category['name'];
            return name is String ? name : name.toString();
          }).toList();

          _categoryMap = {
            for (var item in data)
              item['name'] is String
                  ? item['name']
                  : item['name'].toString(): item['id'] is String
                      ? item['id']
                      : item['id'].toString()
          };

          if (_categories.isNotEmpty) {
            _selectedCategory = _categories[0];
            isLoading = false;
          }
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendQuestion() async {
    if (_questionController.text.trim().isEmpty ||
        _answerLeftController.text.trim().isEmpty ||
        _answerRightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все поля должны быть заполнены!')),
      );
      return;
    }

    final questionContent = _questionController.text.trim();
    final answerLeft = _answerLeftController.text.trim();
    final answerRight = _answerRightController.text.trim();
    final categoryId = _categoryMap[_selectedCategory];

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Категория не выбрана')),
      );
      return;
    }

    final requestBody = {
      "questionContent": questionContent,
      "answerLeft": answerLeft,
      "answerRight": answerRight,
      "categoryId": categoryId
    };

    try {
      final response = await _apiClient.post(
        '$baseUrl/question/add',
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Question added successfully');
        setState(() {
          _questionController.clear();
          _answerLeftController.clear();
          _answerRightController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вопрос добавлен!')),
        );
      } else {
        print('Failed to add question: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error sending question: $e');
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedCategory.isEmpty ? null : _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Выберите категорию',
                      labelStyle: TextStyle(color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: theme.colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Вопрос',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerLeftController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Ответ 1',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerRightController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Ответ 2',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendQuestion,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                backgroundColor: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.onSurface),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'Создать вопрос',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}