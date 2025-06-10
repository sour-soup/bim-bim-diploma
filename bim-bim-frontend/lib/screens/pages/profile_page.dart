import 'package:bim_bim_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bim_bim_app/config/constants.dart';
import 'package:bim_bim_app/screens/pages/edit_profile_page.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _apiClient = ApiClient();
  final _picker = ImagePicker();
  String? username;
  String? description;
  File? avatar;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await _apiClient.get('$baseUrl/user/profile');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        
        if (mounted) {
          setState(() {
            username = data['username'];
            description = data['description'];
            avatarUrl = data['avatar'];
          });
        }
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          avatar = File(pickedFile.path);
        });
      }
      await _uploadAvatarToBackend(File(pickedFile.path));
    }
  }

  Future<void> _uploadAvatarToBackend(File imageFile) async {
    try {
      final file = await http.MultipartFile.fromPath('image', imageFile.path);

      final response = await _apiClient.uploadMultipart(
          endpoint: '$baseUrl/user/updateAvatar',
          files: [file],
          fields: {'type': 'image'});

      if (response.statusCode == 200) {
        print('Avatar uploaded successfully');
        _fetchUserData();
      } else {
        print('Failed to upload avatar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: avatar != null
                          ? FileImage(avatar!)
                          : (avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : null) as ImageProvider?,
                      child: (avatar == null && avatarUrl == null)
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username ?? 'Загрузка...',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description ?? 'Загрузка...',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildThemeSwitcher(
                    context: context,
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Редактировать',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                      _fetchUserData();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Выход',
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher({
    required BuildContext context,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        title: Text(
          'Тёмная тема',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
          activeColor: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Выход',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Вы точно хотите выйти?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Отмена',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () async { 
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                side: BorderSide.none,
              ),
              child: const Text('Выход'),
            ),
          ],
        );
      },
    );
  }
}