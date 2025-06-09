import 'package:flutter/material.dart';

void showUserProfileDialog({
  required BuildContext context,
  required Map<String, dynamic> person,
  Future<void> Function(String)? onInvite,
  Future<void> Function(String)? onAccept,
}) {
  final theme = Theme.of(context);
  final userId = person['id']?.toString();
  final chatId = person['chatId']?.toString();

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
                backgroundImage: person['avatar'] != null ? NetworkImage(person['avatar']) : null,
              ),
              const SizedBox(height: 20),
              Text(
                person['username'] ?? 'No name',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              if (person.containsKey('similarity') && person['similarity'] != null)
                Text(
                  'Сходство: ${person['similarity']}%',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                ),
              const SizedBox(height: 10),
              if (person.containsKey('description') && person['description'] != null && person['description'].toString().trim().isNotEmpty)
                Text(
                  person['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (onInvite != null && userId != null)
                ElevatedButton(
                  onPressed: () {
                    onInvite(userId);
                    Navigator.pop(context);
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
              if (onAccept != null && chatId != null)
                ElevatedButton(
                  onPressed: () {
                    onAccept(chatId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Принять запрос',
                    style: TextStyle(
                      color: Colors.white,
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