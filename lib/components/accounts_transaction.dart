import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reactor_wallet/components/transaction_card.dart';
import 'package:reactor_wallet/components/transaction_card_shimmer.dart';
import 'package:reactor_wallet/components/transaction_card_unsupported.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';

DateFormat hourMinutFormatter = DateFormat.Hm();
DateFormat dayFormatter = DateFormat.yMMMMEEEEd();

List getAllBlockNumbers(List<TransactionDetails> txs) {
  Map<String, List<TransactionDetails>> blocks = {};

  for (var tx in txs) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(tx.blockTime * 1000);
    String readableDate = dayFormatter.format(date);

    if (blocks[readableDate] == null) blocks[readableDate] = [];

    blocks[readableDate]!.add(tx);
  }

  List<dynamic> items = [];

  for (var entry in blocks.entries) {
    items.add(entry.key);

    items.addAll(entry.value);
  }

  return items;
}

class AccountTransactions extends HookConsumerWidget {
  final Account account;

  const AccountTransactions({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for changes
    ref.watch(accountsProvider);

    return Padding(
      key: key,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: RefreshIndicator(
          key: Key(account.address),
          onRefresh: () async {
            // Refresh the account when pulling down
            final accountsProv = ref.read(accountsProvider.notifier);
            await accountsProv.refreshAccount(account.name);
          },
          child: Builder(builder: (BuildContext context) {
            if (account.isItemLoaded(AccountItem.transactions)) {
              if (account.transactions.isNotEmpty) {
                List<TransactionDetails> txs = account.transactions;

                // Wrap the transactions and block times in the same list
                List items = getAllBlockNumbers(txs);

                return ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    if (item is TransactionDetails) {
                      final TransactionDetails tx = item;
                      if (tx.origin != "Unknown") {
                        return TransactionCard(tx);
                      } else {
                        return UnsupportedTransactionCard(tx);
                      }
                    } else {
                      String blockTime = item as String;
                      return Padding(
                        padding: const EdgeInsets.all(7),
                        child: Text(
                          blockTime,
                          style: TextStyle(color: Theme.of(context).fadedTextColor),
                        ),
                      );
                    }
                  },
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("No recent payments found"),
                      ],
                    ),
                  ],
                );
              }
            } else {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return const TransactionCardWithShimmer();
                },
              );
            }
          }),
        ),
      ),
    );
  }
}
