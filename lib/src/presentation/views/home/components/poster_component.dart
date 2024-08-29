import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/configs.dart';

class PosterComponent extends StatelessWidget {
  const PosterComponent(
      {super.key, required this.imageUrl, this.width, this.height});

  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final configsProvider = context.watch<ConfigsProvider>();
    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[700],
          ),
          child: (imageUrl.isNotEmpty &&
                  !imageUrl.contains('undefined') &&
                  !imageUrl.contains('null') &&
                  !configsProvider.hideImages &&
                  configsProvider.isRealDevice)
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.fitHeight,
                  placeholder: (context, url) =>
                      const Icon(Icons.image, size: 30.0, color: Colors.grey),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, size: 30.0, color: Colors.red),
                )
              : Icon(Icons.image, size: 30.0, color: Colors.grey[200]),
        ),
      ),
    );
  }
}
