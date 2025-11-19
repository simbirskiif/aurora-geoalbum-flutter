import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/models/image_location.dart';
import 'package:geo_album/widgets/image_item.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.goToMap});

  final void Function(ImageLocation image)? goToMap;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  get math => null;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 100).floor().clamp(4, 12);
    return RefreshIndicator(
        child: SingleChildScrollView(
          child: Column(
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
              Consumer<ImageManager>(builder: (context, value, child) {
                if (value.isUpdating) {
                  return const Center(
                    child: SpinKitWave(
                      size: 50,
                      color: Colors.black,
                    ),
                  );
                } else if (value.images.isEmpty) {
                  return const Center(
                    child: Text("Не найдено изображений"),
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true, // занимает только нужное место
                    physics:
                        const NeverScrollableScrollPhysics(), // скролл только у Column
                    itemCount: value.images.length,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final image = value.images[index];
                      return ImageItem(widget: widget, image: image);
                    },
                  );
                }
              }),
              const SizedBox(height: 80, width: double.infinity),
            ],
          ),
        ),
        onRefresh: () async {
          final random = Random();
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              Provider.of<ImageManager>(context, listen: false)
                  .findAndUpdateImages());
          await Future.delayed(Duration(seconds: 1 + random.nextInt(3)));
        });
  }
}
