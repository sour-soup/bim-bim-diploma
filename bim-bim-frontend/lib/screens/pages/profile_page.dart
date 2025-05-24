import 'package:flutter/material.dart';
import 'package:bim_bim_app/constants/constants.dart';
import 'package:bim_bim_app/screens/pages/edit_profile_page.dart';
import 'package:bim_bim_app/services/api_client.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          description = data['description'];
          avatarUrl = data['avatar'];
        });
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
      setState(() {
        avatar = File(pickedFile.path);
      });

      await _uploadAvatarToBackend(File(pickedFile.path));
    }
  }

  Future<void> _uploadAvatarToBackend(File imageFile) async {
    try {
      final file = await http.MultipartFile.fromPath('image', imageFile.path);

      final response = await _apiClient.uploadMultipart(
        endpoint: '$baseUrl/user/updateAvatar', 
        files: [file],
        fields: {'type': 'image'}
      );

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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color(0xFF64FFDA),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(
            color: Color(0xFF64FFDA)),
        elevation: 4,
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
                      backgroundColor:
                          const Color(0xFF64FFDA),
                      backgroundImage: avatar != null
                          ? FileImage(avatar!)
                          : (avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : null) as ImageProvider?,
                      child: (avatar == null && avatarUrl == null)
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.black,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username ?? 'Загрузка...',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description ?? 'Загрузка...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Редактировать',
                    backgroundColor:
                        const Color(0xFF1F2937),
                    shadowColor: const Color(0xFF64FFDA),
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
                    backgroundColor:
                        const Color(0xFF1F2937),
                    shadowColor: const Color(0xFF64FFDA),
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: shadowColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Выход',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Вы точно хотите выйти?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF64FFDA)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64FFDA),
              ),
              child: const Text(
                'Выход',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
