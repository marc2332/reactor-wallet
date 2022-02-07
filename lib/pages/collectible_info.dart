import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/utils/base_account.dart';

class CollectibleInfo extends ConsumerWidget {
  final NFT nft;
  final bool isBig;

  const CollectibleInfo({Key? key, required this.nft, required this.isBig}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = nft.imageInfo?.data?.attributes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Hero(
                    tag: nft.imageInfo!.uri,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: nft.imageInfo!.uri,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image_not_supported_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: isBig
              ? const EdgeInsets.all(10)
              : const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attributes.map(
              (attribute) {
                return Row(
                  children: [
                    Text(
                      '${attribute.traitType}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(attribute.value.toString()),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
