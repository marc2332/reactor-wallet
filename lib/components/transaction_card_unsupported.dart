import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/accounts_transaction.dart';
import 'package:reactor_wallet/utils/base_account.dart';

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
