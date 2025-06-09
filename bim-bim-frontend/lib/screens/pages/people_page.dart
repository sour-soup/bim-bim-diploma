import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final _apiClient = ApiClient();
  List<Map<String, String?>> _categories = [];
  List<Map<String, dynamic>> _people = [];
  String? _selectedGender;
  int? _selectedCategoryId = 1;
  bool _isDescending = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPeople(_selectedCategoryId);
  }

  Future<void> _sendInvite(String toUserId) async {
  try {
    final response = await _apiClient.post('$baseUrl/chat/invite/$toUserId');

    if (response.statusCode == 200) {
      _showSuccessDialog('Запрос отправлен');
      _fetchPeople(_selectedCategoryId);
    } else {
      throw Exception('Failed to send invite: ${response.body}');
    }
  } catch (e) {
    _showErrorDialog('Error sending invite: $e');
  }
}

void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Успех!'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
  
  Future<void> _fetchCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiClient.get('$baseUrl/category/all');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List<dynamic>;
        setState(() {
          _categories = data.map((e) {
            final category = e as Map<String, dynamic>;
            return {
              'id': category['id']?.toString(),
              'name': category['name'] as String?,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading categories: $e');
    }
  }

  Future<void> _fetchPeople(int? categoryId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiClient.get('$baseUrl/matching/$categoryId');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List<dynamic>;
        setState(() {
          _people = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load people');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading people: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPeople = _people.where((person) {
      if (_selectedGender == null) return true;
      return person['gender'] == _selectedGender;
    }).toList();

    final sortedPeople = List.of(filteredPeople);
    sortedPeople.sort((a, b) => _isDescending
        ? b['similarity'].compareTo(a['similarity'])
        : a['similarity'].compareTo(b['similarity']));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedCategoryId?.toString(),
                    decoration: InputDecoration(
                      labelText: 'Категория',
                      labelStyle: TextStyle(color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value != null ? int.tryParse(value) : null;
                        _fetchPeople(_selectedCategoryId);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Пол',
                      labelStyle: TextStyle(color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFBB86FC)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Все')),
                      DropdownMenuItem(value: 'male', child: Text('Мужчины')),
                      DropdownMenuItem(value: 'female', child: Text('Женщины')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDescending = !_isDescending;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            else if (sortedPeople.isEmpty)
              Center(
                child: Text(
                  'Нет людей в этой категории',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              Expanded(
              child: ListView.builder(
                itemCount: sortedPeople.length,
                itemBuilder: (context, index) {
                  final person = sortedPeople[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        backgroundImage: NetworkImage(person['avatar']),
                      ),
                      title: Text(
                        person['username'],
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Сходство: ${person['similarity']}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.mail,
                              size: 28,
                              color: theme.colorScheme.secondary,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 12,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                           _sendInvite(person['id'].toString());
                        },
                      ),
                      onTap: () {
                        _showPersonDetails(context, person);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showPersonDetails(BuildContext context, Map<String, dynamic> person) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: theme.dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.secondary,
                  backgroundImage: NetworkImage(person['avatar']),
                ),
                const SizedBox(height: 20),
                Text(
                  person['username'],
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Сходство: ${person['similarity']}%',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 10),
                if (person['description'] != null && person['description'].toString().trim().isNotEmpty)
                  Text(
                    person['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _sendInvite(person['id'].toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Пригласить в чат',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}