import 'package:flutter/material.dart';
import 'package:reactor_wallet/dialogs/transaction_info.dart';
import 'package:reactor_wallet/utils/base_account.dart';
import 'package:reactor_wallet/utils/theme.dart';

import 'accounts_transaction.dart';

class TransactionCard extends StatelessWidget {
  final TransactionDetails transaction;

  const TransactionCard(this.transaction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool toMe = transaction.receivedOrNot;
    String shortAddress =
        toMe ? transaction.origin.substring(0, 5) : transaction.destination.substring(0, 5);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String readableDate = hourMinutFormatter.format(date);

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(
                      toMe ? Icons.call_received_outlined : Icons.call_made_outlined,
                      color: Theme.of(context).iconColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
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


class UnsupportedTransactionCard extends StatelessWidget {
  final TransactionDetails transaction;

  const UnsupportedTransactionCard(this.transaction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String readableDate = hourMinutFormatter.format(date);

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(readableDate),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: const [
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