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
    final collectibles = account.tokens.whereType<NFT>();
    final screenSize = MediaQuery.of(context).size;
    final columnsNumber = screenSize.width > 750 ? 3 : 2;

    return Scaffold(
      body: ResponsiveSizer(
        triggerWidth: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: collectibles.isEmpty
              ? const Center(
                  child: Text("This address doesn't own any collectible"),
                )
              : GridView.count(
                  crossAxisCount: columnsNumber,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: collectibles.map((nft) {
                    final screenSize = MediaQuery.of(context).size;
                    final name = nft.imageInfo?.data?.name ?? "Unknown";

                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
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
                        onTap: () {
                          if (screenSize.width > 600) {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(name),
                                  content: SingleChildScrollView(
                                    child: CollectibleInfo(
                                      nft: nft,
                                      isBig: true,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Dismiss'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
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
                                      nft: nft,
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
