import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WrapperImage extends StatelessWidget {
  final String url;

  const WrapperImage(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp isImage = RegExp(r'[\/.=](jpg|jpeg|png)', caseSensitive: true);
    if (isImage.hasMatch(url)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: CachedNetworkImage(
          imageUrl: url,
          height: 20,
          width: 35,
          errorWidget: (context, url, error) => const Icon(Icons.no_accounts_outlined),
        ),
      );
    } else {
      return const SizedBox(width: 30, height: 30, child: Icon(Icons.no_accounts_outlined));
    }
  }
}
