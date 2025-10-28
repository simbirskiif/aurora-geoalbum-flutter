import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/image_location.dart';
import 'package:flutter_application_1/image_store.dart';
import 'package:flutter_application_1/photo_view.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ImageManager(),
    child: const Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final GlobalKey<_MapScreenState> mapKey = GlobalKey<_MapScreenState>();

  int _selectedScreen = 0;
  List<Widget> get _screens {
    return <Widget>[
      KeepAliveWrapper(child: GalleryScreen(
        goToMap: (image) {
          mapKey.currentState?.goTo(image);
          setState(() {
            _selectedScreen = 1;
          });
        },
      )),
      KeepAliveWrapper(
          child: MapScreen(
        key: mapKey,
      ))
    ];
  }

  String t = "Поиск....";
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ImageManager>(context, listen: false)
            .findAndUpdateImages());
    // load();
    // printTest();
    // _imagePathsFuture = findImagePaths();
    // ignore: unused_local_variable
  }

  Future<void> load() async {
    // setState(() {
    //   t = "Поиск...";
    // });
    // findImagePathsRecursive().then((paths) async {
    //   images = await fromPaths(paths);
    //   if (mounted) {
    //     setState(() {
    //       int a = images.length;
    //       t = "Найдено: $a изображений";
    //     });
    //   }
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ImageManager>(context, listen: false)
            .findAndUpdateImages());
  }

  Future<void> printTest() async {
    List<String> imagePath = await findImagePathsRecursive();
    for (final s in imagePath) {
      debugPrint(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.system,
        theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.deepOrange,
            primaryColor: Colors.deepOrange),
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(
                  icon: Icon(Icons.image), label: "Списком"),
              NavigationDestination(icon: Icon(Icons.map), label: "На карте")
            ],
            selectedIndex: _selectedScreen,
            // currentIndex: _selectedScreen,
            onDestinationSelected: (value) {
              setState(() {
                _selectedScreen = value;
              });
            },
            // items: [
            //   BottomNavigationBarItem(
            //       icon: Icon(Icons.image), label: "Изображения"),
            //   BottomNavigationBarItem(icon: Icon(Icons.map), label: "На карте")
            // ],
          ),
          appBar: AppBar(
            title: Text("ГеоАльбом"),
            actions: [
              IconButton(
                  onPressed: () {
                    load();
                  },
                  icon: Icon(Icons.restart_alt))
            ],
          ),
          body: IndexedStack(
            index: _selectedScreen,
            children: _screens,
          ),
        ));
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.goToMap});

  final void Function(ImageLocation image)? goToMap;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 150).floor().clamp(2, 4);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Consumer<ImageManager>(
            builder: (context, value, child) {
              return Text(value.isUpdating
                  ? "Поиск..."
                  : "Найдено ${value.images.length} изображений");
            },
          ),
        ),
        Expanded(
            child: Consumer<ImageManager>(builder: (context, value, child) {
          return value.isUpdating
              ? const Center(child: CircularProgressIndicator())
              : value.images.isEmpty
                  ? const Center(
                      child: Text("Не найдено изображений"),
                    )
                  : GridView.builder(
                      itemCount: value.images.length,
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1),
                      itemBuilder: (context, index) {
                        final image = value.images[index];
                        return GridTile(
                            child: GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PhotoViewScreen(
                                  goToMap: () {
                                    widget.goToMap!(value.images[index]);
                                  },
                                  imageLocation: image);
                            }));
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: Column(
                                children: [
                                  Expanded(
                                      child: Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                    cacheWidth: 150,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  )),
                                  Text(
                                    image.path.split("/").last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(image.creationDate != null
                                      ? image.creationDate!
                                          .toIso8601String()
                                          .split("T")[0]
                                      : "Неизвестно")
                                ],
                              )),
                              image.latitude == null && image.longitude == null
                                  ? Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Icon(
                                        Icons.location_off,
                                        color: Colors.redAccent,
                                      ))
                                  : Text("")
                            ],
                          ),
                        ));
                      });
        })),
        // Padding(
        //   padding: const EdgeInsets.all(8),
        //   child: Consumer<ImageManager>(builder: (context, value, child) {
        //     return ElevatedButton(
        //         onPressed: () {
        //           value.isUpdating ? null : value.findAndUpdateImages();
        //         },
        //         child: const Text("Найти изображения"));
        //   }),
        // )
      ],
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
                // MarkerLayer(
                //     markers: value.images
                //         .asMap()
                //         .entries
                //         .where((entry) =>
                //             entry.value.latitude != null &&
                //             entry.value.longitude != null)
                //         .map((entry) {
                //   debugPrint(
                //       "${entry.value.latitude} ${entry.value.longitude}");
                //   final index = entry.key;
                //   final image = entry.value;
                //   return Marker(
                //       point: LatLng(image.latitude!, image.longitude!),
                //       width: 40,
                //       height: 40,
                //       child: GestureDetector(
                //         onTap: () {
                //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //               content: Text(
                //                   "Изображение: ${image.path.split("/").last}")));
                //         },
                //         child: Container(
                //           decoration: BoxDecoration(
                //               color: Colors.amber,
                //               shape: BoxShape.circle,
                //               border:
                //                   Border.all(color: Colors.white, width: 2)),
                //           child: Center(
                //             child: Text(
                //               "${index + 1}",
                //               style: TextStyle(
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold),
                //             ),
                //           ),
                //         ),
                //       ));
                // }).toList())
              ]);
        }),
        Positioned(
            bottom: 150,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(3, 18);
                    });
                    controller.move(controller.camera.center, _currentZoom);
                  },
                  child: Text("+"),
                ),
                FloatingActionButton(
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image.path),
                      width: 60,
                      height: 60,
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
                  trailing: const Icon(Icons.arrow_forward_ios),
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

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
