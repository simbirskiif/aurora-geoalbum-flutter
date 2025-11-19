import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/models/image_location.dart';
import 'package:geo_album/screens/photo_view_screen.dart';
import 'package:geo_album/screens/gallery_screen.dart';
import 'package:geo_album/utils/rename_dialog.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImageItem extends StatefulWidget {
  const ImageItem({
    super.key,
    required this.widget,
    required this.image,
  });

  final GalleryScreen widget;
  final ImageLocation image;

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  Widget build(BuildContext context) {
    final file = File(widget.image.path);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return Skeletonizer(
          ignorePointers: true,
          ignoreContainers: true,
          enabled: true,
          child: SizedBox(
            width: 100,
            height: 100,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.red)),
          ));
    }
    return GestureDetector(
      onLongPress: () async {
        bool renamed = await showRenameDialog(context, file);
        if (!mounted) return;
        if(renamed & mounted){
          ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Файл переименован")));
          WidgetsBinding.instance.addPostFrameCallback((_) =>
            Provider.of<ImageManager>(context, listen: false)
                .findAndUpdateImages());
        }
      },
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PhotoViewScreen(
              goToMap: () {
                widget.widget.goToMap!(widget.image);
              },
              imageLocation: widget.image);
        }));
      },
      child: Stack(
        children: [
          Positioned.fill(
              child: Image.file(
            File(widget.image.path),
            fit: BoxFit.cover,
            cacheWidth: 150,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return frame == null
                  ? Skeletonizer(
                      ignorePointers: true,
                      ignoreContainers: true,
                      enabled: true,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.red)),
                      ))
                  : child;
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black]))),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8, left: 3),
              child: Text(
                widget.image.path.split("/").last,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          widget.image.latitude == null && widget.image.longitude == null
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
    );
  }
}
