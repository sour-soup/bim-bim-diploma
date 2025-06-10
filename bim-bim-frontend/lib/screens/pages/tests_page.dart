import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:bim_bim_app/config/constants.dart';

class QuestionItem {
  final String id;
  final String content;
  final String answerLeft;
  final String answerRight;

  QuestionItem({
    required this.id,
    required this.content,
    required this.answerLeft,
    required this.answerRight,
  });
}

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final _apiClient = ApiClient();
  String _selectedCategory = '';
  List<String> _categories = [];
  List<Map<String, dynamic>> _questions = [];
  Map<String, String> _categoryMap = {};
  late List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  bool _isLoading = true;

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
        if (mounted) {
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
              _loadAllQuestions(_selectedCategory);
            } else {
              _isLoading = false;
            }
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllQuestions(String categoryName) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _questions.clear();
        _swipeItems.clear();
      });
    }

    final categoryId = _categoryMap[categoryName];
    final intId = int.tryParse(categoryId ?? '0');

    try {
      final response = await _apiClient
          .get('$baseUrl/question/remainderByCategory?categoryId=$intId');
      
      List<Map<String, dynamic>> newQuestions = [];
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List;
        if (data.isNotEmpty) {
           newQuestions = data.map((q) => {
                'id': q['id'],
                'content': q['content'],
                'answerLeft': q['answerLeft'],
                'answerRight': q['answerRight']
              }).toList();
        }
      }
      if (mounted) {
        setState(() {
          _questions = newQuestions;
          if (_questions.isNotEmpty) {
            _initializeSwipeItems();
          }
          _isLoading = false; 
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeSwipeItems() {
    _swipeItems = _questions.map((question) {
      QuestionItem questionItem = QuestionItem(
        id: question['id'].toString(),
        content: question['content'],
        answerLeft: question['answerLeft'],
        answerRight: question['answerRight'],
      );

      return SwipeItem(
        content: questionItem,
        likeAction: () => _onAnswer(questionItem.id, 1),
        nopeAction: () => _onAnswer(questionItem.id, -1),
        superlikeAction: () => _onAnswer(questionItem.id, 0),
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  Future<void> _sendAnswer(String questionId, int value) async {
    try {
      final response = await _apiClient
          .get('$baseUrl/question/setAnswer?questionId=$questionId&result=$value');

      if (response.statusCode == 200) {
        print('Answer saved successfully for question $questionId');
      } else {
        print('Failed to save answer: ${response.body}');
      }
    } catch (e) {
      print('Error saving answer: $e');
    }
  }

  void _onAnswer(String questionId, int answer) async {
    if (_swipeItems.isNotEmpty) {
      await _sendAnswer(questionId, answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Категория',
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
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) async {
                if (value != null && value != _selectedCategory) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  await _loadAllQuestions(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : _questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.done_all,
                                color: Colors.green,
                                size: 64,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Вопросы кончились!',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : SwipeCards(
                          matchEngine: _matchEngine,
                          itemBuilder: (context, index) {
                            final question =
                                _swipeItems[index].content.content as String;
                            final leftOption =
                                _swipeItems[index].content.answerLeft as String;
                            final rightOption =
                                _swipeItems[index].content.answerRight as String;

                            return Container(
                              width: screenWidth * 0.9,
                              height: screenHeight * 0.7,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isDarkMode
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(-5, 5),
                                        ),
                                        BoxShadow(
                                          color: theme.colorScheme.secondary.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(5, 5),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: screenHeight * 0.05,
                                    left: 20,
                                    right: 20,
                                    child: Text(
                                      question,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: question.length > 20 ? 28 : 36,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                        shadows: isDarkMode
                                            ? [
                                                Shadow(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    top: screenHeight * 0.35,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: theme.colorScheme.primary,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          leftOption,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                            shadows: isDarkMode
                                                ? [
                                                    Shadow(
                                                      color: theme.colorScheme.primary,
                                                      blurRadius: 10,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 20,
                                    top: screenHeight * 0.35,
                                    child: Row(
                                      children: [
                                        Text(
                                          rightOption,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.secondary,
                                            shadows: isDarkMode
                                                ? [
                                                    Shadow(
                                                      color: theme.colorScheme.secondary,
                                                      blurRadius: 10,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: theme.colorScheme.secondary,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onStackFinished: () {
                            if (mounted) {
                              setState(() {
                                _questions.clear();
                              });
                            }
                          },
                          upSwipeAllowed: true,
                          fillSpace: true,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}