import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactor_wallet/components/clickable_card.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/wallet_account.dart';
import 'package:shimmer/shimmer.dart';

Future<WalletAccount?> selectAccount(BuildContext context) async {
  return await showDialog<WalletAccount?>(
    context: context,
    builder: (BuildContext context) {
      return HookConsumer(
        builder: (context, ref, _) {
          final accounts = ref.watch(accountsProvider);

          Iterable<WalletAccount> wallets = accounts.values.whereType<WalletAccount>();

          return AlertDialog(
            title: const Text('Select an account'),
            content: SizedBox(
              height: 200,
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: wallets.length,
                itemBuilder: (BuildContext context, int index) {
                  final account = wallets.toList()[index];

                  return ClickableCard(
                    onTap: () {
                      Navigator.pop(context, account);
                    },
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet_outlined),
                        title: Text(account.name),
                        trailing: account.isItemLoaded(AccountItem.usdBalance)
                            ? Text('\$${account.usdBalance.toStringAsFixed(2)}')
                            : Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 50,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(150, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
