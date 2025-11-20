import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> saveToFileWithoutEditingName(String path, Uint8List data) async {
  final File file = File(path);
  final image = img.decodeImage(data);
  await file.writeAsBytes(img.encodeJpg(image!, quality: 85));
  debugPrint("Saved");
}

Future<void> saveToFileWithDateAndTime(String path, Uint8List data) async {
  final image = img.decodeImage(data);
  await getDateAndTimeName(path)
      .writeAsBytes(img.encodeJpg(image!, quality: 85));
  debugPrint("Saved");
}

File getDateAndTimeName(String path) {
  String suffix = DateFormat("dd.MM.yyyy в HH:mm:ss").format(DateTime.now());
  final File file = File("${path.substring(0, path.length - 4)}-$suffix.jpg");
  return file;
}
String getDateAndTimeNameString(String path) {
  String suffix = DateFormat("dd.MM.yyyy в HH:mm:ss").format(DateTime.now());
  return "${path.substring(0, path.length - 4)}-$suffix.jpg";
}
