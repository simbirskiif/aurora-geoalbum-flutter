import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

List<ImageLocation> images = List.empty(growable: true);

Future<void> startFind() async {
  // List<String> paths = await findImagePathsRecursive();
}

class ImageLocation {
  final String path;
  final double? latitude;
  final double? longitude;
  final DateTime? creationDate;

  ImageLocation(
      {required this.path, this.latitude, this.longitude, this.creationDate});

  @override
  String toString() {
    return 'Path: $path, Lat: ${latitude ?? 'N/A'}, Lon: ${longitude ?? 'N/A'}';
  }
}

Future<List<ImageLocation>> fromPaths(List<String> paths) async {
  final List<ImageLocation> result = [];

  for (final path in paths) {
    try {
      final file = File(path);
      final fileBytes = await file.readAsBytes();
      final data = await readExifFromBytes(fileBytes);

      double? lat;
      double? lon;
      DateTime? creationDate;

      try {
        final stat = await file.stat();
        creationDate = stat.modified;
      } catch (e) {
        // debugPrint('Ошибка получения даты для $path: $e');
      }

      if (data.isNotEmpty) {
        final latData = data['GPS GPSLatitude'];
        final latRef = data['GPS GPSLatitudeRef'];
        final lonData = data['GPS GPSLongitude'];
        final lonRef = data['GPS GPSLongitudeRef'];

        lat = _convertToDegree(latData, latRef);
        lon = _convertToDegree(lonData, lonRef);
        // debugPrint('Извлечённые координаты для $path: lat=$lat, lon=$lon');
      }
      result.add(ImageLocation(
        path: path,
        latitude: lat,
        longitude: lon,
        creationDate: creationDate,
      ));
    } catch (e) {
      result.add(ImageLocation(path: path));
    }
  }

  result.sort((a, b) {
    if (a.creationDate == null && b.creationDate == null) return 0;
    if (a.creationDate == null) return 1;
    if (b.creationDate == null) return -1;
    return a.creationDate!.compareTo(b.creationDate!);
  });

  return result;
}

double? _convertToDegree(dynamic value, dynamic ref) {
  if (value == null || ref == null) {
    return null;
  }

  try {
    String valueStr = value.toString().replaceAll(RegExp(r'[\[\]]'), '');
    List<String> parts = valueStr.split(',').map((s) => s.trim()).toList();
    if (parts.length != 3) {
      return null;
    }

    double? deg = _parseExifRational(parts[0]);
    double? min = _parseExifRational(parts[1]);
    double? sec = _parseExifRational(parts[2]);
    if (deg == null || min == null || sec == null) {
      return null;
    }

    double result = deg + (min / 60.0) + (sec / 3600.0);
    if (ref.toString().contains('S') || ref.toString().contains('W')) {
      result = -result;
    }
    return result;
  } catch (e) {
    return null;
  }
}

double? _parseExifRational(String rational) {
  try {
    final nums = rational.split('/').map((s) => s.trim()).toList();
    if (nums.length != 2) {
      return double.tryParse(rational);
    }
    final num = double.parse(nums[0]);
    final den = double.parse(nums[1]);
    return den != 0 ? num / den : 0.0;
  } catch (e) {
    return null;
  }
}

Future<List<String>> findImagePathsRecursive() async {
  final List<String> imagePaths = [];
  try {
    final Directory homeDir = await getApplicationDocumentsDirectory();
    final String picturesPath = '${homeDir.parent.path}/Pictures';
    final Directory picturesDir = Directory(picturesPath);

    if (await picturesDir.exists()) {
      debugPrint("Начинаем рекурсивный поиск в: $picturesPath");

      await _searchDirectory(picturesDir, imagePaths);
    } else {
      debugPrint("Директория не найдена: $picturesPath");
    }
  } on FileSystemException catch (e) {
    debugPrint("Ошибка доступа к файловой системе: $e");
  }

  debugPrint("Найдено ${imagePaths.length} изображений.");
  return imagePaths;
}

Future<void> _searchDirectory(
    Directory directory, List<String> imagePaths) async {
  try {
    final Stream<FileSystemEntity> entities = directory.list();

    await for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final String path = entity.path;
        if (path.toLowerCase().endsWith('.jpg') ||
            path.toLowerCase().endsWith('.jpeg') ||
            path.toLowerCase().endsWith('.png')) {
          imagePaths.add(path);
        }
      } else if (entity is Directory) {
        await _searchDirectory(entity, imagePaths);
      }
    }
  } on FileSystemException catch (e) {
    debugPrint("Ошибка доступа к директории ${directory.path}: $e");
  }
}
