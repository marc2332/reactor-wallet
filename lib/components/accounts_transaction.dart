import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reactor_wallet/dialogs/transaction_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/states.dart';
import 'package:reactor_wallet/utils/theme.dart';

DateFormat hourMinutFormatter = DateFormat.Hm();
DateFormat dayFormatter = DateFormat.yMMMMEEEEd();

class UnsupportedTransactionCard extends StatelessWidget {
  final TransactionDetails transaction;

  const UnsupportedTransactionCard(this.transaction);

  @override
  Widget build(BuildContext context) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String readableDate = hourMinutFormatter.format(date);

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(readableDate),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(Icons.block_outlined),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Unsupported transaction'),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionDetails transaction;

  const TransactionCard(this.transaction);

  @override
  Widget build(BuildContext context) {
    bool toMe = transaction.receivedOrNot;
    String shortAddress =
        toMe ? transaction.origin.substring(0, 5) : transaction.destination.substring(0, 5);

    DateTime date = new DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String readableDate = hourMinutFormatter.format(date);

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(readableDate),
        ),
        Expanded(
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                transactionInfo(context, transaction);
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(
                      toMe ? Icons.call_received_outlined : Icons.call_made_outlined,
                      color: Theme.of(context).iconColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        '${toMe ? '+' : '-'}${transaction.ammount.toString()} SOL ${toMe ? 'from' : 'to'} $shortAddress...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List getAllBlockNumbers(List<TransactionDetails> txs) {
  Map<int, List<TransactionDetails>> blocks = Map();

  txs.forEach((dynamic tx) {
    if (blocks[tx.blockTime] == null) blocks[tx.blockTime] = [];

    blocks[tx.blockTime]!.add(tx);
  });

  List<dynamic> items = [];

  blocks.entries.forEach((entry) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(entry.key * 1000);
    String readableDate = dayFormatter.format(date);

    items.add(readableDate);

    items.addAll(entry.value);
  });

  return items;
}

class AccountTransactions extends HookConsumerWidget {
  final Account account;

  AccountTransactions({Key? key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for changes
    ref.watch(accountsProvider);

    List<TransactionDetails> txs = account.transactions;

    // Wrap the transactions and block times in the same list
    List items = getAllBlockNumbers(txs);

    return Padding(
      key: key,
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: RefreshIndicator(
          key: Key(account.address),
          onRefresh: () async {
            // Refresh the account when pulling down
            final accountsProv = ref.read(accountsProvider.notifier);
            await accountsProv.refreshAccount(account.name);
          },
          child: ListView.builder(
            physics: BouncingScrollPhysics(
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
                  padding: EdgeInsets.all(7),
                  child: Text(
                    blockTime,
                    style: TextStyle(color: Theme.of(context).fadedTextColor),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
