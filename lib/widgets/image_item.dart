import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geo_album/image_location.dart';
import 'package:geo_album/photo_view.dart';
import 'package:geo_album/screens/gallery_screen.dart';

class ImageItem extends StatelessWidget {
  const ImageItem({
    super.key,
    required this.widget,
    required this.image,
  });

  final GalleryScreen widget;
  final ImageLocation image;

  @override
  Widget build(BuildContext context) {
    return GridTile(
        child: GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PhotoViewScreen(
              goToMap: () {
                widget.goToMap!(image);
              },
              imageLocation: image);
        }));
      },
      child: Stack(
        children: [
          // Center(
          //   child: CircularProgressIndicator(),
          // ),
          Positioned.fill(
              child: Image.file(
            File(image.path),
            fit: BoxFit.cover,
            cacheWidth: 150,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return frame == null
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
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
                image.path.split("/").last,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
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
  }
}
