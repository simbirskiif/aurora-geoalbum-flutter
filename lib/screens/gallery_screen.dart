import 'package:flutter/material.dart';
import 'package:geo_album/image_location.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/widgets/image_item.dart';
import 'package:provider/provider.dart';

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
    final crossAxisCount = (screenWidth / 100).floor().clamp(4, 12);
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
                        return ImageItem(widget: widget, image: image);
                      });
        })),
      ],
    );
  }
}
