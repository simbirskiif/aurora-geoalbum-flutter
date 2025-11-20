import 'dart:io';

import 'package:flutter/material.dart';

Future<bool> showRenameDialog(BuildContext context, File file) async {
  final originalName = file.uri.pathSegments.last;
  final extension =
      originalName.contains('.') ? '.${originalName.split('.').last}' : '';
  final baseName = extension.isNotEmpty
      ? originalName.substring(0, originalName.length - extension.length)
      : originalName;
  final TextEditingController controller =
      TextEditingController(text: baseName);
  bool success = false;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Переименовать"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: "Новое имя"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final dir = file.parent.path;
                final newBaseName = controller.text.trim();
                final newFile = File("$dir/$newBaseName$extension");

                if (newFile.existsSync()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Файл с таким именем уже существует")));
                  return;
                }
                if (newBaseName.isNotEmpty) {
                  final newFile = File("$dir/$newBaseName$extension");
                  try {
                    file.renameSync(newFile.path);
                    success = true;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Ошибка при переименовании: $e")));
                  }
                }
                Navigator.pop(context);
              },
              child: const Text("Переименовать"),
            ),
          ],
        );
      });
  return success;
}
