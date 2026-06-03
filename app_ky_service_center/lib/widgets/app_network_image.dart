import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for [Image.network] that persists images to disk so
/// the API is only ever hit once per URL.  Subsequent loads come from the
/// on-device cache — no network round-trip required.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  /// Custom widget shown when the image fails to load.
  /// Receives (context, url, error) — same as [CachedNetworkImage.errorWidget].
  /// Defaults to a grey broken-image icon.
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      placeholder: (context, url) => Container(color: Colors.grey.shade200),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              ),
    );
  }
}
