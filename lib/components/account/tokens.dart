import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/account/account_home.dart';
import 'package:reactor_wallet/components/token_card_info.dart';
import 'package:reactor_wallet/components/token_card_shimmer.dart';
import 'package:reactor_wallet/utils/accounts/base_account.dart';

class AccountTokens extends StatelessWidget {
  final Account account;
  final ScrollController listController = ScrollController();

  AccountTokens(this.account, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            List<Token> accountTokens = List.from(account.tokens.values);
            accountTokens.retainWhere((token) => token is! NFT);

            int accountTokenQuantity = accountTokens.length;

            orderTokensByUSDBalanace(accountTokens);

            if (account.isItemLoaded(AccountItem.tokens)) {
              if (accountTokenQuantity == 0) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text("This address doesn't own any token"),
                          )
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  controller: listController,
                  itemCount: accountTokens.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return TokenCardInfo(accountTokens[index]);
                  },
                );
              }
            } else {
              return ListView.builder(
                controller: listController,
                itemCount: 7,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return const TokenCardWithShimmer();
                },
              );
            }
          },
        ),
      ),
    );
  }
}
