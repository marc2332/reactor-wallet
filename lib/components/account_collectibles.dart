import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/clickable_card.dart';
import 'package:reactor_wallet/pages/collectible_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';

class AccountCollectibles extends ConsumerWidget {
  final Account account;

  const AccountCollectibles({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectibles = account.tokens.values.whereType<NFT>();
    final screenSize = MediaQuery.of(context).size;
    final columnsNumber = screenSize.width > 750 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: RefreshIndicator(
          key: Key(account.address),
          onRefresh: () async {
            // Refresh the account when pulling down
            final accountsProv = ref.read(accountsProvider.notifier);
            await accountsProv.refreshAccount(account.name);
          },
          child: collectibles.isEmpty
              ? const Center(
                  child: Text("This address doesn't own any collectible"),
                )
              : GridView.count(
                  crossAxisCount: columnsNumber,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: collectibles.map(
                    (nft) {
                      final screenSize = MediaQuery.of(context).size;
                      final name = nft.imageInfo?.data?.name ?? "Unknown";

                      return Column(
                        children: [
                          ClickableCard(
                            child: Hero(
                              tag: nft.imageInfo!.uri,
                              child: CachedNetworkImage(
                                height: 120,
                                width: 120,
                                imageUrl: nft.imageInfo!.uri,
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
                          Text(name.length > 18 ? '${name.substring(0, 16)}...' : name),
                        ],
                      );
                    },
                  ).toList(),
                ),
        ),
      ),
    );
  }
}
