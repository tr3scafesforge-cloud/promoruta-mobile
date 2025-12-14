// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsConfigGen {
  const $AssetsConfigGen();

  /// File path: assets/config/app_config.json
  String get appConfig => 'assets/config/app_config.json';

  /// List of all assets
  List<String> get values => [appConfig];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/map_marker_24.png
  AssetGenImage get mapMarker24 =>
      const AssetGenImage('assets/icons/map_marker_24.png');

  /// File path: assets/icons/map_marker_32.png
  AssetGenImage get mapMarker32 =>
      const AssetGenImage('assets/icons/map_marker_32.png');

  /// File path: assets/icons/map_marker_48.png
  AssetGenImage get mapMarker48 =>
      const AssetGenImage('assets/icons/map_marker_48.png');

  /// File path: assets/icons/map_marker_full_24.png
  AssetGenImage get mapMarkerFull24 =>
      const AssetGenImage('assets/icons/map_marker_full_24.png');

  /// File path: assets/icons/map_marker_full_32.png
  AssetGenImage get mapMarkerFull32 =>
      const AssetGenImage('assets/icons/map_marker_full_32.png');

  /// File path: assets/icons/map_marker_full_48.png
  AssetGenImage get mapMarkerFull48 =>
      const AssetGenImage('assets/icons/map_marker_full_48.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        mapMarker24,
        mapMarker32,
        mapMarker48,
        mapMarkerFull24,
        mapMarkerFull32,
        mapMarkerFull48
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/advertiser_selection.png
  AssetGenImage get advertiserSelection =>
      const AssetGenImage('assets/images/advertiser_selection.png');

  /// File path: assets/images/promoter_selection.png
  AssetGenImage get promoterSelection =>
      const AssetGenImage('assets/images/promoter_selection.png');

  /// File path: assets/images/splash_img.png
  AssetGenImage get splashImg =>
      const AssetGenImage('assets/images/splash_img.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [advertiserSelection, promoterSelection, splashImg];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsConfigGen config = $AssetsConfigGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
