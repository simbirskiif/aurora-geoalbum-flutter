import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geo_album/models/image_location.dart';
import 'package:geo_album/screens/editor_screen.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/utils/rename_dialog.dart';
import 'package:geo_album/widgets/row_default.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhotoViewScreen extends StatefulWidget {
  final ImageLocation imageLocation;
  final void Function()? goToMap;
  const PhotoViewScreen(
      {super.key, required this.imageLocation, required this.goToMap});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  bool isBroken = true;

  Future<void> _checkIfImageIsValid() async {
    final path = widget.imageLocation.path;
    final file = File(path);
    final exists = await file.exists();
    if (!exists) {
      if (mounted) {
        setState(() {
          isBroken = true;
        });
      }
      return;
    }
    final length = await file.length();
    if (length == 0) {
      if (mounted) {
        setState(() {
          isBroken = true;
        });
      }
      return;
    }
    try {
      final bytes = await file.readAsBytes();
      await decodeImageFromList(bytes); // flutter/painting.dart

      if (mounted) {
        setState(() {
          isBroken = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isBroken = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfImageIsValid();
  }

  @override
  Widget build(BuildContext context) {
    final filePath = widget.imageLocation.path;
    final file = File(filePath);
    final fileImage = FileImage(file);
    fileImage.evict();
    bool isLoading = true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Просмотр: $filePath",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          isBroken
              ? Text("")
              : IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditorScreen(img: widget.imageLocation);
                    }));
                  },
                  icon: Icon(Icons.crop)),
          IconButton(
              onPressed: () {
                showInfo(widget.imageLocation);
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: !file.existsSync()
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            )
          : Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                        clipBehavior: Clip.none,
                        minScale: 0.75,
                        maxScale: 4,
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null) {
                              return const Center(
                                  child: SpinKitWave(
                                    size: 50,
                                color: Colors.white,
                              ));
                            }
                            return child;
                          },
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && isLoading) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            });
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 125,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black]))),
                    ),
                  ),
                  Positioned(
                      left: 00,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 10,
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Закрыть",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                            widget.imageLocation.latitude != null &&
                                    widget.imageLocation.longitude != null
                                ? Expanded(
                                    flex: 10,
                                    child: MaterialButton(
                                      onPressed: () {
                                        widget.goToMap!();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Показать на карте",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ))
                                : Text(""),
                            Expanded(
                                flex: 2,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.drive_file_rename_outline_sharp,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      bool renamed =
                                          await showRenameDialog(context, file);
                                      if (!mounted) return;
                                      if (renamed & mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text("Файл переименован")));
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                                Provider.of<ImageManager>(
                                                        context,
                                                        listen: false)
                                                    .findAndUpdateImages());
                                      }
                                    }))
                          ],
                        ),
                      ))
                ],
              ),
            ),
    );
  }

  void showInfo(ImageLocation imageLocation) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                RowDefault(
                    icon: Icons.folder,
                    title: "Путь",
                    value: imageLocation.path),
                RowDefault(
                    icon: Icons.date_range,
                    title: "Создан",
                    value: imageLocation.creationDate != null
                        ? DateFormat("dd.MM.yyyy в HH:mm")
                            .format(imageLocation.creationDate!)
                        : "Неизвестно"),
                imageLocation.latitude != null &&
                        imageLocation.longitude != null
                    ? RowDefault(
                        icon: Icons.location_on,
                        title: "Локация",
                        value:
                            "${imageLocation.latitude != null && imageLocation.longitude != null ? "${imageLocation.latitude?.toStringAsFixed(6)} ${imageLocation.longitude?.toStringAsFixed(6)}" : "Неизвестно"} ")
                    : Text(""),
                // _row(Icons.warning, "Геолокация недоступна. Изображение не отображается на экране карты", ""),
                imageLocation.latitude == null &&
                        imageLocation.longitude == null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 24,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                              child: Text(
                            style: TextStyle(fontWeight: FontWeight.bold),
                            "Локация недоступна. Изображение не отображается на карте",
                            maxLines: 10,
                          ))
                        ],
                      )
                    : Text(""),
                Spacer(
                  flex: 10,
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Закрыть"),
                )
              ],
            ),
          );
        });
  }
}
