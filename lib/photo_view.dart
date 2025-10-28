import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/image_location.dart';
import 'package:intl/intl.dart';

class PhotoViewScreen extends StatefulWidget {
  final ImageLocation imageLocation;
  final void Function()? goToMap;
  const PhotoViewScreen(
      {super.key, required this.imageLocation, required this.goToMap});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  @override
  Widget build(BuildContext context) {
    final filePath = widget.imageLocation.path;
    final file = File(filePath);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Просмотр: $filePath",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
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
                      color: Colors.grey,
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
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
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
                                flex: 1,
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
                                    flex: 1,
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
                                : Text("")
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
                _row(Icons.folder, "Путь", imageLocation.path),
                _row(
                    Icons.date_range,
                    "Создан",
                    imageLocation.creationDate != null
                        ? DateFormat("dd.MM.yyyy в HH:mm")
                            .format(imageLocation.creationDate!)
                        : "Неизвестно"),
                imageLocation.latitude != null &&
                        imageLocation.longitude != null
                    ? _row(Icons.location_on, "Локация",
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

  Widget _row(IconData icon, String title, String value) {
    return GestureDetector(
      onLongPress: () {
        debugPrint("Скопировано в буфер обмена");
        Clipboard.setData(ClipboardData(text: title));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.blueGrey,
            ),
            SizedBox(
              width: 12,
            ),
            SizedBox(
              width: 100,
              child: Text(
                title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
                child: Text(
              value,
              style: TextStyle(color: Colors.black54),
              softWrap: true,
            ))
          ],
        ),
      ),
    );
  }
}
