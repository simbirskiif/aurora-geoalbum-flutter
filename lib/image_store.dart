import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_album/image_location.dart';

class ImageManager extends ChangeNotifier {
  List<ImageLocation> _images = [];
  bool _isUpdating = false;

  List<ImageLocation> get images => _images;
  bool get isUpdating => _isUpdating;
  Future<void> findAndUpdateImages() async {
    if (_isUpdating) return;
    _isUpdating = true;
    // notifyListeners();
    try {
      final paths = await findImagePathsRecursive();
      _images = await fromPaths(paths);
      notifyListeners();
    } finally {
      _isUpdating = false;
    }
  }
}
