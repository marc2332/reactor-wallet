import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/size_wrapper.dart';
import 'package:reactor_wallet/pages/collectible_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';

class AccountCollectibles extends StatelessWidget {
  final Account account;

  const AccountCollectibles({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveSizer(
        triggerWidth: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const BouncingScrollPhysics(),
            children: account.tokens.whereType<NFT>().map((token) {
              final screenSize = MediaQuery.of(context).size;
              final name = token.imageInfo?.data?.name ?? "Unknown";

              return Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: token.imageInfo!.uri,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported_rounded),
                    ),
                  ),
                  onTap: () {
                    if (screenSize.width > 600) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(name),
                            content: SingleChildScrollView(
                              child: CollectibleInfo(
                                nft: token,
                                isBig: true,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return Scaffold(
                              appBar: AppBar(title: Text(name)),
                              body: CollectibleInfo(
                                nft: token,
                                isBig: false,
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
