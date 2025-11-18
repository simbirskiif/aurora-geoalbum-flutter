import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geo_album/image_location.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  void goTo(ImageLocation image) {
    // setState(() {
    //   _initialPos = LatLng(image.latitude!, image.longitude!);
    // });
    controller.move(LatLng(image.latitude!, image.longitude!), _currentZoom);
  }

  double _currentZoom = 10;
  final MapController controller = MapController();
  final LatLng _initialPos = const LatLng(54.351928688579044, 48.3897236601857);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ImageManager>(builder: (context, value, child) {
          final imgs = value.images
              .where((img) => img.latitude != null && img.longitude != null)
              .toList();
          return FlutterMap(
              mapController: controller,
              options: MapOptions(
                  maxZoom: 18,
                  minZoom: 3,
                  initialZoom: _currentZoom,
                  initialCenter: _initialPos),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.app",
                ),
                MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                        maxClusterRadius: 45,
                        size: Size(40, 40),
                        padding: EdgeInsets.all(50),
                        disableClusteringAtZoom: 12,
                        markers: imgs.map((image) {
                          debugPrint(
                              "Отобразить одиночный: ${image.path}, ${image.latitude}, ${image.longitude}");
                          return Marker(
                              point: LatLng(image.latitude!, image.longitude!),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PhotoViewScreen(
                                        goToMap: () {
                                          controller.move(
                                            LatLng(image.latitude!,
                                                image.longitude!),
                                            _currentZoom,
                                          );
                                        },
                                        imageLocation: image);
                                  }));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(image.path),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey,
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ));
                        }).toList(),
                        builder: (context, markers) {
                          final representativeImage = imgs.firstWhere(
                            (img) =>
                                img.latitude == markers.first.point.latitude &&
                                img.longitude == markers.first.point.longitude,
                            orElse: () => imgs.first,
                          );
                          return GestureDetector(
                            onTap: () {
                              _showImageBottomSheet(context, markers, imgs);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.file(
                                    File(representativeImage.path),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey,
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                                  markers.length > 1
                                      ? Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.black54,
                                          child: Center(
                                              child: Text(
                                            markers.length.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )),
                                        )
                                      : Text("")
                                ],
                              ),
                            ),
                          );
                        }))
              ]);
        }),
        Positioned(
            bottom: 150,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "+",
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(3, 18);
                    });
                    controller.move(controller.camera.center, _currentZoom);
                  },
                  child: Text("+"),
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  heroTag: "-",
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(3, 18);
                    });
                    controller.move(controller.camera.center, _currentZoom);
                  },
                  child: Text("-"),
                )
              ],
            ))
      ],
    );
  }

  void _showImageBottomSheet(BuildContext context, List<Marker> markers,
      List<ImageLocation> allImages) {
    final nearbyImages = markers.map((marker) {
      return allImages.firstWhere(
        (img) =>
            img.latitude == marker.point.latitude &&
            img.longitude == marker.point.longitude,
        orElse: () => allImages[0],
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: nearbyImages.length,
            itemBuilder: (context, index) {
              final image = nearbyImages[index];
              return Material(
                // margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: FittedBox(
                    // borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.hardEdge,
                    child: Image.file(
                      File(image.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      cacheWidth: 100,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                  title: Text(image.path.split('/').last),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Широта: ${image.latitude?.toStringAsFixed(6)}'),
                      Text('Долгота: ${image.longitude?.toStringAsFixed(6)}'),
                      if (image.creationDate != null)
                        Text(DateFormat("dd.MM.yyyy в HH:mm")
                            .format(image.creationDate!)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PhotoViewScreen(
                          goToMap: () {
                            setState(() {
                              _currentZoom = 10;
                            });
                            controller.move(
                              LatLng(image.latitude!, image.longitude!),
                              _currentZoom,
                            );
                            Navigator.pop(context);
                          },
                          imageLocation: image);
                    }));
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
