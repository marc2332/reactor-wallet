import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WrapperImage extends StatelessWidget {
  final String url;

  WrapperImage(this.url);

  @override
  Widget build(BuildContext context) {
    RegExp isImage = RegExp(r'[\/.](jpg|jpeg|png)', caseSensitive: true);
    if (isImage.hasMatch(url)) {
      return CachedNetworkImage(
        imageUrl: url,
        height: 30,
        width: 30,
        errorWidget: (context, url, error) => const Icon(Icons.no_accounts_outlined),
      );
    } else {
      return Container(width: 30, height: 30, child: const Icon(Icons.no_accounts_outlined));
    }
  }
}
