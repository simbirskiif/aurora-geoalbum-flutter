import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/models/image_location.dart';
import 'package:geo_album/utils/save_utils.dart';
import 'package:geo_album/widgets/big_row.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  final ImageLocation img;

  const EditorScreen({super.key, required this.img});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool inWork = false;
  final CropController _controller = CropController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Редактирование: ${widget.img.path}",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          inWork
              ? Padding(
                  padding: EdgeInsets.only(
                    right: 4,
                  ),
                  child: SpinKitWave(
                    color: Colors.black,
                    size: 20,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    inWork = true;
                    _controller.crop();
                  },
                  icon: Icon(Icons.save))
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          Center(
            child: SpinKitWave(
              size: 50,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Crop(
                baseColor: Colors.black,
                controller: _controller,
                image: File(widget.img.path).readAsBytesSync(),
                onCropped: (result) {
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      // _saveToFileWithoutEditingName(
                      //     widget.img.path, croppedImage);
                      _showSaveDialog(croppedImage);
                    case CropFailure():
                      debugPrint("Не удалось обрезать");
                      setState(() {
                        inWork = false;
                      });
                  }
                }),
          )
        ],
      ),
    );
  }

  void _showSaveDialog(final data) async {
    setState(() {
      inWork = true;
    });
    bool lock = false;
    await showModalBottomSheet(
        context: context,
        builder: (contex) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () async {
                    if (lock) return;
                    setState(() {
                      lock = true;
                    });
                    await saveToFileWithoutEditingName(widget.img.path, data);
                    final file = File(widget.img.path);
                    int replies = 5;
                    while (!file.existsSync() && replies > 0) {
                      await Future.delayed(Duration(milliseconds: 50));
                      replies--;
                    }
                    if (file.existsSync() && file.lengthSync() > 0) {
                      final fileImage = FileImage(file);
                      fileImage.evict();
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          Provider.of<ImageManager>(context, listen: false)
                              .findAndUpdateImages());
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: BigRow(
                      icon: Icons.save_as,
                      title: "Сохранить в оригинальном файле",
                      value:
                          "Будет сохранен как: ${widget.img.path.split("/").last}"),
                ),
                GestureDetector(
                  onTap: () async {
                    if (lock) return;
                    setState(() {
                      lock = true;
                    });
                    await saveToFileWithDateAndTime(widget.img.path, data);
                    final file = File(widget.img.path);
                    int replies = 5;
                    while (!file.existsSync() && replies > 0) {
                      await Future.delayed(Duration(milliseconds: 50));
                      replies--;
                    }
                    if (file.existsSync() && file.lengthSync() > 0) {
                      final newImage = ImageLocation(
                          path: widget.img.path,
                          latitude: widget.img.latitude,
                          longitude: widget.img.longitude,
                          creationDate: widget.img.creationDate);
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          Provider.of<ImageManager>(context, listen: false)
                              .updateImage(widget.img, newImage));
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: BigRow(
                      icon: Icons.save,
                      title: "Сохранить в новом файле",
                      value:
                          "Будет сохранен как: ${getDateAndTimeNameString(widget.img.path).toString()}"),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          );
        });
    setState(() {
      inWork = false;
    });
  }
}
