class ImageLocation {
  final String path;
  final double? latitude;
  final double? longitude;
  final DateTime? creationDate;

  ImageLocation({
    required this.path,
    this.latitude,
    this.longitude,
    this.creationDate,
  });

  @override
  String toString() {
    return 'Path: $path, Lat: ${latitude ?? 'N/A'}, Lon: ${longitude ?? 'N/A'}';
  }
}
