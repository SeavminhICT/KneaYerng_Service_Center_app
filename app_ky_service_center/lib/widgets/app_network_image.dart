import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../services/api_service.dart';

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

  /// Replaces localhost/127.0.0.1/10.0.2.2 in cached URLs with the current
  /// server origin so images load correctly on real devices.
  String _resolvedUrl() {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      if (host == '127.0.0.1' || host == 'localhost' || host == '10.0.2.2') {
        final serverOrigin = ApiService.serverOrigin;
        final serverUri = Uri.parse(serverOrigin);
        if (serverUri.host.isNotEmpty &&
            serverUri.host != '127.0.0.1' &&
            serverUri.host != 'localhost' &&
            serverUri.host != '10.0.2.2') {
          return uri
              .replace(
                scheme: serverUri.scheme,
                host: serverUri.host,
                port: serverUri.hasPort ? serverUri.port : null,
              )
              .toString();
        }
      }
    } catch (_) {}
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolvedUrl();
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      placeholder: (context, url) => Container(color: Colors.grey.shade200),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  HugeIcons.strokeRoundedImageNotFound01,
                  color: Colors.grey,
                ),
              ),
    );
  }
}
