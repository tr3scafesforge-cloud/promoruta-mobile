import 'package:flutter/material.dart';

/// Caps the image size based on the screen size to prevent loading unnecessarily large images.
ImageProvider? capImageSize(BuildContext context, ImageProvider? image,
    {double scale = 1}) {
  if (image == null) return image;
  final MediaQueryData mq = MediaQuery.of(context);
  final Size screenSize = mq.size * mq.devicePixelRatio * scale;
  return ResizeImage(image, width: screenSize.width.round());
}
