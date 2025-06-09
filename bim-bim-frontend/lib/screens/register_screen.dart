import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _apiClient = ApiClient();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedGender;

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String description = _descriptionController.text;

    if (username.isEmpty || password.isEmpty || _selectedGender == null) {
      _showError('Пожалуйста, заполни все поля!');
      return;
    }

    try {
      final response = await _apiClient.post(
        '$baseUrl/auth/register',
        body: jsonEncode({
          'username': username,
          'password': password,
          'gender': _selectedGender,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 400) {
        _showError('Имя занято!');
      } else {
        _showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to connect to server');
    }
  }

  void _showError(String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          'Ошибка!',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: theme.cardColor,
            elevation: isDarkMode ? 15 : 5,
            shadowColor: isDarkMode ? theme.colorScheme.secondary : Colors.grey.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.secondary,
                    child: Icon(
                      Icons.person_add,
                      size: 50,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Создать аккаунт',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      shadows: isDarkMode ? [
                        Shadow(
                          color: theme.colorScheme.secondary,
                          blurRadius: 10,
                        ),
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: theme.hintColor),
                      prefixIcon:
                          Icon(Icons.person, color: theme.colorScheme.secondary),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: theme.hintColor),
                      prefixIcon:
                          Icon(Icons.lock, color: theme.colorScheme.secondary),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    dropdownColor: theme.cardColor,
                    value: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Пол',
                      labelStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'male',
                        child: Text('Мужской', style: TextStyle(color: theme.colorScheme.onSurface)),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text('Женский', style: TextStyle(color: theme.colorScheme.onSurface)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'О себе',
                      labelStyle: TextStyle(color: theme.hintColor),
                      prefixIcon:
                          Icon(Icons.info_outline, color: theme.colorScheme.secondary),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide.none,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Уже есть аккаунт?',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Войти',
                          style: TextStyle(color: theme.colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}